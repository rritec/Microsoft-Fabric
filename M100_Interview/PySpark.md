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
