# Authoring CLI Quick Reference

Concise `sqlcmd` invocation patterns, output formatting, monitoring queries, and agent tips. For full T-SQL patterns, see [SQLDW-AUTHORING-CORE.md](../../../common/SQLDW-AUTHORING-CORE.md). For full reusable scripts, see [authoring-script-templates.md](authoring-script-templates.md).

All examples assume reusable connection variables are set:

```bash
FABRIC_SERVER="<endpoint>.datawarehouse.fabric.microsoft.com"
FABRIC_DB="<WarehouseName>"
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"
```

## Core Authoring via CLI

### Table DDL via CLI

```bash
# CREATE TABLE
$SQLCMD -Q "
CREATE TABLE dbo.FactSales (
    SaleID bigint NOT NULL,
    ProductID int NOT NULL,
    SaleDate date NOT NULL,
    Amount decimal(19,4) NOT NULL
)"

# CTAS with explicit types (preferred for populated tables)
$SQLCMD -Q "
CREATE TABLE dbo.FactSales_2024 AS
SELECT SaleID, CAST(Amount AS decimal(19,2)) AS Amount
FROM dbo.FactSales WHERE SaleDate >= '2024-01-01'"

# ALTER TABLE — add column / DROP TABLE
$SQLCMD -Q "ALTER TABLE dbo.FactSales ADD Region varchar(50) NULL"
$SQLCMD -Q "DROP TABLE IF EXISTS dbo.StagingTable"
```

### DML via CLI

```bash
# INSERT...SELECT (preferred for bulk)
$SQLCMD -Q "
INSERT INTO dbo.FactSales (SaleID, ProductID, SaleDate, Amount)
SELECT SaleID, ProductID, SaleDate, Amount
FROM dbo.StagingTable WHERE IsValid = 1"

# Upsert (production-safe: DELETE + INSERT) — use -i for multi-statement
$SQLCMD -i upsert.sql

# TRUNCATE (fast, preserves history — use instead of DELETE FROM)
$SQLCMD -Q "TRUNCATE TABLE dbo.StagingTable"
```

### Data Ingestion via CLI

```bash
# Parquet from ADLS Gen2 (uses caller's Entra ID credentials)
$SQLCMD -Q "
COPY INTO dbo.FactSales
FROM 'https://storageacct.dfs.core.windows.net/container/sales/*.parquet'
WITH (FILE_TYPE = 'PARQUET')"

# CSV with options
$SQLCMD -Q "
COPY INTO dbo.FactSales
FROM 'https://storageacct.dfs.core.windows.net/container/sales/*.csv'
WITH (FILE_TYPE = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')"

# OPENROWSET + CTAS (transform-on-ingest)
$SQLCMD -Q "
CREATE TABLE dbo.CleanData AS
SELECT id, UPPER(country) AS Country, CAST(amount AS decimal(19,4)) AS Amount
FROM OPENROWSET(BULK 'https://storageacct.dfs.core.windows.net/container/raw/*.parquet') AS raw
WHERE amount > 0"
```

## Advanced Authoring Patterns via CLI

### Transactions via CLI

Multi-statement transactions require input files or piped here-docs (GO separators needed between batch-scoped statements).

```bash
# Simple transaction via piped input
cat <<'SQL' | sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G
BEGIN TRANSACTION;
INSERT INTO dbo.FactSales SELECT * FROM dbo.StagingTable WHERE IsValid = 1;
DELETE FROM dbo.StagingTable WHERE IsValid = 1;
COMMIT TRANSACTION;
SQL

# Transaction with TRY/CATCH via input file
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -i etl_load.sql
```

### Schema Evolution via CLI

```bash
# Add nullable column (fast metadata op)
$SQLCMD -Q "ALTER TABLE dbo.FactSales ADD Region varchar(50) NULL"

# Drop column (April 2025+)
$SQLCMD -Q "ALTER TABLE dbo.FactSales DROP COLUMN Region"

# Change column type (CTAS workaround — ALTER COLUMN not supported)
$SQLCMD -i schema_migrate.sql
```

> **Warning**: CTAS + rename loses time-travel history and security. Re-apply GRANT/DENY after swap.

### Stored Procedures via CLI

```bash
# Create procedure (use -i for multi-statement with GO)
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G -i create_sp.sql

# Execute procedure
$SQLCMD -Q "EXEC dbo.sp_LoadFactSales @BatchDate = '2025-06-15'"

# Create view on Lakehouse SQLEP (read-only endpoint — views/funcs/procs allowed)
sqlcmd -S "$LAKEHOUSE_SERVER" -d "$LAKEHOUSE_DB" -G -i create_views.sql
```

