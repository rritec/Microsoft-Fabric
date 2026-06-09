# Identity Column

This chapter explains identity (auto-increment) columns commonly used for surrogate primary keys in data warehouse tables.

## T-SQL (SQL Server / Synapse SQL)

- Create a table with an identity column:

```sql
CREATE TABLE dbo.Employees (
  EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
  FirstName NVARCHAR(100),
  LastName NVARCHAR(100)
);
```

- Insert rows (EmployeeID assigned automatically):

```sql
INSERT INTO dbo.Employees (FirstName, LastName)
VALUES ('Ada', 'Lovelace'), ('Alan', 'Turing');
```

- Reseed the identity value:

```sql
DBCC CHECKIDENT ('dbo.Employees', RESEED, 100);
```

## Using SEQUENCE objects

If you need more control or cross-table sequences:

```sql
CREATE SEQUENCE dbo.EmployeeSeq START WITH 1 INCREMENT BY 1;

CREATE TABLE dbo.Employees2 (
  EmployeeID INT DEFAULT (NEXT VALUE FOR dbo.EmployeeSeq) PRIMARY KEY,
  FirstName NVARCHAR(100),
  LastName NVARCHAR(100)
);
```

## Delta Lake / Spark (Fabric notebooks)

Delta tables do not automatically support T-SQL `IDENTITY`. In Spark/Delta, create surrogate keys in ETL:

Example (PySpark):

```python
from pyspark.sql import functions as F
from pyspark.sql.window import Window

# Assign a stable row number as surrogate id (ensure deterministic ordering)
df = df.withColumn('id', F.row_number().over(Window.orderBy('some_column')))

# Or use a monotonically increasing id for ad-hoc keys
df = df.withColumn('tmp_id', F.monotonically_increasing_id())
```

Note: `monotonically_increasing_id()` does not guarantee compact sequential numbering across partitions.

## Best practices

- Use an integer/`BIGINT` identity for large tables to avoid overflow.
- Prefer `BIGINT` for enterprise-scale ingestion.
- Use `SEQUENCE` when you need the same sequence across multiple tables.
- Avoid relying on identity values for business logic — treat them as surrogate keys only.
- When loading data in bulk, consider generating keys in the ETL layer to keep control over values.
- Document any reseed or identity-management operations in deployment scripts.

## Troubleshooting

- To find current identity seed:

```sql
DBCC CHECKIDENT ('dbo.Employees', NORESEED);
```

- Adding an identity property to an existing column is not supported; create a new column or table and migrate data.

---

See also: `IDENTITY(seed, increment)`, `DBCC CHECKIDENT`, `CREATE SEQUENCE`.
