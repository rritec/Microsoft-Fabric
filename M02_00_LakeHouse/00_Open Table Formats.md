## 📊 Open Table Formats

### 🔹 What

Open table formats add **ACID transactions, schema evolution, and time travel** to data lakes while remaining **open and vendor-neutral**.

---

### 🔹 Types

* Delta Lake → Simple, tightly integrated (Fabric/Databricks) https://delta.io/
* Apache Iceberg → Scalable, multi-engine https://iceberg.apache.org/
* Apache Hudi → Streaming & real-time updates https://hudi.apache.org/

---

### 🔹 Tools Mapping

* Microsoft Fabric → Delta Lake(Native Format) + Iceberg (Virtualized)
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

      ```           Microsoft Fabric

                       OneLake
                          │

       ┌──────────────────┼──────────────────┐
       │                  │                  │

   Delta Lake         Iceberg          Apache Hudi
   Native Format      Virtualized      Not Native

      ✅                 ✅               ❌
```
