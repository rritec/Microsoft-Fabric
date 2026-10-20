# Microsoft Fabric Lakehouse Partition Pruning

## Objective

This lab demonstrates:

1. How to create a partitioned Delta table in a Fabric Lakehouse.
2. How to verify partition pruning using Spark.
3. How to inspect physical files being accessed.

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

# Second Example: Partition by DeptName and HireDate

## Objective

This example shows a more granular partition layout. Instead of partitioning only by department, we partition by both:

```text
DeptName
HireDate
```

This creates a directory structure such as:

```text
employee_partition_perf_2
|
|-- DeptName=IT/HireDate=2024-01-01
|-- DeptName=IT/HireDate=2024-01-02
|-- DeptName=IT/HireDate=2024-06-30
|-- DeptName=HR/HireDate=2024-01-01
|-- DeptName=HR/HireDate=2024-01-02
|-- DeptName=Sales/HireDate=2024-02-15
|-- DeptName=Marketing/HireDate=2024-08-10
```

This allows Spark to prune by department and date at the same time.

---

# Step 1: Write the Table with Two Partition Keys

```python
df.write \
    .format("delta") \
    .mode("overwrite") \
    .partitionBy("DeptName", "HireDate") \
    .saveAsTable("employee_partition_perf_2")
```

Now the table is partitioned by both department and hire date.

---

# Step 2: Inspect the Partition Layout

```sql
DESCRIBE DETAIL employee_partition_perf_2
```

Expected folder structure:

```text
employee_partition_perf_2
|
|-- DeptName=IT/HireDate=2024-01-01
|-- DeptName=IT/HireDate=2024-01-02
|-- DeptName=IT/HireDate=2024-06-30
|-- DeptName=HR/HireDate=2024-01-01
|-- DeptName=HR/HireDate=2024-01-02
|-- DeptName=Sales/HireDate=2024-02-15
|-- DeptName=Marketing/HireDate=2024-08-10
```

As the number of partition keys increases, the number of folders increases as well, which makes the scan narrower and more selective.

---

# Step 3: Validate Partition Pruning in Spark

Query:

```python
spark.sql("""
SELECT *
FROM employee_partition_perf_2
WHERE DeptName = 'IT'
  AND HireDate >= date '2024-06-01'
""").explain(True)
```

Expected result:

```text
PartitionFilters:
[(DeptName = IT), (HireDate >= 2024-06-01)]
```

This proves Spark is pruning both partition columns.

---

# Step 4: Verify Physical Files Accessed

```python
result = spark.sql("""
SELECT *
FROM employee_partition_perf_2
WHERE DeptName = 'IT'
  AND HireDate >= date '2024-06-01'
""")

for f in result.inputFiles():
    print(f)
```

Expected output example:

```text
.../DeptName=IT/HireDate=2024-06-01/part-xxxx.parquet
.../DeptName=IT/HireDate=2024-06-15/part-xxxx.parquet
.../DeptName=IT/HireDate=2024-06-30/part-xxxx.parquet
```

Files from other departments or date ranges should not appear.

---

# Evidence #3

Spark Execution Plan

```text
PartitionFilters:
[(DeptName = IT), (HireDate >= 2024-06-01)]
```

This is direct evidence that Spark is applying pruning against both partition columns.

---

# Evidence #4

Physical Files

```text
.../DeptName=IT/HireDate=2024-06-01/part-xxxx.parquet
```

Only the matching department and date partitions are read.

---

# Why this matters

When the table is partitioned by multiple columns, Spark can eliminate large sections of the table before scanning the actual Parquet files.

This is extremely useful when queries filter on:

- department
- date range
- month or year
- customer region + date

In short, the more selective the partition columns are, the smaller the actual file scan becomes.

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

## Multi-Partition View

With a second partition key such as HireDate, Spark can prune at a finer level:

```text
PartitionFilters:
[(DeptName = IT), (HireDate >= 2024-06-01)]
```

and

```text
inputFiles()
```

returns only files from the matching department and date range.

This is the strongest proof that Delta partition pruning is working effectively.

---



"
