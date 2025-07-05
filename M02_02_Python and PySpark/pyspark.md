# PySpark Examples with emp and dept Data (Microsoft Fabric Focus)

This repository contains practical **PySpark** examples designed for teaching key data engineering concepts in **Microsoft Fabric** using the classic `emp` and `dept` datasets. It covers reading data, transformations, joins, optimizations, and writing data to **Delta Lake** inside a Fabric Lakehouse.


## 📁 Dataset Description

Ensure the following CSV files are uploaded to your Lakehouse (OneLake > Files):

- `emp.csv`: Employee data
- `dept.csv`: Department data

---

## 🧱 1. Reading CSV Files

```python
emp_df = spark.read.option("header", True).csv("Files/emp.csv")
dept_df = spark.read.option("header", True).csv("Files/dept.csv")
````

---

## 🔎 2. Filtering Rows

```python
# Filter employees with salary greater than 2000
emp_df_filtered = emp_df.filter(emp_df.sal > 2000)
```

---

## ➕ 3. Column Calculations

```python
# Add bonus column (10% of salary)
emp_df_with_bonus = emp_df.withColumn("bonus", emp_df.sal * 0.1)
```

---

## 🔁 4. Loops (for educational use only)

```python
# Print department names (avoid loops in production)
for row in dept_df.select("dname").collect():
    print(row.dname)
```

---

## 🔗 5. Joins

```python
# Inner join on deptno
emp_dept_df = emp_df.join(dept_df, on="deptno", how="inner")
```

---

## 📡 6. Broadcast Joins (Performance Optimization)

```python
from pyspark.sql.functions import broadcast

# Broadcast smaller dept table
emp_dept_broadcast = emp_df.join(broadcast(dept_df), on="deptno", how="inner")
```

---

## 📊 7. Grouping and Aggregations

```python
# Average salary by department
avg_salary_df = emp_df.groupBy("deptno").agg({"sal": "avg"})
```

---

## 🪟 8. Window Functions

```python
from pyspark.sql.window import Window
from pyspark.sql.functions import rank

window_spec = Window.partitionBy("deptno").orderBy(emp_df.sal.desc())
ranked_df = emp_df.withColumn("salary_rank", rank().over(window_spec))
```

---

## 💾 9. Writing to Delta Table

```python
# Save as Delta format in Microsoft Fabric Lakehouse
emp_dept_df.write.format("delta").mode("overwrite").save("Tables/emp_dept_delta")
```

---

## 🔄 10. Caching and Persistence

```python
# Cache frequently used DataFrame
emp_df.cache()

# Or persist with storage level
from pyspark import StorageLevel
emp_df.persist(StorageLevel.MEMORY_AND_DISK)
```

---

## 🏞️ 11. Reading from and Writing to OneLake

```python
# Reading from OneLake (Files section)
df = spark.read.option("header", True).csv("Files/emp.csv")

# Writing back to OneLake
df.write.format("delta").mode("overwrite").save("Tables/emp_output")
```

---

## 🧪 Bonus Use Cases

* Converting CSV to Delta and querying via SQL Analytics Endpoint
* Data quality checks before writing
* Repartitioning and coalescing data
* Creating views from DataFrames

---

## 📚 Prerequisites

* Microsoft Fabric Workspace (with Spark runtime enabled)
* Lakehouse with `emp.csv` and `dept.csv` in Files
* Access to Delta Lake & SQL Analytics Endpoint (optional)

---

## 🧑‍🏫 Target Audience

* Data Engineers using Microsoft Fabric
* Instructors and students of PySpark
* Professionals migrating from Azure Data Factory or Synapse to Fabric

---

## 📂 Project Structure

```
/data/
    emp.csv
    dept.csv

/notebooks/
    pyspark_examples.ipynb

/README.md
```

---

## 🔗 References

* [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric)
* [Apache Spark Guide](https://spark.apache.org/docs/latest/)
* [Delta Lake Documentation](https://delta.io/)

---

## 👨‍💻 Author

Created by [Myla RamReddy](https://datahexa.com) for Microsoft Fabric training and PySpark education.

```

---

Would you like me to create the starter Jupyter Notebook (`pyspark_examples.ipynb`) with code blocks aligned to this README?
```
