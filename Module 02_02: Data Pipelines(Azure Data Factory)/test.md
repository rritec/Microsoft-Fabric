# Microsoft Fabric Data Pipeline: Load Multiple Excel Sheets

This pipeline demonstrates how to load data from **multiple Excel sheets** stored in a Lakehouse and append the content into a single destination **Lakehouse table**.

## 📌 Pipeline Overview

- **Pipeline Name:** `pipeline5`
- **Purpose:** Iterates over a list of Excel sheet names and loads each into a target Lakehouse table using a `ForEach` activity and a `Copy` activity.
- **Parameter:** `pSheets` – list of Excel sheet names to be processed.

---

## 🧩 Parameters

| Name     | Type  | Default Values             |
|----------|-------|----------------------------|
| pSheets  | Array | `["CA", "Texas", "Seattle"]` |

---

## 🔁 ForEach Activity

### Name: `ForEach1`
- **Execution:** Sequential (`isSequential: true`)
- **Items Source:** `@pipeline().parameters.pSheets`

Each item represents an Excel sheet name that will be passed into the `Copy data1` activity.

---

## 📥 Copy Activity

### Name: `Copy data1`

#### 🔹 Source Configuration

- **Type:** `ExcelSource`
- **File Location:**
  - **Lakehouse Path:** `rawdata/Load_multiple_sheets_of_excel.xlsx`
  - **Lakehouse:** `rr_batch100`
- **Sheet Name:** `@item()` (driven by the `ForEach` loop)
- **Read Settings:**
  - `recursive: true`
  - `firstRowAsHeader: true`

#### 🔸 Sink Configuration

- **Type:** `LakehouseTableSink`
- **Target Table:** `test202504111`
- **Write Mode:** `Append`
- **Partition Option:** `None`
- **Lakehouse Path:** `Tables`
- **Lakehouse:** `rr_batch100`

#### 🔄 Translator Configuration

- **Type:** `TabularTranslator`
- **Settings:**
  - `typeConversion: true`
  - `allowDataTruncation: true`
  - `treatBooleanAsNumber: false`

---

## 🧠 Summary

This pipeline enables efficient loading of multiple sheets from a single Excel file located in a Lakehouse and appends the data into a unified Lakehouse table. It uses a parameterized and modular approach for extensibility and reusability.

---

## 🏗️ JSON Reference

<details>
<summary>Click to expand the original JSON</summary>

```json
<Insert your JSON here if needed for reference>
