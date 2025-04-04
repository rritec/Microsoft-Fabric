# Microsoft Fabric - Module 1: Introduction to Microsoft Fabric

## **Overview of Microsoft Fabric**
- Microsoft **Fabric** is an enterprise-ready, **end-to-end analytics platform**.
- It unifies data movement, data processing, ingestion, transformation, real-time event routing, and report building.**(ADF + Synase + Data Science + PowerBI + OneLake)**
- It supports these capabilities with integrated services like Data Engineering, Data Factory, Data Science, Real-Time Intelligence, Data Warehouse, Lake House, and Databases.
- It integrates separate components into a cohesive stack.
- It centralizes data storage with **OneLake** and embeds **AI** capabilities, eliminating the need for manual integration.
- With Fabric, you can efficiently transform **raw data** into **actionable insights**

## **Microsoft Fabric Architecture**
- Unification with **SaaS** foundation
- Microsoft Fabric is built on a Software as a Service (SaaS) platform.
- It unifies new and existing components from Power BI, Azure Synapse Analytics, Azure Data Factory, and more into a single environment.

  ![Microsoft Fabric Architecture](https://github.com/user-attachments/assets/ddeb2da9-54aa-471d-8925-a51a2e37219d)

## OneLake
- OneLake, the OneDrive for data
- OneLake is a single, unified, logical data lake for your whole organization. Like OneDrive, OneLake comes automatically with every **Microsoft Fabric tenant** and is designed to be the **single place** for all your analytics data
- OneLake is built on top of Azure Data Lake Storage (ADLS) Gen2 and can support any type of file, structured or unstructured
- Refer [msft help](https://learn.microsoft.com/en-us/fabric/onelake/onelake-overview)
- [Download and Install OneLake Client](https://www.microsoft.com/en-us/download/details.aspx?id=105222)
## **Key Features and Capabilities**
- **OneLake**: A single storage layer for all data within Microsoft Fabric, eliminating data silos.
- **Lakehouse Architecture**: Combines the benefits of data lakes and data warehouses, allowing structured and unstructured data management.
- **Integrated AI and Analytics**: Built-in machine learning and analytics capabilities for data processing and insights generation.
- **Unified Security and Governance**: Provides role-based access controls, data compliance, and security enforcement across all data assets.

## **Fabric vs. Other Data Platforms**
- **Azure Synapse vs. Fabric**:
  - Synapse is more focused on data warehousing and big data analytics, while Fabric provides an **all-in-one** data solution.
- **Databricks vs. Fabric**:
  - Databricks is centered around big data and AI workloads, whereas Fabric integrates **BI, ML, AI and real-time analytics**.
- **Snowflake vs. Fabric**:
  - Snowflake provides a cloud-based data warehouse, while Fabric offers a **broader ecosystem** with integrated services.
- Fabric’s advantage lies in **end-to-end integration**, making it suitable for enterprises looking for a complete data solution.

## **Refer**
- [Refer microsoft-fabric-overview](https://learn.microsoft.com/en-us/fabric/fundamentals/microsoft-fabric-overview)

## Exercise 1: Get MSFT Login
1. Get any one personal mail id (Recommended Outlook mailid) https://signup.live.com/?lic=1

![image](https://github.com/user-attachments/assets/d0af6992-8e1e-4a8b-ab2c-2ebbc72f02e6)


2. Follow this link https://learn.microsoft.com/en-us/power-bi/enterprise/service-admin-signing-up-for-power-bi-with-a-new-office-365-trial
## Exercise 2: Create Workspace

1. Open your browser and navigate to https://app.fabric.microsoft.com.
2. Sign in with your Microsoft account that has Fabric access.
3. On the left navigation pane, click on **Workspaces**.
4. Click on ![image](https://github.com/user-attachments/assets/df3cf33e-c41d-431e-b253-9a130b2219ad)
5. Enter a Workspace name (e.g., **rritec_fabric_demo_Workspace**)
6. Click **Apply**

![image](https://github.com/user-attachments/assets/b7f4fb07-dcc7-4205-8198-fe219f285ecc)

7. Your new workspace is now available under the Workspaces section
   


---

