## 📊 Open Table Formats

### 🔹 What

Open table formats add **ACID transactions, schema evolution, and time travel** to data lakes while remaining **open and vendor-neutral**.

---

### 🔹 Types

* Delta Lake → Simple, tightly integrated (Fabric/Databricks)
* Apache Iceberg → Scalable, multi-engine
* Apache Hudi → Streaming & real-time updates

---

### 🔹 Tools Mapping

* Microsoft Fabric → Delta Lake
* Databricks → Delta Lake (+ Iceberg support)
* Snowflake → Apache Iceberg
* Apache Spark → Delta, Iceberg, Hudi
* Apache Flink → Iceberg, Hudi

---

### 🔹 Summary

> Delta = simplicity
> Iceberg = flexibility
> Hudi = real-time

✔ Backbone of modern **Lakehouse architecture**
