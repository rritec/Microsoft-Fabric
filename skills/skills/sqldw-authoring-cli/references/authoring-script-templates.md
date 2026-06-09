# Authoring Script Templates

Self-contained templates for generating reusable authoring scripts.

**Common prerequisites** (validated in each template):
- `sqlcmd` (Go) installed — `winget install sqlcmd` / `brew install sqlcmd`
- `az login` session active
- Env vars: `FABRIC_SERVER`, `FABRIC_DB`

## Bash Templates

### Bash — COPY INTO Ingestion

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?Set FABRIC_SERVER env var}"
FABRIC_DB="${FABRIC_DB:?Set FABRIC_DB env var}"
STORAGE_PATH="${1:?Usage: $0 <storage_path> [table_name]}"
TABLE_NAME="${2:-dbo.StagingData}"

command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd (Go) not found. Install: winget install sqlcmd"; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

echo "Loading $STORAGE_PATH → $TABLE_NAME ..."
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -Q "
COPY INTO $TABLE_NAME
FROM '$STORAGE_PATH'
WITH (FILE_TYPE = 'PARQUET')
OPTION (LABEL = 'ETL_COPY_INTO_$(date +%Y%m%d)')"

echo "Verifying..."
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -Q "
SET NOCOUNT ON; SELECT COUNT(*) AS row_count FROM $TABLE_NAME" -W -h-1
echo "✓ Done"
```

### Bash — Full ELT Pipeline (Stage → Transform → Load)

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}" ; FABRIC_DB="${FABRIC_DB:?}"
STORAGE_PATH="${1:?Usage: $0 <parquet_path>}"
BATCH_DATE=$(date +%Y-%m-%d)
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"

echo "[1/3] Loading raw data from $STORAGE_PATH ..."
$SQLCMD -Q "
COPY INTO dbo.Staging_RawSales
FROM '$STORAGE_PATH'
WITH (FILE_TYPE = 'PARQUET')
OPTION (LABEL = 'ETL_Stage_$BATCH_DATE')"

echo "[2/3] Transforming and loading into FactSales ..."
$SQLCMD -Q "
INSERT INTO dbo.FactSales (SaleID, ProductID, CustomerID, SaleDate, Amount)
SELECT SaleID, ProductID, CustomerID,
       CAST(SaleTimestamp AS date) AS SaleDate,
       CAST(RawAmount AS decimal(19,4)) AS Amount
FROM dbo.Staging_RawSales
WHERE RawAmount > 0 AND SaleID IS NOT NULL
OPTION (LABEL = 'ETL_Transform_$BATCH_DATE')"

echo "[3/3] Cleaning staging ..."
$SQLCMD -Q "TRUNCATE TABLE dbo.Staging_RawSales"

echo "✓ ELT pipeline complete for $BATCH_DATE"
$SQLCMD -Q "SET NOCOUNT ON; SELECT COUNT(*) AS fact_rows FROM dbo.FactSales" -W -h-1
```

### Bash — Incremental Upsert (DELETE + INSERT with Retry)

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}" ; FABRIC_DB="${FABRIC_DB:?}"
CUTOFF_DATE="${1:?Usage: $0 <cutoff_date YYYY-MM-DD>}"
MAX_RETRIES=3
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

# Write the upsert SQL to a temp file
TMPFILE=$(mktemp /tmp/upsert_XXXXXX.sql)
cat > "$TMPFILE" <<SQL
SET NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    DELETE FROM dbo.FactSales WHERE SaleDate >= '$CUTOFF_DATE';
    INSERT INTO dbo.FactSales
    SELECT * FROM SalesLakehouse.dbo.ProcessedSales WHERE SaleDate >= '$CUTOFF_DATE';
    COMMIT TRANSACTION;
    PRINT 'SUCCESS';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + CAST(ERROR_NUMBER() AS varchar) + ' - ' + ERROR_MESSAGE();
    THROW;
END CATCH;
SQL

ATTEMPT=1
while [ "$ATTEMPT" -le "$MAX_RETRIES" ]; do
  echo "Attempt $ATTEMPT/$MAX_RETRIES: Upserting data since $CUTOFF_DATE ..."
  if sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -i "$TMPFILE" 2>&1 | tee /dev/stderr | grep -q "SUCCESS"; then
    echo "✓ Upsert complete"
    rm -f "$TMPFILE"
    exit 0
  fi
  echo "Retrying in $((ATTEMPT * 5))s ..."
  sleep $((ATTEMPT * 5))
  ATTEMPT=$((ATTEMPT + 1))
done

