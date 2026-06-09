# Consumption CLI Quick Reference

Concise `sqlcmd` output formatting, monitoring queries, and agent tips. For full T-SQL patterns, see [SQLDW-CONSUMPTION-CORE.md](../../../common/SQLDW-CONSUMPTION-CORE.md). For full reusable scripts, see [script-templates.md](script-templates.md).

All examples assume reusable connection variables are set:

```bash
FABRIC_SERVER="<endpoint>.datawarehouse.fabric.microsoft.com"
FABRIC_DB="<WarehouseName>"
SQLCMD="sqlcmd -S $FABRIC_SERVER -d $FABRIC_DB -G"
```

## Script Generation

### Bash Template

See [script-templates.md](script-templates.md) for full bash and PowerShell templates.

Key pattern for script generation:

```bash
#!/usr/bin/env bash
set -euo pipefail
FABRIC_SERVER="${FABRIC_SERVER:?Set FABRIC_SERVER env var}"
FABRIC_DB="${FABRIC_DB:?Set FABRIC_DB env var}"
command -v sqlcmd >/dev/null 2>&1 || { echo "ERROR: sqlcmd not found. Install: winget install sqlcmd"; exit 1; }
az account show >/dev/null 2>&1 || { echo "Run 'az login' first."; exit 1; }

sqlcmd -S "$FABRIC_SERVER" -d "$FABRIC_DB" -G \
  -Q "SET NOCOUNT ON; SELECT * FROM dbo.FactSales WHERE SaleDate >= '2025-01-01'" \
  -W -s"," -h-1 -o results.csv
echo "Results written to results.csv"
```

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
| `-i file.sql` | Input from file | Complex queries |
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

## Monitoring and Performance

For full query catalog see [SQLDW-CONSUMPTION-CORE.md § Monitoring and Diagnostics](../../../common/SQLDW-CONSUMPTION-CORE.md#monitoring-and-diagnostics) and [script-templates.md § Performance Investigation](script-templates.md#bash--performance-investigation).

```bash
# Active queries
$SQLCMD -Q "SELECT request_id, session_id, command, status, total_elapsed_time/1000 AS elapsed_sec FROM sys.dm_exec_requests WHERE status='running' ORDER BY total_elapsed_time DESC" -W

# Kill a stuck session (Admin role)
$SQLCMD -Q "KILL '<distributed_statement_id>'"
```

## Agent Integration Notes

- **GitHub Copilot CLI**: `gh copilot suggest -t shell` for `sqlcmd` one-liners; ensure `-G` and `-d` in output; use "explain" mode for errors.
- **Claude Code / Cowork**: run `sqlcmd -Q "..."` via `bash` tool; follow the Agentic Workflow in [SKILL.md](../SKILL.md); produce scripts using [script-templates.md](script-templates.md).
- Always verify `sqlcmd` availability before first SQL operation.
