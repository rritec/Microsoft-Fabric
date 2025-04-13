# 📊 Microsoft Fabric Data Pipeline: Dynamic Excel Sheet Load to Lakehouse

This pipeline dynamically determines the **number of sheets** in an Excel file and loads each sheet's data into a **Lakehouse table**. It uses metadata retrieval and a smart use of variables to build the loop range at runtime.

---

## 🧭 Navigation Steps in Microsoft Fabric

1. **Open Microsoft Fabric Workspace** where your Lakehouse resides.
2. In the left pane, go to **Data Factory**.
3. Click **+ New pipeline** to create a new pipeline.
4. Rename the pipeline to `Dynamic_Excel_Sheet_Load_To_Lakehouse`.
5. Add two **pipeline variables**:
   - `GetError` (String)
   - `range_of_page_numbers` (Array)

---

## 🔁 Step-by-Step Activity Configuration

### 1. 🧾 `GetMetadata` – `getMetadataOfWrongIndexNumber`
- **Purpose:** Trigger an error by accessing a non-existent Excel sheet index (e.g., 999) to extract the number of actual sheets from the error message.
- **Field List:** `structure`
- **Excel File Path:** `rawdata/Load_multiple_sheets_of_excel.xlsx`
- **Linked Service:** `rr_batch100`
- **Sheet Index:** `999`
- **First Row as Header:** True

---

### 2. 🪪 `SetVariable` – `setVariableGetError`
- **Triggered When:** `getMetadataOfWrongIndexNumber` **Fails**
- **Variable Name:** `GetError`
- **Value:**
    ```json
    @split(activity('getMetadataOfWrongIndexNumber').error.message,'(')[2]
    ```

---

### 3. 🧮 `SetVariable` – `setVariableRangeOfIndexes`
- **Triggered When:** `setVariableGetError` **Succeeds**
- **Variable Name:** `range_of_page_numbers`
- **Value (Expression to calculate sheet indexes):**
    ```json
    @range(
        0,
        add(
            int(
                substring(
                    variables('GetError'),
                    3,
                    sub(
                        length(variables('GetError')),
                        4
                    )
                )
            ),
            1
        )
    )
    ```

---

### 4. 🔄 `ForEach` – `ForEach1`
- **Triggered When:** `setVariableRangeOfIndexes` **Succeeds**
- **Items:** `@variables('range_of_page_numbers')`
- **Execution Mode:** Sequential

#### ⬇️ Inside `ForEach`: `Copy data1`

- **Source:**
  - Type: Excel
  - Sheet Index: `@item()`
  - File: `rawdata/Load_multiple_sheets_of_excel.xlsx`
  - Linked Service: `rr_batch100`
  - First Row as Header: True

- **Sink:**
  - Type: Lakehouse Table
  - Table: `emp202504111`
  - Mode: Append
  - Linked Service: `rr_batch100`

- **Translator:**
  - Type: TabularTranslator
  - Type Conversion: Enabled
  - Allow Data Truncation: True
  - Treat Boolean as Number: False

---

## 📂 Variable Configuration

| Variable Name         | Type   | Purpose                                    |
|-----------------------|--------|--------------------------------------------|
| `GetError`            | String | Holds error message containing sheet count |
| `range_of_page_numbers` | Array | Holds dynamically generated sheet indexes  |

---

## ✅ Summary

This pipeline provides a **dynamic and automated** approach to:
- Detect number of sheets in an Excel file.
- Loop through each sheet **by index**.
