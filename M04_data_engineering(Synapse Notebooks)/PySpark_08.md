# Microsoft Fabric Lakehouse Partition Pruning: Spark vs SQL Analytics Endpoint

## Objective

This lab demonstrates:

1. How to create a partitioned Delta table in a Fabric Lakehouse.
2. How to verify partition pruning using Spark.
3. How to inspect physical files being accessed.
4. How to analyze SQL Analytics Endpoint execution plans.
5. Why Spark is the authoritative source for validating partition pruning.
6. Why SQL Analytics Endpoint execution plans do not clearly expose Delta partition elimination.

---

# Architecture

```text
Power BI
    |
SQL Analytics Endpoint
    |
Delta Table
    |
OneLake Files
```

```text
Spark Notebook
    |
Delta Table
    |
OneLake Files
```

Both Spark and SQL Analytics Endpoint query the same Delta table.

---

# Lab Environment

Lakehouse:

```text
lh_sales
```

Notebook:

```text
PySpark Notebook
```

SQL Endpoint:

```text
Lakehouse SQL Analytics Endpoint
```

---

# Step 1: Generate Sample Data

Goal:

Create a large enough dataset to observe optimizer behavior.

Row count:

```text
10,000,000 rows
```

Departments:

```text
IT
HR
Finance
Sales
Marketing
```

Notebook code:

```python
from pyspark.sql import functions as F

row_count = 10000000

df = (
    spark.range(row_count)
    .withColumn(
        "DeptName",
        F.expr("""
        CASE
            WHEN id % 5 = 0 THEN 'IT'
            WHEN id % 5 = 1 THEN 'HR'
            WHEN id % 5 = 2 THEN 'Finance'
            WHEN id % 5 = 3 THEN 'Sales'
            ELSE 'Marketing'
        END
        """)
    )
    .withColumn(
        "HireDate",
        F.expr("date_add('2024-01-01', CAST(id % 365 AS INT))")
    )
    .withColumn(
        "Salary",
        (F.rand() * 100000 + 50000).cast("int")
    )
)
```

Verify:

```python
display(df.limit(10))
```

---

# Step 2: Create Partitioned Delta Table

Partition by:

```text
DeptName
```

Write the table:

```python
df.write \
    .format("delta") \
    .mode("overwrite") \
    .partitionBy("DeptName") \
    .saveAsTable("employee_partition_perf")
```

---

# Step 3: Verify Partition Structure

SQL:

```sql
DESCRIBE DETAIL employee_partition_perf
```

Expected partition folders:

```text
employee_partition_perf
|
|-- DeptName=IT
|-- DeptName=HR
|-- DeptName=Finance
|-- DeptName=Sales
|-- DeptName=Marketing
```

Each department has its own partition folder.

---

# Step 4: Validate Partition Pruning in Spark

Query:

```python
spark.sql("""
SELECT *
FROM employee_partition_perf
WHERE DeptName='IT'
""").explain(True)
```

Expected result:

```text
PartitionFilters:
[(DeptName = IT)]
```

This proves Spark recognizes the partition filter.

---

# Step 5: Verify Physical Files Accessed

Run:

```python
df = spark.sql("""
SELECT *
FROM employee_partition_perf
WHERE DeptName='IT'
""")

for f in df.inputFiles():
    print(f)
```

Expected output:

```text
.../DeptName=IT/part-xxxx.parquet
```

Files from:

```text
DeptName=HR
DeptName=Sales
DeptName=Finance
DeptName=Marketing
```

should not appear.

---

# Evidence #1

Spark Execution Plan

```text
PartitionFilters:
[(DeptName = IT)]
```

This is direct proof of partition pruning.

---

# Evidence #2

Physical Files

```text
.../DeptName=IT/part-xxxx.parquet
```

Only IT partition files are returned.

This is physical proof.

---

# Step 6: Query Through SQL Analytics Endpoint

Open:

```text
Lakehouse SQL Analytics Endpoint
```

Run:

```sql
SELECT COUNT(*)
FROM employee_partition_perf;
```

