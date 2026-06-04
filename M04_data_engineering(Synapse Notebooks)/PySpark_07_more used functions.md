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
import requests
import urllib.request

# GitHub API URL for the folder contents
api_url = "https://api.github.com/repos/rritec/Azure-Cloud-Data-Engineering/contents/Lab%20Data/sample-data/parquet/"

# target Location
local_path = "/lakehouse/default/Files"

# Call the GitHub API
response = requests.get(api_url)

if response.status_code == 200:
    files = response.json()
    parquet_file = [f['name'] for f in files if f['name'].endswith('.parquet')]
    print(parquet_files)

else:
    print("❌ Failed to fetch file list:", response.status_code)

for file in parquet_files:     
    # Save the parquet file locally
    print(local_path+file)
    print(api_url+file)
    urllib.request.urlretrieve(api_url+file, local_path+file)
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
## 12. repartition Vs coalesce

* ✅ `repartition()` — before a **join** to improve parallelism and avoid skew
* ✅ `coalesce()` — before a **write** to reduce number of output files

---

### 📊 Sample Setup (assuming you already have this)

```python
emp = spark.read.format("delta").load("/lakehouse/default/Files/emp")
dept = spark.read.format("delta").load("/lakehouse/default/Files/dept")
```

---

### 🔁 Best Use Case for `repartition()`

### 🧠 Scenario:

You want to **join emp and dept**, and `emp` has millions of records. You want to **optimize parallelism** for better performance.

```python
# Repartition emp by deptno to optimize shuffle
emp_repart = emp.repartition("deptno")

# Join after repartitioning
result = emp_repart.join(dept, on="deptno", how="inner")
```

✅ This helps **Spark parallelize the join**, especially if there are **skewed departments**.

---

### 🔽 Best Use Case for `coalesce()`

### 🧠 Scenario:

After transformations or join, you want to **save the result as fewer files** (e.g., 1 file per partition).

```python
# Coalesce to reduce number of output files
result_final = result.coalesce(1)

# Save to lakehouse
result_final.write.mode("overwrite").format("delta").save("/lakehouse/default/Files/emp_dept_joined")
```

✅ This reduces small files and improves performance during reads later (especially in Power BI or downstream Fabric pipelines).

---

### 📝 Summary

| Step         | Method        | Why?                          |
| ------------ | ------------- | ----------------------------- |
| Before join  | `repartition` | Even distribution, avoid skew |
| Before write | `coalesce`    | Fewer output files            |

---





## 🔗 References

* [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric)
* [Apache Spark Guide](https://spark.apache.org/docs/latest/)
* [Delta Lake Documentation](https://delta.io/)

---

## 👨‍💻 Author

Created by [Myla RamReddy](https://datahexa.com) for Microsoft Fabric training and PySpark education.

```

