# Step-by-Step Guide: Creating a Data Pipeline in Microsoft Fabric


---

## Step 1: Access Microsoft Fabric
1. Log in to your Microsoft Fabric workspace.
2. Navigate to the **Data Pipelines** section.

---

## Step 2: Create a New Pipeline
1. Click on **New Pipeline**.
2. Give your pipeline a name, e.g., `Pipe_from_SqlDatabase_to_Lakehouse_deltaTable`.

---

## Step 3: Add Activities to the Pipeline
The pipeline consists of multiple activities. These are detailed below:

### 3.1 Get Metadata Activity
1. Add a **Get Metadata** activity to the pipeline.
2. Configure the following:
   - **Field List**: `exists`, `itemName`, `itemType`, `lastModified`, `size`, `contentMD5`.
   - **Dataset Settings**:
     - Type: `DelimitedText`
     - Linked Service: `Lakehouse`
     - Location: `LakehouseLocation`
       - File Name: `emp.csv`
       - Folder Path: `rawdata`
   - **Format Settings**: `DelimitedTextReadSettings`

---

### 3.2 If Condition Activity
1. Add an **If Condition** activity.
2. Set the condition expression to:

```
@activity('Get Metadata1').output.exists
```

3. Configure the True and False activities:
- **If True**: 
  - Add a **Copy Data** activity (details in Step 3.3).
- **If False**:
  - Add a **Set Variable** activity:
    - Variable Name: `Test`
    - Value: `"If condition false box executed"`

---

### 3.3 Copy Data Activity
1. Add a **Copy Data** activity under the **If True** condition.
2. Configure the following:
- **Source**:
  - Type: `FabricSqlDatabaseSource`
  - Query Timeout: `02:00:00`
  - Dataset: `FabricSqlDatabaseTable`
    - Schema: `dbo`
    - Table: `EMP`
- **Sink**:
  - Type: `LakehouseTableSink`
  - Table Action: `Append`
  - Dataset: `LakehouseTable`
    - Table Name: `emp20250411`

---

## Step 4: Define Pipeline Variables
1. Define a variable named `Test` of type `String`.

---

## Step 5: Review and Publish
1. Review the pipeline configuration to ensure all settings are correct.
2. Click **Publish** to deploy the pipeline.

---

## Additional Notes
- You can monitor the pipeline's execution and review logs for debugging.
- Use the JSON file as a reference for exact property settings.

---

Enjoy teaching your students about data pipelines in Microsoft Fabric! 🎉
