# 🌿 What is **Column Pruning** in PySpark?

**Column Pruning** is an optimization technique where **Spark reads only the columns required** for a computation — ignoring unnecessary columns from data sources like **Parquet**, **Delta**, **ORC**, etc.

This happens automatically in Spark's **Catalyst optimizer** as part of **lazy evaluation**.

---

## 🔧 Why It Matters

✅ **Performance Gains**:

* Reduces **I/O**: Less data is read from disk.
* Reduces **memory footprint**: Fewer columns in the DataFrame.
* Speeds up execution: Less data to shuffle or cache.

✅ Especially useful for **wide tables** with dozens or hundreds of columns.

---

## 🎯 Example

Assume a Parquet file with 10 columns (`id`, `name`, `email`, `country`, `status`, etc.):

```python
df = spark.read.parquet("/mnt/data/users")

# Column Pruning: only 2 columns are selected
df = df.select("id", "status")

df.show()
```

🔥 **Spark only reads `id` and `status`** from disk — other columns are ignored entirely.

---

## 🧠 When Does Column Pruning Work Best?

| Format         | Supports Column Pruning?     |
| -------------- | ---------------------------- |
| **Parquet**    | ✅ Yes                        |
| **Delta Lake** | ✅ Yes                        |
| **ORC**        | ✅ Yes                        |
| **CSV / JSON** | ❌ No (must read all columns) |

⚠️ With **CSV/JSON**, Spark must read the whole file and then discard columns.

---

## 🔍 How to Verify Column Pruning

Use `.explain()` to inspect the **physical plan**:

```python
df.select("id", "status").explain(True)
```

✅ You’ll see only selected columns being scanned in the **physical plan** if pruning is applied.

---

## 💡 Practical Tip

Avoid `select("*")` if you don't need all columns — it **prevents column pruning**:

```python
# ❌ BAD: reads all columns
df = spark.read.parquet("/mnt/data/users").select("*")

# ✅ GOOD: allows pruning
df = spark.read.parquet("/mnt/data/users").select("id", "status")
```

---

## ✅ Summary

| Feature           | Column Pruning                       |
| ----------------- | ------------------------------------ |
| Optimizes I/O     | ✅ Yes                                |
| Reduces Memory    | ✅ Yes                                |
| Automatic?        | ✅ If only necessary columns are used |
| Formats Supported | Parquet, ORC, Delta                  |

---

Would you like a Databricks notebook example with `.explain()` showing pruning in action?

**Lazy Evaluation** is one of the core optimization principles in **PySpark** and Apache Spark in general.

---

## 🧠 What is Lazy Evaluation in PySpark?

In **lazy evaluation**, PySpark **does not execute your code immediately** when you define transformations like `map()`, `filter()`, or `select()`. Instead, it builds up a **logical execution plan (DAG)** and only **executes** it when an **action** is called — such as `count()`, `collect()`, or `show()`.

---

## 🔁 Lazy vs Eager Evaluation

| Aspect                 | Lazy Evaluation                    | Eager Evaluation           |
| ---------------------- | ---------------------------------- | -------------------------- |
| When is code executed? | When an **action** is triggered    | Immediately upon execution |
| Optimization?          | Yes, Spark optimizes full pipeline | No (runs line-by-line)     |
| Intermediate results   | Not materialized until needed      | Materialized at each step  |

---

## 🔧 Example of Lazy Evaluation

```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("LazyExample").getOrCreate()

# Create DataFrame
df = spark.range(1, 1000)

# Step 1: Transformation - this line does NOT trigger execution
df_filtered = df.filter("id % 2 == 0")

# Step 2: Another Transformation
df_squared = df_filtered.withColumn("square", df_filtered["id"] * df_filtered["id"])

# Step 3: Action - triggers the actual computation
df_squared.show()
```

### 🛑 What happens:

* `range()`, `filter()`, and `withColumn()` are **transformations** → Spark builds a plan.
* Only when `.show()` (an **action**) is called, Spark executes the DAG of operations.
* The entire chain is optimized before execution (via Catalyst + Tungsten).

---

## 🔍 Why Lazy Evaluation Is Powerful

1. **Optimization**:

   * Spark applies **query optimizations** like predicate pushdown, column pruning, etc.
   * It skips unnecessary work and merges stages where possible.

2. **Fault Tolerance**:

   * Spark keeps the DAG, so it can **recompute** only the needed parts in case of failure.

3. **Efficiency**:

   * Avoids materializing intermediate results → saves memory and I/O.

---

## 📊 Real Use Case

```python
# Read a large CSV (no data read yet)
df = spark.read.csv("/mnt/data/large.csv", header=True, inferSchema=True)

# Filter + Transformation (still not executed)
df = df.filter("status = 'active'").select("user_id", "signup_date")

# Trigger the plan
df.write.parquet("/mnt/output/active_users")
```

* Spark won't even read the CSV until the final `.write()` is called.
* Catalyst will **combine filtering and projection** into one optimized scan.

---

## 🧪 How to See the Lazy Plan?

Use `.explain()` before triggering an action:

```python
df.explain()
```

You’ll see the **logical plan** and **physical plan** Spark will use.

---

## ✅ Summary

| Term                             | Examples                                |
| -------------------------------- | --------------------------------------- |
| **Transformations (Lazy)**       | `select`, `filter`, `map`, `withColumn` |
| **Actions (Triggers Execution)** | `show`, `count`, `collect`, `write`     |

---

Would you like a Databricks notebook that walks through this with `.explain()` and performance tips?