rm -f "$TMPFILE"
echo "✗ Failed after $MAX_RETRIES attempts"
exit 1
```

### Bash — Schema Migration (CTAS Workaround)

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}" ; FABRIC_DB="${FABRIC_DB:?}"
TABLE="dbo.FactSales"
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

TMPFILE=$(mktemp /tmp/migrate_XXXXXX.sql)
cat > "$TMPFILE" <<'SQL'
-- Change Amount type from decimal(19,4) to decimal(19,2)
PRINT 'Creating new table with updated schema...';
CREATE TABLE dbo.FactSales_V2 AS
SELECT SaleID, ProductID, CustomerID, SaleDate,
       CAST(Amount AS decimal(19,2)) AS Amount, Quantity
FROM dbo.FactSales;
GO
PRINT 'Dropping original...';
DROP TABLE dbo.FactSales;
GO
PRINT 'Renaming...';
EXEC sp_rename 'dbo.FactSales_V2', 'FactSales';
GO
PRINT 'Re-applying constraints...';
ALTER TABLE dbo.FactSales
ADD CONSTRAINT PK_FactSales PRIMARY KEY NONCLUSTERED (SaleID) NOT ENFORCED;
GO
PRINT 'Migration complete.';
-- WARNING: Re-apply GRANT/DENY security and verify time-travel history is reset.
SQL

echo "Migrating schema for $TABLE ..."
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -i "$TMPFILE"
rm -f "$TMPFILE"
echo "✓ Schema migration complete. Re-apply any GRANT/DENY statements."
```

### Bash — Data Recovery via Time Travel

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}" ; FABRIC_DB="${FABRIC_DB:?}"
TABLE="${1:?Usage: $0 <table> <utc_timestamp>}"
TIMESTAMP="${2:?Usage: $0 <table> <utc_timestamp>}"
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"

echo "Recovering $TABLE as of $TIMESTAMP ..."

$SQLCMD -Q "
CREATE TABLE ${TABLE}_Recovered AS
SELECT * FROM $TABLE
OPTION (FOR TIMESTAMP AS OF '$TIMESTAMP')"

echo "Recovered rows:"
$SQLCMD -Q "SET NOCOUNT ON; SELECT COUNT(*) AS rows FROM ${TABLE}_Recovered" -W -h-1

echo "Merging back missing rows ..."
# Assumes SaleID as PK — adjust for your table
$SQLCMD -Q "
INSERT INTO $TABLE
SELECT r.* FROM ${TABLE}_Recovered r
WHERE NOT EXISTS (SELECT 1 FROM $TABLE t WHERE t.SaleID = r.SaleID)"

$SQLCMD -Q "DROP TABLE ${TABLE}_Recovered"
echo "✓ Recovery complete"
```

### Bash — Create Stored Procedure

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}" ; FABRIC_DB="${FABRIC_DB:?}"

# Write procedure to file (GO separators required)
cat > /tmp/create_sp.sql <<'SQL'
CREATE OR ALTER PROCEDURE dbo.sp_IncrementalLoad
    @CutoffDate date
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM dbo.FactSales WHERE SaleDate >= @CutoffDate;
        INSERT INTO dbo.FactSales
        SELECT * FROM SalesLakehouse.dbo.ProcessedSales WHERE SaleDate >= @CutoffDate;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
SQL

sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -i /tmp/create_sp.sql
echo "✓ Procedure created. Execute: EXEC dbo.sp_IncrementalLoad @CutoffDate = '2025-01-01'"
```

## PowerShell Templates

### PowerShell — COPY INTO Ingestion

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][string]$Database,
    [Parameter(Mandatory)][string]$StoragePath,
    [string]$TableName = "dbo.StagingData"
)

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd (Go) not found. Install: winget install sqlcmd"; exit 1
}
$null = az account show 2>$null
if ($LASTEXITCODE -ne 0) { Write-Error "Not logged in. Run: az login"; exit 1 }

$query = @"
COPY INTO $TableName
FROM '$StoragePath'
WITH (FILE_TYPE = 'PARQUET')
OPTION (LABEL = 'ETL_COPY_$(Get-Date -Format yyyyMMdd)')
"@

Write-Host "Loading $StoragePath → $TableName ..."
sqlcmd -S $Server -d $Database -G -Q $query
Write-Host "Verifying..."
sqlcmd -S $Server -d $Database -G -Q "SET NOCOUNT ON; SELECT COUNT(*) AS rows FROM $TableName" -W -h-1
Write-Host "Done"
```

### PowerShell — Incremental Upsert with Retry

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][string]$Database,
    [Parameter(Mandatory)][string]$CutoffDate,
    [int]$MaxRetries = 3
)

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd not found."; exit 1
}

$sql = @"
SET NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    DELETE FROM dbo.FactSales WHERE SaleDate >= '$CutoffDate';
    INSERT INTO dbo.FactSales SELECT * FROM SalesLakehouse.dbo.ProcessedSales WHERE SaleDate >= '$CutoffDate';
    COMMIT TRANSACTION;
    PRINT 'SUCCESS';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
"@

$tmpFile = [System.IO.Path]::GetTempFileName() + ".sql"
$sql | Out-File -FilePath $tmpFile -Encoding UTF8

for ($i = 1; $i -le $MaxRetries; $i++) {
    Write-Host "Attempt $i/$MaxRetries ..."
    $output = sqlcmd -S $Server -d $Database -G -i $tmpFile 2>&1
    if ($output -match "SUCCESS") {
        Remove-Item $tmpFile -Force
        Write-Host "Upsert complete"; exit 0
    }
    Write-Host "Retrying in $($i * 5)s ..."
    Start-Sleep -Seconds ($i * 5)
}

Remove-Item $tmpFile -Force
Write-Error "Failed after $MaxRetries attempts"; exit 1
```
