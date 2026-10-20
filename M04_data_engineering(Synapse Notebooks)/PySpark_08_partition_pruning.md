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



