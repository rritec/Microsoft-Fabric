# Extended Discovery Queries

Queries for deep schema exploration beyond the basics in SKILL.md Schema Discovery Sequence.
All queries work on Warehouse, Lakehouse SQLEP, and Mirrored DB SQLEP.

## Schema and Object Discovery

### Table and Column Metadata

```bash
# All columns across all tables with types
$SQLCMD -Q "
SELECT t.table_schema, t.table_name, c.column_name,
       c.data_type, c.character_maximum_length,
       c.numeric_precision, c.numeric_scale, c.is_nullable
FROM information_schema.tables t
JOIN information_schema.columns c
  ON t.table_schema = c.table_schema AND t.table_name = c.table_name
WHERE t.table_type = 'BASE TABLE'
ORDER BY t.table_schema, t.table_name, c.ordinal_position" -W

# Tables with row counts and column counts
$SQLCMD -Q "
SELECT s.name AS [schema], t.name AS [table],
       COUNT(DISTINCT c.column_id) AS col_count,
       SUM(p.rows) AS row_count
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY s.name, t.name
ORDER BY row_count DESC" -W

# Constraints (PK, FK, UNIQUE)
$SQLCMD -Q "
SELECT tc.constraint_type, tc.table_schema, tc.table_name,
       tc.constraint_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
ORDER BY tc.table_schema, tc.table_name, tc.constraint_type" -W

# Foreign key relationships (useful for JOIN hints)
$SQLCMD -Q "
SELECT
    fk.name AS fk_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) + '.' + OBJECT_NAME(fk.parent_object_id) AS child_table,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS child_column,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) + '.' + OBJECT_NAME(fk.referenced_object_id) AS parent_table,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS parent_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY child_table, fk_name" -W
```

### View and Function Definitions

```bash
# View definitions (source SQL)
$SQLCMD -Q "
SELECT s.name AS [schema], v.name AS [view],
       m.definition
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
JOIN sys.sql_modules m ON v.object_id = m.object_id
ORDER BY s.name, v.name" -W

# Function definitions
$SQLCMD -Q "
SELECT s.name AS [schema], o.name AS [function], o.type_desc,
       m.definition
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.sql_modules m ON o.object_id = m.object_id
WHERE o.type IN ('FN','IF','TF')
ORDER BY s.name, o.name" -W

# Stored procedure definitions
$SQLCMD -Q "
SELECT s.name AS [schema], p.name AS [procedure],
       m.definition
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
JOIN sys.sql_modules m ON p.object_id = m.object_id
ORDER BY s.name, p.name" -W

# Procedure parameters
$SQLCMD -Q "
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS [schema],
       OBJECT_NAME(p.object_id) AS [procedure],
       p.name AS param_name,
       TYPE_NAME(p.user_type_id) AS data_type,
       p.max_length, p.is_output
FROM sys.parameters p
JOIN sys.procedures pr ON p.object_id = pr.object_id
WHERE p.parameter_id > 0
ORDER BY [schema], [procedure], p.parameter_id" -W
```

### Cross-Database Discovery

```bash
# List all accessible databases in the workspace
$SQLCMD -Q "SELECT name, create_date FROM sys.databases ORDER BY name" -W

# Tables in another database (3-part name)
$SQLCMD -Q "SELECT table_schema, table_name FROM OtherDatabase.information_schema.tables ORDER BY table_schema, table_name" -W
```

## Security Discovery

```bash
# Current user identity
$SQLCMD -Q "SELECT USER_NAME() AS current_user, SUSER_SNAME() AS login_name" -W

# Database principals
$SQLCMD -Q "
SELECT name, type_desc, authentication_type_desc
FROM sys.database_principals
WHERE type NOT IN ('R')
ORDER BY name" -W

# Role memberships
$SQLCMD -Q "
SELECT r.name AS role_name, m.name AS member_name
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
ORDER BY r.name, m.name" -W

# Object-level permissions
$SQLCMD -Q "
SELECT
    dp.state_desc + ' ' + dp.permission_name AS permission,
    OBJECT_SCHEMA_NAME(dp.major_id) + '.' + OBJECT_NAME(dp.major_id) AS [object],
    prin.name AS grantee
FROM sys.database_permissions dp
JOIN sys.database_principals prin ON dp.grantee_principal_id = prin.principal_id
WHERE dp.major_id > 0
ORDER BY [object], grantee" -W
```

## Statistics and Performance Metadata

```bash
# Statistics on tables
$SQLCMD -Q "
SELECT OBJECT_SCHEMA_NAME(s.object_id) AS [schema],
       OBJECT_NAME(s.object_id) AS [table],
       s.name AS stat_name,
       COL_NAME(sc.object_id, sc.column_id) AS column_name,
       STATS_DATE(s.object_id, s.stats_id) AS last_updated
FROM sys.stats s
JOIN sys.stats_columns sc ON s.object_id = sc.object_id AND s.stats_id = sc.stats_id
ORDER BY [schema], [table], stat_name" -W

# Data clustering info (DW only) — see SQLDW-CONSUMPTION-CORE.md § Performance for full query
$SQLCMD -Q "SELECT OBJECT_SCHEMA_NAME(ic.object_id) AS [schema], OBJECT_NAME(ic.object_id) AS [table], COL_NAME(ic.object_id, ic.column_id) AS cluster_column FROM sys.index_columns ic JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id WHERE i.type_desc = 'CLUSTERED COLUMNSTORE' ORDER BY [schema], [table], ic.key_ordinal" -W
```
