# Microsoft Fabric – Roles & Responsibilities Overview

> A structured guide covering the four key roles in Microsoft Fabric: Data Engineer, Data Analyst, Data Scientist, and AI Engineer.

---

# 🏗️ Data Engineer Role

The Data Engineer is responsible for building and managing the data infrastructure — from storage design to ingestion pipelines and transformations.

---

## 01. Where to Store Analytical Data?

Microsoft Fabric provides multiple analytical storage options depending on the use case, query pattern, and data type.

| Store | Best For |
|---|---|
| **Lakehouse** | Large-scale raw & curated data, Delta/Parquet format, unified SQL + Spark access |
| **EventHouse (KQL)** | High-velocity streaming/event data, time-series analysis, real-time telemetry |
| **Warehouse** | Structured, enterprise-grade SQL workloads, T-SQL queries, BI-ready data marts |
| **SQL Database** | Transactional + analytical hybrid (HTAP), operational data with ACID compliance |
| **...etc** | Other stores like Azure Data Explorer, external lakehouses via shortcuts |

### Key Decision Criteria
- **Volume & velocity** → EventHouse for real-time, Lakehouse for batch/large scale
- **Query type** → T-SQL heavy? Use Warehouse. Python/Spark? Use Lakehouse.
- **Latency requirements** → Near real-time = EventHouse, batch = Lakehouse/Warehouse

---

## 02. How to Get Source / Transactional Data into Fabric? (Ingestion)

**Ingestion** is the process of moving data from source systems (databases, APIs, files, streams) into Fabric storage.

### 1. Copy Job
- Lightweight, no-code data movement tool
- Ideal for **one-time or scheduled bulk copies** from sources like Azure SQL, Blob Storage, REST APIs
- Supports incremental copy patterns
- Low latency, minimal configuration required
- Best for: simple source → destination copies without complex transformation logic

### 2. Pipeline (Data Factory in Fabric)
- Orchestration-based ingestion using **Azure Data Factory (ADF) experience** inside Fabric
- Supports **100+ connectors** (SAP, Salesforce, Oracle, REST, etc.)
- Can chain activities: Copy → Notebook → Stored Procedure → Notification
- Supports **parameterization, error handling, loops, and conditions**
- Best for: complex, multi-step ingestion workflows with dependencies

> 💡 **Rule of thumb:** Use Copy Job for simplicity, use Pipeline when you need orchestration logic around the copy.

---

## 03. How to Do Transformations?

Transformations shape, clean, enrich, and restructure data after ingestion.

### 1. Dataflow Gen2 — Lightweight Transformations
- **Language:** M (Power Query language)
- Visual, low-code transformation experience (drag & drop)
- Ideal for: column renaming, filtering, type casting, joins, aggregations
- Output destinations: Lakehouse, Warehouse, SQL Database
- Best for: **business analysts and data engineers** who prefer a visual ETL experience
- Limitation: not suitable for very large datasets or complex ML feature engineering

### 2. Notebook (PySpark) — Deep Level Transformations
- **Language:** Python / PySpark (distributed computing on Apache Spark)
- Full programmatic control over data transformation logic
- Handles: complex business logic, ML feature engineering, large-scale data processing
- Can read/write Delta tables in Lakehouse directly
- Supports libraries: `pandas`, `scikit-learn`, `delta`, `mlflow`, etc.
- Best for: **data engineers and data scientists** dealing with complex or high-volume transformations

> 💡 **Rule of thumb:** Dataflow Gen2 for 80% of standard ETL. Notebooks for the remaining 20% that needs code-level control.

---

## 04. How to Schedule, Organize, and Create Workflows?

### 1. Data Pipeline (Azure Data Factory Experience)
- Native orchestration tool inside Fabric
- Schedule pipelines using **built-in triggers** (time-based, event-based)
- Chain multiple activities: Notebooks, Dataflows, Copy Jobs, stored procedures
- Monitor run history, set alerts, handle failures with retry logic
- Best for: **end-to-end ETL/ELT workflow orchestration**