Example output:

```text
Query Hash: 0xA783781625DBE98D
Duration : 2.379 sec
```

---

Run:

```sql
SELECT COUNT(*)
FROM employee_partition_perf
WHERE DeptName='IT';
```

Example output:

```text
Query Hash: 0x3ADEB24635F381CC
Duration : 2.804 sec
```

---

# Important Observation

The filtered query may not be faster.

Example:

```text
Full table scan : 2.379 sec

DeptName='IT' : 2.804 sec
```

Why?

Factors include:

```text
Caching
Metadata reads
Cluster warm-up
Execution scheduling
Result rendering
```

Therefore elapsed time alone is not reliable proof of partition pruning.

---

# Step 7: Capture Execution Plan in SSMS

Connect to the SQL Analytics Endpoint using:

```text
SQL Server Management Studio (SSMS)
```

Enable:

```text
Display Estimated Execution Plan
```

Query:

```sql
SELECT COUNT(*)
FROM employee_partition_perf
WHERE DeptName='IT';
```

---

# Observed Execution Plan

Plan operators:

```text
Clustered Columnstore Index Scan
        |
Hash Match Aggregate
        |
Return
```

---

# XML Analysis

Important section:

```xml
EstimatedRowsRead="10000000"
EstimateRows="1999910"
```

Interpretation:

```text
Rows Read     = 10,000,000

Rows Returned ≈ 2,000,000
```

The optimizer expects all rows to be scanned.

---

# Full Table Query XML

Query:

```sql
SELECT COUNT(*)
FROM employee_partition_perf;
```

Important section:

```xml
EstimatedRowsRead="10000000"
EstimateRows="10000000"
```

Interpretation:

```text
Rows Read     = 10,000,000

Rows Returned = 10,000,000
```

---

# Comparison

## Query 1

```sql
SELECT COUNT(*)
FROM employee_partition_perf;
```

Execution Plan:

```text
Clustered Columnstore Scan
```

Rows Read:

```text
10,000,000
```

Rows Returned:

```text
10,000,000
```

---

## Query 2

```sql
SELECT COUNT(*)
FROM employee_partition_perf
WHERE DeptName='IT';
```

Execution Plan:

```text
Clustered Columnstore Scan
```

Rows Read:

```text
10,000,000
```

Rows Returned:

```text
2,000,000
```

---

# Key Finding

The SQL Analytics Endpoint execution plan does not visibly expose Delta partition elimination.

The plan still shows:

```text
Clustered Columnstore Scan
```

with:

```text
EstimatedRowsRead = 10,000,000
```

even when a partition filter exists.

---

# Why This Matters

Many engineers assume:

```text
Partitioned Table
    =>
Execution Plan shows partition seek
```

This is not what happens here.

The SQL Analytics Endpoint presents a relational execution plan.

Delta partition pruning is not clearly visible in that plan.

---

# Final Conclusion

## Spark View

Spark clearly exposes partition pruning.

Evidence:

```text
PartitionFilters:
[(DeptName = IT)]
```

and

```text
inputFiles()
```

returns:

```text
DeptName=IT
```

files only.

---

## SQL Analytics Endpoint View

Execution plan shows:

```text
Clustered Columnstore Scan
```

with:

```text
EstimatedRowsRead = 10,000,000
```

for both filtered and unfiltered queries.

The plan does not visibly expose Delta partition elimination.

---

# Recommended Teaching Approach

When teaching Fabric Lakehouse partition pruning:

✅ Use Spark `EXPLAIN`.

✅ Use `inputFiles()`.

✅ Show partition folder structure.

❌ Do not use query duration as proof.

❌ Do not rely on SQL Endpoint execution plans to prove partition elimination.

---

# Final Takeaway

The most reliable method for validating partition pruning in Microsoft Fabric Lakehouse is:

```text
Spark EXPLAIN
        +
PartitionFilters
        +
inputFiles()
```

The SQL Analytics Endpoint can successfully query the same Delta table, but its execution plan does not currently provide a transparent view of Delta partition pruning behavior.
