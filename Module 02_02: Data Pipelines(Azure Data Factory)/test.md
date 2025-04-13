# Step-by-Step Guide to Execute Pipeline `pipeline5`

## Overview
This guide provides instructions for setting up and running the pipeline `pipeline5`, which extracts data from multiple Excel sheets and appends it into a Lakehouse table.

---

## Prerequisites
1. Access to **Azure Data Factory** or **Synapse Studio**.
2. Ensure the following are configured:
   - Linked Service: `rr_batch100` with workspace ID `55732739-60eb-445b-94c4-65725b7190fa`.
   - File location: `rawdata/Load_multiple_sheets_of_excel.xlsx`.
   - Target table: `test202504111`.
3. Permissions to access the workspace and Lakehouse artifacts.

---

## Steps to Follow

### 1. **Create Pipeline Parameters**
- Open the pipeline editor.
- Define the parameter `pSheets` as follows:
  ```json
  {
    "name": "pSheets",
    "type": "array",
    "defaultValue": ["CA", "Texas", "Seattle"]
  }

  3. Configure the Copy Data Activity
Within ForEach1, add a Copy Data Activity named Copy data1:
Source Settings
- Type: ExcelSource
- File Location:- File: Load_multiple_sheets_of_excel.xlsx.
- Folder: rawdata.

- Sheet Name: Use the expression:@item()

- Enable the First Row as Header option.


