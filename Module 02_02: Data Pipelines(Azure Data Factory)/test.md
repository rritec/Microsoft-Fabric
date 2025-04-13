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
# Json
``` json
{
    "name": "Get Excel Number of Sheets Dynamically and load it",
    "objectId": "7adb903d-4abe-44b7-a232-6721bc6ab657",
    "properties": {
        "activities": [
            {
                "name": "ForEach1",
                "type": "ForEach",
                "dependsOn": [
                    {
                        "activity": "setVariableRangeOfIndexes",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "typeProperties": {
                    "items": {
                        "value": "@variables('range_of_page_numbers')",
                        "type": "Expression"
                    },
                    "isSequential": true,
                    "activities": [
                        {
                            "name": "Copy data1",
                            "type": "Copy",
                            "dependsOn": [],
                            "policy": {
                                "timeout": "0.12:00:00",
                                "retry": 0,
                                "retryIntervalInSeconds": 30,
                                "secureOutput": false,
                                "secureInput": false
                            },
                            "typeProperties": {
                                "source": {
                                    "type": "ExcelSource",
                                    "storeSettings": {
                                        "type": "LakehouseReadSettings",
                                        "recursive": true,
                                        "enablePartitionDiscovery": false
                                    },
                                    "datasetSettings": {
                                        "annotations": [],
                                        "linkedService": {
                                            "name": "rr_batch100",
                                            "properties": {
                                                "annotations": [],
                                                "type": "Lakehouse",
                                                "typeProperties": {
                                                    "workspaceId": "55732739-60eb-445b-94c4-65725b7190fa",
                                                    "artifactId": "dd9dd813-0f22-446d-9621-dfd670945ea5",
                                                    "rootFolder": "Files"
                                                }
                                            }
                                        },
                                        "type": "Excel",
                                        "typeProperties": {
                                            "location": {
                                                "type": "LakehouseLocation",
                                                "fileName": "Load_multiple_sheets_of_excel.xlsx",
                                                "folderPath": "rawdata"
                                            },
                                            "sheetIndex": {
                                                "value": "@item()",
                                                "type": "Expression"
                                            },
                                            "firstRowAsHeader": true
                                        },
                                        "schema": []
                                    }
                                },
                                "sink": {
                                    "type": "LakehouseTableSink",
                                    "tableActionOption": "Append",
                                    "datasetSettings": {
                                        "annotations": [],
                                        "linkedService": {
                                            "name": "rr_batch100",
                                            "properties": {
                                                "annotations": [],
                                                "type": "Lakehouse",
                                                "typeProperties": {
                                                    "workspaceId": "55732739-60eb-445b-94c4-65725b7190fa",
                                                    "artifactId": "dd9dd813-0f22-446d-9621-dfd670945ea5",
                                                    "rootFolder": "Tables"
                                                }
                                            }
                                        },
                                        "type": "LakehouseTable",
                                        "schema": [],
                                        "typeProperties": {
                                            "table": "emp202504111"
                                        }
                                    }
                                },
                                "enableStaging": false,
                                "translator": {
                                    "type": "TabularTranslator",
                                    "typeConversion": true,
                                    "typeConversionSettings": {
                                        "allowDataTruncation": true,
                                        "treatBooleanAsNumber": false
                                    }
                                }
                            }
                        }
                    ]
                }
            },
            {
                "name": "getMetadataOfWrongIndexNumber",
                "type": "GetMetadata",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "fieldList": [
                        "structure"
                    ],
                    "datasetSettings": {
                        "annotations": [],
                        "linkedService": {
                            "name": "rr_batch100",
                            "properties": {
                                "annotations": [],
                                "type": "Lakehouse",
                                "typeProperties": {
                                    "workspaceId": "55732739-60eb-445b-94c4-65725b7190fa",
                                    "artifactId": "dd9dd813-0f22-446d-9621-dfd670945ea5",
                                    "rootFolder": "Files"
                                }
                            }
                        },
                        "type": "Excel",
                        "typeProperties": {
                            "location": {
                                "type": "LakehouseLocation",
                                "fileName": "Load_multiple_sheets_of_excel.xlsx",
                                "folderPath": "rawdata"
                            },
                            "sheetIndex": 999,
                            "firstRowAsHeader": true
                        },
                        "schema": []
                    },
                    "storeSettings": {
                        "type": "LakehouseReadSettings",
                        "enablePartitionDiscovery": false
                    }
                }
            },
            {
                "name": "setVariableGetError",
                "type": "SetVariable",
                "dependsOn": [
                    {
                        "activity": "getMetadataOfWrongIndexNumber",
                        "dependencyConditions": [
                            "Failed"
                        ]
                    }
                ],
                "policy": {
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "variableName": "GetError",
                    "value": {
                        "value": "@split(activity('getMetadataOfWrongIndexNumber').error.message,'(')[2]",
                        "type": "Expression"
                    }
                }
            },
            {
                "name": "setVariableRangeOfIndexes",
                "type": "SetVariable",
                "dependsOn": [
                    {
                        "activity": "setVariableGetError",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "variableName": "range_of_page_numbers",
                    "value": {
                        "value": "@range(\n        0,\n        add(\n            int(\n                substring(\n                    variables('GetError'),\n                    3,\n                    sub(\n                        length(\n                            variables('GetError')\n                        ),\n                        4\n                    )\n                )\n            )\n            ,1\n        )\n    \n    )",
                        "type": "Expression"
                    }
                }
            }
        ],
        "variables": {
            "GetError": {
                "type": "String"
            },
            "range_of_page_numbers": {
                "type": "Array"
            }
        },
        "lastModifiedByObjectId": "07dffa9c-d10a-43aa-a4dc-89568542f3c3",
        "lastPublishTime": "2025-04-13T00:27:01Z"
    }
}
