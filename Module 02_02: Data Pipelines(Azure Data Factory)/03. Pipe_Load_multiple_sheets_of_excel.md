# 🚀 Microsoft Fabric Data Pipeline: Load Multiple Excel Sheets to Lakehouse

This document explains how to create a Data Pipeline in **Microsoft Fabric** that loads data from **multiple Excel sheets** into a Lakehouse table using a `ForEach` activity and a `Copy` activity.

---

## 🧭 Navigation Steps in Microsoft Fabric

Follow these steps to implement this pipeline in Microsoft Fabric:

1. **Go to the Microsoft Fabric workspace** where your Lakehouse is located.
2. Upload file into Lakehouse rawdata folder Load_multiple_sheets_of_excel.xlsx
3. Click **+ New Item** > **Data Pipeline** to create a new pipeline.
4. **Rename the pipeline** to `Load_Multiple_Excel_Sheets_To_Lakehouse`.
5. Define a pipeline **parameter** named `pSheets`:
    ```json
    ["CA", "Texas", "Seattle"]
    ```

6. From the **Activities** pane, drag the `ForEach` activity onto the canvas.
7. Click on the `ForEach` activity and configure it:
   - Set **Items** to `@pipeline().parameters.pSheets`
   - Enable **IsSequential**
8. Inside the `ForEach`, add a `Copy data` activity.
9. Configure the **Source**:
   - **Source Type:** Excel
   - **Linked Service:** Your Lakehouse (e.g., `rr_batch100`)
   - **File Name:** `Load_multiple_sheets_of_excel.xlsx`
   - **Folder Path:** `rawdata`
   - **Sheet Name:** `@item()` (from the loop)
   - **First Row as Header:** True
10. Configure the **Sink**:
   - **Sink Type:** Lakehouse Table
   - **Table Name:** `test202504111`
   - **Write Behavior:** Append
   - **Lakehouse Path:** `Tables`
   - **Linked Service:** `rr_batch100`
11. Set the **Translator** to `TabularTranslator` and enable:
    - Type conversion
    - Allow data truncation

12. Click **Publish** to save the pipeline.

---

## 📌 Pipeline Overview

- **Pipeline Name:** `Load_Multiple_Excel_Sheets_To_Lakehouse`
- **Purpose:** Load data from each Excel sheet in a list and append into one Lakehouse table.
- **Parameter Used:** `pSheets` (array of sheet names)

---

## 🧩 Parameter Details

| Parameter | Type  | Default Value                 |
|-----------|-------|-------------------------------|
| pSheets   | Array | `["CA", "Texas", "Seattle"]`  |

---

## 🔁 ForEach Activity

### Name: `ForEach1`
- **Execution Mode:** Sequential
- **Iterates Over:** `@pipeline().parameters.pSheets`

---

## 📥 Copy Activity

### Name: `Copy data1`

#### 🔹 Source Settings
- **Source Type:** Excel
- **Lakehouse Path:** `rawdata/Load_multiple_sheets_of_excel.xlsx`
- **Lakehouse Linked Service:** `rr_batch100`
- **Sheet Name:** `@item()` (from ForEach loop)
- **Read Options:**
  - Recursive: True
  - First Row as Header: True

#### 🔸 Sink Settings
- **Sink Type:** Lakehouse Table
- **Target Table:** `test202504111`
- **Mode:** Append
- **Lakehouse Path:** `Tables`
- **Linked Service:** `rr_batch100`

#### 🔄 Translator
- **Type:** TabularTranslator
- **Type Conversion:** Enabled
- **Allow Data Truncation:** True
- **Treat Boolean as Number:** False

---

## ✅ Summary

This pipeline automates reading from multiple sheets within a single Excel file and appends them into one unified Lakehouse table using Microsoft Fabric's Data Factory.

---

## 🗂️ Full JSON Code (Optional)

<details>
<summary>Click to expand the JSON</summary>

```json
{
  "name": "Load_Multiple_Excel_Sheets_To_Lakehouse",
  ...
}