### 2. Apache Airflow Jobs
- Open-source workflow orchestration framework, available natively in Fabric
- Define workflows as **DAGs (Directed Acyclic Graphs)** in Python
- Better suited for **complex dependency management**, dynamic workflows, and teams already using Airflow
- Supports cross-platform orchestration (Fabric + external systems)
- Best for: **data engineering teams** who prefer code-first orchestration or have existing Airflow DAGs

> 💡 **Rule of thumb:** Use Data Pipeline for Fabric-native simplicity. Use Airflow for code-first, Python-defined, complex DAG orchestration.

---

# 📊 Data Analyst Role

The Data Analyst presents data to derive business insights and support decision-making.

---

## 05. Consuming & Presenting Data

### 1. Power BI
- The primary **business intelligence and reporting tool** in Microsoft Fabric
- Build interactive dashboards, reports, and semantic models
- **DirectLake mode** — query Lakehouse Delta tables at speed without data import
- Supports: DAX measures, row-level security (RLS), paginated reports
- Publish to workspaces, apps, and embed in portals
- Best for: **self-service BI, executive dashboards, operational reporting**

### 2. KQL Dashboards
- Built on top of **EventHouse (Kusto Query Language)**
- Real-time dashboards for streaming/event data
- Auto-refresh capability for live operational monitoring
- Best for: **real-time telemetry, log analytics, IoT data visualization**

---

# 🔍 06. Observability Dashboard

Observability in Microsoft Fabric helps monitor the health, performance, and cost of your data platform.

### 1. Reports Observability
- Track report usage: who is viewing, how often, which visuals are used
- Identify stale or unused reports
- Helps with governance and cleanup

### 2. Datasets Observability
- Monitor semantic model (dataset) refresh history, failures, and durations
- Track dataset size growth and query performance
- Helps identify bottlenecks in data refresh pipelines

### 3. Cost Monitor
- Track **Fabric Capacity Unit (CU) consumption** across workloads
- Identify which workspaces, pipelines, or notebooks are consuming the most capacity
- Helps in **capacity planning and cost optimization**

---

# 🔬 Data Scientist Role

The Data Scientist uses Fabric's ML capabilities to build and operationalize machine learning models.

### 1. Experiments
- Track ML experiments using **MLflow integration** inside Fabric
- Log parameters, metrics, artifacts, and model versions
- Compare runs to identify the best-performing model
- Integrated with Notebooks for seamless logging

### 2. ML Models
- Register, version, and manage trained ML models in the Fabric Model Registry
- Deploy models for batch inference (via Notebooks/Pipelines) or real-time scoring
- Supports frameworks: `scikit-learn`, `XGBoost`, `LightGBM`, `PyTorch`, `TensorFlow`

---

# 🤖 AI Engineer Role

The AI Engineer builds intelligent, agentic solutions on top of Fabric's data and AI capabilities.

### 1. Data Agents
- AI agents that can **query and reason over structured data** (Lakehouse, Warehouse, KQL)
- Use natural language to interact with data — powered by LLMs + Fabric data context
- Enable business users to ask questions without writing SQL or DAX
- Built using **Fabric's AI skill / Data Agent features**

### 2. Operations Agent
- Agents focused on **automating operational tasks** within Fabric
- Can monitor pipeline health, trigger remediation workflows, send alerts
- Combines AI reasoning with Fabric APIs and orchestration tools
- Enables **AIOps** patterns for self-healing data pipelines

---

## 📌 Summary — Role to Tool Mapping

| Role | Key Tools in Fabric |
|---|---|
| **Data Engineer** | Lakehouse, Warehouse, EventHouse, Copy Job, Pipeline, Dataflow Gen2, Notebook, Airflow |
| **Data Analyst** | Power BI, KQL Dashboards, Observability Dashboard |
| **Data Scientist** | Experiments (MLflow), ML Model Registry, Notebooks |
| **AI Engineer** | Data Agents, Operations Agent, AI Skills |