### Time Travel and Recovery via CLI

```bash
# Query data as it existed at a specific time (UTC)
$SQLCMD -Q "
SELECT * FROM dbo.FactSales
OPTION (FOR TIMESTAMP AS OF '2025-06-14T23:59:59.999')" -W

# Recover deleted data via CTAS + merge back
$SQLCMD -Q "
CREATE TABLE dbo.FactSales_Recovered AS
SELECT * FROM dbo.FactSales
OPTION (FOR TIMESTAMP AS OF '2025-06-14T23:59:59.999')"
```

## Script Generation

### sqlcmd Output Formatting Flags

| Flag | Purpose | When |
|---|---|---|
| `-W` | Trim trailing spaces | Always |
| `-s","` | Column separator | CSV export |
| `-s"\t"` | Tab separator | TSV export |
| `-h-1` | No headers/dashes | Clean CSV body |
| `-h 1` | Headers, no dashes | CSV with headers |
| `-w 4000` | Line width | Wide tables |
| `-o file` | Output to file | Export |
| `-i file.sql` | Input from file | Complex queries, multi-statement |
| `-F vertical` | One column per row | Exploration |
| `SET NOCOUNT ON;` | Suppress row-affected messages | Always in scripts |

### Piped Input

```bash
# Pipe SQL from stdin
echo "SELECT TOP 5 * FROM dbo.FactSales" | sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G

# Here-doc for multi-statement
cat <<'SQL' | sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G
SET NOCOUNT ON;
SELECT COUNT(*) AS TotalRows FROM dbo.FactSales;
SELECT TOP 3 ProductID, SUM(Amount) AS Total FROM dbo.FactSales GROUP BY ProductID ORDER BY Total DESC;
SQL
```

### Parameterized Queries (sqlcmd Variables)

```bash
sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G \
  -v StartDate="2025-01-01" EndDate="2025-06-30" \
  -Q "SET NOCOUNT ON; SELECT * FROM dbo.FactSales WHERE SaleDate BETWEEN '$(StartDate)' AND '$(EndDate)'" -W
```

For full reusable bash/PowerShell script templates, see [authoring-script-templates.md](authoring-script-templates.md).

## Monitoring Authoring Operations

For full monitoring catalog see [SQLDW-CONSUMPTION-CORE.md § Monitoring and Diagnostics](../../../common/SQLDW-CONSUMPTION-CORE.md#monitoring-and-diagnostics).

```bash
# Active DML/DDL operations
$SQLCMD -Q "SELECT request_id, session_id, command, status, total_elapsed_time/1000 AS sec FROM sys.dm_exec_requests WHERE command IN ('INSERT','UPDATE','DELETE','MERGE','CREATE TABLE','COPY') ORDER BY total_elapsed_time DESC" -W

# Recent ETL queries (last 24h)
$SQLCMD -Q "SELECT TOP 20 distributed_statement_id, login_name, label, total_elapsed_time_ms FROM queryinsights.exec_requests_history WHERE start_time >= DATEADD(HOUR,-24,GETUTCDATE()) AND label LIKE 'ETL_%' ORDER BY total_elapsed_time_ms DESC" -W

# Failed writes (last 7d) — detect snapshot conflicts
$SQLCMD -Q "SELECT TOP 10 distributed_statement_id, command, start_time, status FROM queryinsights.exec_requests_history WHERE status='Failed' AND start_time >= DATEADD(DAY,-7,GETUTCDATE()) ORDER BY start_time DESC" -W

# Kill a stuck session (Admin role)
$SQLCMD -Q "KILL '<distributed_statement_id>'"
```

## Agent Integration Notes

- **GitHub Copilot CLI**: Generate `sqlcmd` one-liners for DDL/DML or complete `.sql` + `.sh` file pairs. Ensure `-G` and `-d` in output. For COPY INTO, remind user about Storage Blob Data Reader role.
- **Claude Code / Cowork**: Run `sqlcmd -Q "..."` via `bash` tool directly. For multi-statement authoring (procedures, transactions): write `.sql` file first, then execute with `-i`. Always verify `sqlcmd` availability and `az login` before first use. After writes: verify success by querying affected table.
- **Common agent pattern**:
  1. Discover schema (columns, types)
  2. Formulate CTAS/DML with explicit CASTs
  3. Execute via sqlcmd
  4. Verify result (row count, sample)
  5. Optionally generate reusable script
