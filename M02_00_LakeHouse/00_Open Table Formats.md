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

<img width="383" height="253" alt="image" src="https://github.com/user-attachments/assets/29deb079-6aa8-4ba8-bbdc-4afc9c16d7af" />
<img width="397" height="276" alt="image" src="https://github.com/user-attachments/assets/8776dec3-c5e9-42d2-bde3-3131f2bd4451" />


