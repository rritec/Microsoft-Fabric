## 📁 Pipeline 2: Load Excel Sheets Dynamically to Lakehouse

### ✅ Use Case

When you **don't know the sheet names/count** in advance, this pipeline dynamically detects the number of sheets and loads all of them.

---

### 🧭 Navigation Steps

1. Go to **Microsoft Fabric > Data Engineering**
2. Create a new **Data Pipeline**
3. Rename it: `Dynamic_Excel_Sheet_Load_To_Lakehouse`
4. Add the following activities:
   - `GetMetadata` (for invalid sheet index)
   - `SetVariable` (capture error)
   - `SetVariable` (generate index array)
   - `ForEach` (loop through indexes and copy)

---

### 🧮 Variables

| Name                  | Type   | Description                             |
|-----------------------|--------|-----------------------------------------|
| `excelSheetErrorMessage` | String | Stores error from invalid sheet access  |
| `sheetIndexArray`        | Array  | Holds indexes like `[0, 1, 2, ..., n]`  |

---

### 🔹 Activity: `getMetadata_InvalidSheet`

- **Type**: `GetMetadata`
- **Purpose**: Access sheet index `999` to trigger an error.
- **Extracts**: Total number of sheets from error message.

---

### 🔹 Activity: `setExcelErrorMessage`

- **Type**: `SetVariable`
- **Expression**:
  ```expression
  @split(activity('getMetadata_InvalidSheet').error.message,'(')[2]
  ```

---

### 🔹 Activity: `generateSheetIndexArray`

- **Type**: `SetVariable`
- **Expression**:
  ```expression
  @range(
    0,
    add(
      int(
        substring(
          variables('excelSheetErrorMessage'),
          3,
          sub(
            length(variables('excelSheetErrorMessage')),
            4
          )
        )
      ),
      1
    )
  )
  ```

---

### 🔁 Activity: `loopThroughSheets`

- **Type**: `ForEach`
- **Items**: `@variables('sheetIndexArray')`
- **Inside Loop**: `copySheetDataToLakehouse`

---

### 🔹 Activity: `copySheetDataToLakehouse`

- **Type**: `Copy`
- **Source**:
  - **Sheet Index**: `@item()` (0-based)
- **Sink**:
  - **Table**: `emp202504111`
  - **Action**: `Append`

---
