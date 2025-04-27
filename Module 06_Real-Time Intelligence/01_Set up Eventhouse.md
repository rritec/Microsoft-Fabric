# 📚 Eventhouse Overview (Microsoft Fabric)

## What is Eventhouse?
- A **scalable solution** for handling **large volumes of real-time data**.
- Built for **efficient ingestion, processing, and analysis** of **streaming** and **event-based data**.
- Best suited for **time-sensitive insights** like **telemetry, IoT, logs, security events**, and **financial records**.
- Preferred for **semi-structured** and **free text** data analysis.
- Works as a **workspace of databases**, sharing resources to optimize **performance** and **cost**.

---

## Key Features
- **Unified Management**: Monitor and manage all databases together.
- **Real-Time Indexing**: Data automatically indexed and partitioned based on **ingestion time**.
- **Multi-source Data**: Supports ingestion from Eventstream, SDKs, Kafka, Logstash, dataflows, and more.
- **Flexible Data Formats**: Handles structured, semi-structured, and unstructured data.

---

## When to Use Eventhouse?
- If your use case involves **event-based data** like:
  - Application telemetry
  - Time series and IoT streams
  - Security and compliance logs
  - Financial transactions and records

---

## Inside an Eventhouse
- **System Overview**: 
  - Eventhouse details
  - Storage usage
  - Compute resource usage
  - Ingestion rates
  - Top queried/ingested databases
- **Databases View**:
  - Database name and metadata
  - Activity Tracker
  - Tables and data previews
  - Query insights (Top 100 queries)

---

## Special Concept: Minimum Consumption
- To **optimize costs**, Eventhouse can **auto-suspend** when not active.
- For **always-on** needs (to avoid wake-up latency), you can enable **Minimum Consumption**.
- Different tiers available, for example:
  - Extra Small (8.5 CUs, 200GB SSD storage)
  - Medium (18 CUs, 3.5–4 TB SSD storage)
  - Extra Large (34 CUs, 7–8 TB SSD storage)
- Pay for the minimum compute or actual usage — whichever is higher.

---

## Important
- You create **KQL Databases** inside an Eventhouse (either standard databases or shortcuts).
- Data can also be made available via **OneLake** integration.

---

# 🎁 Summary
**Eventhouse = Modern, real-time, scalable event data platform**  
for Microsoft Fabric, replacing traditional Log Analytics workspaces!


# Create Eventhouse
1. Browse to the workspace in which you want to create your tutorial resources. You must create all resources in the same workspace.
2. Select + New item.
3. In the Filter by item type search box, enter Eventhouse.
4. Select the Eventhouse item.

![image](https://github.com/user-attachments/assets/37360f35-4107-4fcc-9725-e05494332cc4)

5. Enter **rritec_Eventhouse** as the eventhouse name. A KQL database is created simultaneously with the same name.

![image](https://github.com/user-attachments/assets/33f7b5cb-0f67-47e7-9060-e7d4014d4034)

6. Select Create. When provisioning is complete, the eventhouse System overview page is shown.

![image](https://github.com/user-attachments/assets/9d3e723a-d6a7-4e2a-83a5-786fcfcdec50)

7. 

# Reference:
https://learn.microsoft.com/en-us/fabric/real-time-intelligence/eventhouse
https://learn.microsoft.com/en-us/fabric/real-time-intelligence/tutorial-1-resources


