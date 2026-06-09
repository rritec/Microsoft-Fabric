# Script Templates

Self-contained templates for generating reusable query scripts.

## Bash — Data Export

### Query to CSV

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
FABRIC_SERVER="${FABRIC_SERVER:?Set FABRIC_SERVER env var (e.g. xxx.datawarehouse.fabric.microsoft.com)}"
FABRIC_DB="${FABRIC_DB:?Set FABRIC_DB env var (e.g. MyWarehouse)}"
OUTPUT_FILE="${1:-results.csv}"

# --- Prerequisites ---
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd (Go) not found. Install: winget install sqlcmd OR brew install sqlcmd"; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERROR: Not logged in. Run: az login"; exit 1; }

# --- Query ---
QUERY=$(cat <<'SQL'
SET NOCOUNT ON;
SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM dbo.DimProduct
ORDER BY ProductName;
SQL
)

echo "$QUERY" | sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G \
  -W -s"," -w 4000 -h 1 \
  -o "$OUTPUT_FILE"

echo "✓ Written to $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") lines)"
```

### Parameterized Date Range Export

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}"
FABRIC_DB="${FABRIC_DB:?}"
START_DATE="${1:?Usage: $0 <start_date> <end_date> [output_file]}"
END_DATE="${2:?Usage: $0 <start_date> <end_date> [output_file]}"
OUTPUT_FILE="${3:-export_${START_DATE}_${END_DATE}.csv}"

command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G \
  -v StartDate="$START_DATE" EndDate="$END_DATE" \
  -Q "SET NOCOUNT ON; SELECT * FROM dbo.FactSales WHERE SaleDate BETWEEN '\$(StartDate)' AND '\$(EndDate)'" \
  -W -s"," -w 4000 -h 1 \
  -o "$OUTPUT_FILE"

echo "✓ Exported to $OUTPUT_FILE"
```

## Bash — Schema Discovery Report

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}"
FABRIC_DB="${FABRIC_DB:?}"
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"

command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

echo "=== SCHEMAS ==="
$SQLCMD -Q "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name" -W

echo ""
echo "=== TABLES (with row counts) ==="
$SQLCMD -Q "
SELECT s.name AS [schema], t.name AS [table], SUM(p.rows) AS rows
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY s.name, t.name
ORDER BY rows DESC" -W

echo ""
echo "=== VIEWS ==="
$SQLCMD -Q "SELECT SCHEMA_NAME(schema_id) AS [schema], name FROM sys.views ORDER BY [schema], name" -W

echo ""
echo "=== STORED PROCEDURES ==="
$SQLCMD -Q "SELECT SCHEMA_NAME(schema_id) AS [schema], name FROM sys.procedures ORDER BY [schema], name" -W

echo ""
echo "=== FUNCTIONS ==="
$SQLCMD -Q "SELECT SCHEMA_NAME(schema_id) AS [schema], name, type_desc FROM sys.objects WHERE type IN ('FN','IF','TF') ORDER BY [schema], name" -W
```

## Bash — Performance Investigation

```bash
#!/usr/bin/env bash
set -euo pipefail

FABRIC_SERVER="${FABRIC_SERVER:?}"
FABRIC_DB="${FABRIC_DB:?}"
HOURS="${1:-24}"
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"

command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found."; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

echo "=== ACTIVE QUERIES ==="
$SQLCMD -Q "SELECT request_id, session_id, command, status, total_elapsed_time/1000 AS elapsed_sec FROM sys.dm_exec_requests WHERE status='running' ORDER BY total_elapsed_time DESC" -W

echo ""
echo "=== TOP 20 SLOWEST QUERIES (last ${HOURS}h) ==="
$SQLCMD -Q "
SELECT TOP 20
    distributed_statement_id,
    login_name,
    COALESCE(label,'') AS label,
    total_elapsed_time_ms,
    data_scanned_remote_storage_mb,
    LEFT(command, 120) AS command_preview
FROM queryinsights.exec_requests_history
WHERE start_time >= DATEADD(HOUR, -${HOURS}, GETUTCDATE())
ORDER BY total_elapsed_time_ms DESC" -W

echo ""
echo "=== TOP 10 MOST FREQUENT ==="
$SQLCMD -Q "
SELECT TOP 10
    query_hash,
    execution_count,
    median_total_elapsed_time_ms,
    LEFT(last_query_text, 120) AS query_preview
FROM queryinsights.frequently_run_queries
ORDER BY execution_count DESC" -W
```

## PowerShell Templates

### Query to CSV

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][string]$Database,
    [string]$OutputFile = "results.csv"
)

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd (Go) not found. Install: winget install sqlcmd"; exit 1
}
$null = az account show 2>$null
if ($LASTEXITCODE -ne 0) { Write-Error "Not logged in. Run: az login"; exit 1 }

$query = @"
SET NOCOUNT ON;
SELECT ProductID, ProductName, Category, Price
FROM dbo.DimProduct
ORDER BY ProductName;
"@

sqlcmd -S $Server -d $Database -G -Q $query -W -s"," -w 4000 -h 1 -o $OutputFile
Write-Host "Written to $OutputFile"
```

### Schema Discovery

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory)][string]$Server,
    [Parameter(Mandatory)][string]$Database
)

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd not found. Install: winget install sqlcmd"; exit 1
}

Write-Host "`n=== TABLES ===" -ForegroundColor Cyan
sqlcmd -S $Server -d $Database -G -Q "SELECT table_schema, table_name, table_type FROM information_schema.tables ORDER BY table_schema, table_name" -W

Write-Host "`n=== ROW COUNTS ===" -ForegroundColor Cyan
sqlcmd -S $Server -d $Database -G -Q "SELECT s.name AS [schema], t.name AS [table], SUM(p.rows) AS rows FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id JOIN sys.partitions p ON t.object_id=p.object_id AND p.index_id IN (0,1) GROUP BY s.name, t.name ORDER BY rows DESC" -W
```
