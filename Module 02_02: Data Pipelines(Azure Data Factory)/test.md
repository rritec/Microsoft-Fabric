markdown
Copy
# Microsoft Fabric Data Pipeline: Employee Data Ingestion
**File Name**: `EmployeeData_Ingestion_Pipeline_Guide.md`  
**Pipeline Name**: `EmployeeData_Ingestion_Pipeline`  
**Last Updated**: April 2024  

---

## Table of Contents
1. [Pipeline Overview](#1-pipeline-overview)
2. [Step-by-Step Execution Flow](#2-step-by-step-execution-flow)
3. [Detailed Activity Breakdown](#3-detailed-activity-breakdown)
4. [Configuration Reference](#4-configuration-reference)
5. [Troubleshooting Guide](#5-troubleshooting-guide)
6. [Full Pipeline JSON](#6-full-pipeline-json)

---

## 1. Pipeline Overview
### Business Logic
- Processes employee data files from Lakehouse
- Handles both CSV and JSON formats
- Routes data to appropriate SQL tables
- Auto-creates destination tables if missing

# Microsoft Fabric Data Pipeline: Employee Data Ingestion
**File Name**: `EmployeeData_Ingestion_Pipeline_Guide.md`  
**Pipeline Name**: `EmployeeData_Ingestion_Pipeline`  
**Last Updated**: April 2024  

---

## Table of Contents
1. [Pipeline Overview](#1-pipeline-overview)
2. [Step-by-Step Execution Flow](#2-step-by-step-execution-flow)
3. [Detailed Activity Breakdown](#3-detailed-activity-breakdown)
4. [Configuration Reference](#4-configuration-reference)
5. [Troubleshooting Guide](#5-troubleshooting-guide)
6. [Full Pipeline JSON](#6-full-pipeline-json)

---

## 1. Pipeline Overview

### Business Logic
- Processes employee data files from Lakehouse
- Handles both CSV and JSON formats
- Routes data to appropriate SQL tables
- Auto-creates destination tables if missing

### Technical Architecture
```mermaid
graph TD
    A[Start Pipeline] --> B{ForEach File}
    B -->|emp.csv| C[Transform CSV]
    B -->|emp.json| D[Transform JSON]
    C --> E[Load to dbo.switchempcsv]
    D --> F[Load to switchempjson]


### Technical Architecture
```mermaid
graph TD
  A[Start Pipeline] --> B{ForEach File}
  B -->|emp.csv| C[Transform CSV]
  B -->|emp.json| D[Transform JSON]
  C --> E[Load to dbo.switchempcsv]
  D --> F[Load to switchempjson]
2. Step-by-Step Execution Flow
Phase 1: Initialization
Parameter Validation

Checks pInputFiles array (default: ["emp.csv","emp.json"])

Validates Lakehouse and SQL DB connections

Phase 2: File Processing Loop
mermaid
Copy
sequenceDiagram
  loop ForEach File
    Pipeline->>ForEach: Get next file
    ForEach->>Switch: Route by extension
    alt CSV File
      Switch->>Copy: CSV Transformation
    else JSON File
      Switch->>Copy: JSON Transformation
    end
  end
3. Detailed Activity Breakdown
3.1 IterateOverFiles (ForEach)
Property	Value	Description
Items	@pipeline().parameters.pInputFiles	Dynamic file list
Sequential	true	Ordered processing
Batch Size	1	Processes files individually
Child Activities:

RouteFileByExtension (Switch)

Copy_CSV_To_SQL (Copy)

Copy_JSON_To_SQL (Copy)

3.2 CSV Processing Path
Source Configuration
json
Copy
"location": {
  "type": "LakehouseLocation",
  "fileName": "emp.csv",
  "folderPath": "rawdata"
}
Format: Delimited text (CSV)

Settings:

Column delimiter: ,

First row as header: true

Escape character: \

Sink Configuration
json
Copy
"table": "dbo.switchempcsv",
"autoCreate": true,
"writeBehavior": "insert"
3.3 JSON Processing Path
Special Handling
json
Copy
"columnFlattenSettings": {
  "flattenColumnDelimiter": "."
}
Nested JSON fields flattened using dot notation

Example: {"user":{"name":"John"}} → user.name

4. Configuration Reference
Linked Services
Name	Type	Key Identifiers
rr_batch100	Lakehouse	WorkspaceID: 55732739-...
ArtifactID: dd9dd813-...
rritec	FabricSQL	ConnectionID: cb146f64-...
Performance Settings
Activity	Timeout	Retry Policy
Copy_CSV_To_SQL	12 hours	0 retries
Copy_JSON_To_SQL	12 hours	0 retries
5. Troubleshooting Guide
Common Errors
Error	Solution
FileNotFound	Verify rawdata folder exists in Lakehouse
SchemaMismatch	Check column mappings in TabularTranslator
PermissionDenied	Validate Linked Service credentials
Debugging Tips
Test Connections First

Validate Lakehouse and SQL DB connections

Isolate Activities

Run Switch cases independently

Monitor Runs

Check execution details in Monitoring Hub

6. Full Pipeline JSON
json
Copy
{
    "name": "EmployeeData_Ingestion_Pipeline\t",
    "objectId": "13992b28-105b-4374-86d0-c5aeb91a33e0",
    "properties": {
        "activities": [
            {
                "name": "IterateOverFiles",
                "type": "ForEach",
                "dependsOn": [],
                "typeProperties": {
                    "items": {
                        "value": "@pipeline().parameters.pInputFiles",
                        "type": "Expression"
                    },
                    "isSequential": true,
                    "activities": [
                        {
                            "name": "RouteFileByExtension",
                            "type": "Switch",
                            "dependsOn": [],
                            "typeProperties": {
                                "on": {
                                    "value": "@item()",
                                    "type": "Expression"
                                },
                                "cases": [
                                    {
                                        "value": "emp.csv",
                                        "activities": [
                                            {
                                                "name": "Copy_CSV_To_SQL",
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
                                                        "type": "DelimitedTextSource",
                                                        "storeSettings": {
                                                            "type": "LakehouseReadSettings",
                                                            "recursive": true,
                                                            "enablePartitionDiscovery": false
                                                        },
                                                        "formatSettings": {
                                                            "type": "DelimitedTextReadSettings"
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
                                                            "type": "DelimitedText",
                                                            "typeProperties": {
                                                                "location": {
                                                                    "type": "LakehouseLocation",
                                                                    "fileName": "emp.csv",
                                                                    "folderPath": "rawdata"
                                                                },
                                                                "columnDelimiter": ",",
                                                                "escapeChar": "\\",
                                                                "firstRowAsHeader": true,
                                                                "quoteChar": "\""
                                                            },
                                                            "schema": []
                                                        }
                                                    },
                                                    "sink": {
                                                        "type": "FabricSqlDatabaseSink",
                                                        "writeBehavior": "insert",
                                                        "sqlWriterUseTableLock": false,
                                                        "tableOption": "autoCreate",
                                                        "datasetSettings": {
                                                            "annotations": [],
                                                            "connectionSettings": {
                                                                "name": "rritec",
                                                                "properties": {
                                                                    "annotations": [],
                                                                    "type": "FabricSqlDatabase",
                                                                    "typeProperties": {
                                                                        "workspaceId": "55732739-60eb-445b-94c4-65725b7190fa",
                                                                        "artifactId": "31237005-4d13-4afe-8ff3-42834149ecd7"
                                                                    },
                                                                    "externalReferences": {
                                                                        "connection": "cb146f64-f5ee-47c5-9a70-8bada1b07ac1"
                                                                    }
                                                                }
                                                            },
                                                            "type": "FabricSqlDatabaseTable",
                                                            "schema": [],
                                                            "typeProperties": {
                                                                "schema": "dbo",
                                                                "table": "switchempcsv"
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
                                    },
                                    {
                                        "value": "emp.json",
                                        "activities": [
                                            {
                                                "name": "Copy_JSON_To_SQL",
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
                                                        "type": "JsonSource",
                                                        "storeSettings": {
                                                            "type": "LakehouseReadSettings",
                                                            "recursive": true,
                                                            "enablePartitionDiscovery": false
                                                        },
                                                        "formatSettings": {
                                                            "type": "JsonReadSettings"
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
                                                            "type": "Json",
                                                            "typeProperties": {
                                                                "location": {
                                                                    "type": "LakehouseLocation",
                                                                    "fileName": "emp.json",
                                                                    "folderPath": "rawdata"
                                                                }
                                                            },
                                                            "schema": {}
                                                        }
                                                    },
                                                    "sink": {
                                                        "type": "FabricSqlDatabaseSink",
                                                        "writeBehavior": "insert",
                                                        "sqlWriterUseTableLock": false,
                                                        "tableOption": "autoCreate",
                                                        "datasetSettings": {
                                                            "annotations": [],
                                                            "connectionSettings": {
                                                                "name": "rritec",
                                                                "properties": {
                                                                    "annotations": [],
                                                                    "type": "FabricSqlDatabase",
                                                                    "typeProperties": {
                                                                        "workspaceId": "55732739-60eb-445b-94c4-65725b7190fa",
                                                                        "artifactId": "31237005-4d13-4afe-8ff3-42834149ecd7"
                                                                    },
                                                                    "externalReferences": {
                                                                        "connection": "cb146f64-f5ee-47c5-9a70-8bada1b07ac1"
                                                                    }
                                                                }
                                                            },
                                                            "type": "FabricSqlDatabaseTable",
                                                            "schema": [],
                                                            "typeProperties": {
                                                                "table": "switchempjson"
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
                                                        },
                                                        "columnFlattenSettings": {
                                                            "treatArrayAsString": false,
                                                            "treatStructAsString": false,
                                                            "flattenColumnDelimiter": "."
                                                        }
                                                    }
                                                }
                                            }
                                        ]
                                    }
                                ],
                                "defaultActivities": []
                            }
                        }
                    ]
                }
            }
        ],
        "parameters": {
            "pInputFiles": {
                "type": "array",
                "defaultValue": [
                    "emp.csv",
                    "emp.json"
                ]
            }
        },
        "lastModifiedByObjectId": "07dffa9c-d10a-43aa-a4dc-89568542f3c3",
        "lastPublishTime": "2025-04-13T16:52:43Z"
    }
}
Download this guide as markdown file (Right-click → Save link as)

Key Features:
Visual Workflows: Mermaid diagrams for architecture and sequence flows

Configuration Tables: Quick-reference for key settings

Troubleshooting Matrix: Common errors with solutions

Complete JSON: Full pipeline definition for reference

To use:

Copy this entire document

Save as .md file

Add real screenshots by replacing diagram placeholders
