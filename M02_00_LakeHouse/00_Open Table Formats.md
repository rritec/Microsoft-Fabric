## 📊 Open Table Formats

### 🔹 What is an Open Table Format?

An **Open Table Format (OTF)** is an openly specified way to organize and manage tabular data stored in a data lake. It lets analytics engines work with tables directly on cloud object storage—such as Azure Data Lake Storage (ADLS), Amazon S3, or Google Cloud Storage—without requiring the data to live inside a proprietary database.

The most widely used formats are:

* **Delta Lake** — originated at Databricks and widely used with Spark and Microsoft Fabric. https://delta.io/
* **Apache Iceberg** — designed for large tables and interoperability across query engines. https://iceberg.apache.org/
* **Apache Hudi** — supports incremental data processing and use cases with frequent updates. https://hudi.apache.org/

These formats typically store data in open file formats such as **Apache Parquet**, together with metadata that describes the table and its versions. The metadata layer makes a collection of files behave more like a managed database table.

---

### 🔹 Why is it called “Open” Table Format?

**Open** describes several important properties:

* **Open specification** — the format is publicly documented, so different tools can implement it.
* **Open storage** — data is stored as files in your cloud storage, rather than only inside a proprietary database. The exact files and metadata depend on the format.
* **Open ecosystem** — multiple engines can work with the same table when they support that format and its features. Examples include Microsoft Fabric, Spark, Databricks, Snowflake, Trino, Flink, DuckDB, Dremio, and Athena; support varies by format and operation.
* **Shared table metadata** — compatible tools can interpret information such as schemas, snapshots, and the files that make up a table.

“Open” improves portability and reduces dependence on one engine, but it does not guarantee that every tool supports every feature or that switching platforms requires no work.

---

### 🔹 Why is it called a “Table” Format?

A basic data lake may contain a set of files:

```text
sales/
├── sales_1.parquet
├── sales_2.parquet
└── sales_3.parquet
```

By themselves, the files do not reliably tell an engine which files form the current table, what the current schema is, or how updates and deletes should be interpreted.

An open table format adds metadata to manage those files. Conceptually, a table may include:

```text
sales/
├── data/       # data files, often Parquet
└── metadata/   # format-specific table metadata and history
```

The layout and metadata structures differ between Delta Lake, Iceberg, and Hudi. Together, they define a logical table and its current state.

---

### 🔹 What problems do Open Table Formats solve?

| Data lake challenge | What the table format provides |
|---|---|
| Concurrent writes | Transaction handling to help prevent conflicting or partial table updates |
| Schema changes | Schema evolution, subject to format and engine support |
| Data updates and deletes | Supported update and delete operations, with implementation details varying by format |
| Historical queries | Snapshots or table history for querying earlier states (time travel) |
| Large numbers of files | Metadata that helps engines identify relevant table files without relying only on file listing |
| Multiple analytics engines | A shared table definition that compatible engines can read and, where supported, write |

---

### 🔹 Tools Mapping

* **Microsoft Fabric** → Delta Lake is the native Lakehouse table format; Iceberg tables can also be accessed in supported scenarios.
* **Databricks** → Delta Lake, with support for Apache Iceberg in supported workloads.
* **Snowflake** → Apache Iceberg support.
* **Apache Spark** → Delta Lake, Iceberg, and Hudi through the appropriate integrations.
* **Apache Flink** → Iceberg and Hudi through supported connectors.

Always check the product and engine documentation for the specific format features and read/write operations available in your environment.

---

### 🔹 Summary

> **Delta Lake** = a widely adopted choice, especially in Spark and Fabric ecosystems  
> **Iceberg** = broad, multi-engine table interoperability  
> **Hudi** = incremental processing and frequent data changes

Open table formats add a **metadata and transaction layer** to files in a data lake. They help make lakehouse data more reliable, manageable, and accessible to compatible analytics engines.

✔ A key building block of modern **Lakehouse architecture**

<img width="397" height="276" alt="image" src="https://github.com/user-attachments/assets/8776dec3-c5e9-42d2-bde3-3131f2bd4451" />
