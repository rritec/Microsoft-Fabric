# Microsoft Fabric Course

![Course Badge](https://img.shields.io/badge/course-Microsoft%20Fabric-blue)

A practical collection of Microsoft Fabric tutorials, notebooks, data files, and examples. The course material is arranged in the repository's **existing module folders**. The outline below uses the actual folder and file names in this repository; 

## How the course is organized

Each `M...` folder is an existing course module or topic area. Open a folder to find its Markdown walkthroughs, notebooks, and supporting files. Folder and chapter names below are reproduced from the repository.

### Course modules and existing topics

#### [M01_Introduction to Microsoft Fabric](<M01_Introduction to Microsoft Fabric/>)

Introduction to Fabric concepts, plus a knowledge check and demo:

- [Module 01_00_Introduction to Microsoft Fabric.md](<M01_Introduction to Microsoft Fabric/Module 01_00_Introduction to Microsoft Fabric.md>)
- [Demo.md](<M01_Introduction to Microsoft Fabric/Demo.md>)
- [Module 01_01_Microsoft_Fabric_Intro_MCQs.md](<M01_Introduction to Microsoft Fabric/Module 01_01_Microsoft_Fabric_Intro_MCQs.md>)

#### [M02_00_LakeHouse](<M02_00_LakeHouse/>)

Lakehouse, Delta tables, table formats, and schema evolution:

- [00_Open Table Formats.md](<M02_00_LakeHouse/00_Open Table Formats.md>)
- [01_Lakehouse.md](<M02_00_LakeHouse/01_Lakehouse.md>)
- [02_Delta_table_ACID_operations.md](<M02_00_LakeHouse/02_Delta_table_ACID_operations.md>)
- [03_Time Travel.md](<M02_00_LakeHouse/03_Time Travel.md>)
- [04_Delta_table_Schema_Evolution.md](<M02_00_LakeHouse/04_Delta_table_Schema_Evolution.md>)
- [04nb_Schema evolution for Delta tables.ipynb](<M02_00_LakeHouse/04nb_Schema evolution for Delta tables.ipynb>)
- `Archive/` contains archived notebooks.

#### [M02_01_SQL Analytics Endpoint](<M02_01_SQL Analytics Endpoint/>)

Query and consume Lakehouse data using the SQL analytics endpoint:

- [Module 03_00_SQL analytics endpoint - SQL Query.md](<M02_01_SQL Analytics Endpoint/Module 03_00_SQL analytics endpoint - SQL Query.md>)
- [Module 03_01_SQL Analytics Endpoint - Visual Query Examples.md](<M02_01_SQL Analytics Endpoint/Module 03_01_SQL Analytics Endpoint - Visual Query Examples.md>)
- [Module 03_02_SQL Analytics Endpoint - Notebook.ipynb](<M02_01_SQL Analytics Endpoint/Module 03_02_SQL Analytics Endpoint - Notebook.ipynb>)
- [Module 03_04_SQL Analytics Endpoint - Report.md](<M02_01_SQL Analytics Endpoint/Module 03_04_SQL Analytics Endpoint - Report.md>)
- `archive/` contains an archived notebook.

#### [M02_02_Python and PySpark](<M02_02_Python and PySpark/>)

Python and PySpark examples, including custom modules and field encryption:

- [First_module.py](<M02_02_Python and PySpark/First_module.py>)
- [Import Custom Modules in Fabric.ipynb](<M02_02_Python and PySpark/Import Custom Modules in Fabric.ipynb>)
- [PySpark_Field_Encryption_decryption.ipynb](<M02_02_Python and PySpark/PySpark_Field_Encryption_decryption.ipynb>)
- [readme.md](<M02_02_Python and PySpark/readme.md>)

#### [M03_Data Pipelines(Azure Data Factory)](<M03_Data Pipelines(Azure Data Factory)/>)

Pipeline ingestion, orchestration, scheduling, control flow, and transformations:

- [01. Lakehouse_file_to_Lakehouse_Delta_Table_pipe.md](<M03_Data Pipelines(Azure Data Factory)/01. Lakehouse_file_to_Lakehouse_Delta_Table_pipe.md>)
    - additional columns
    - Lakehouse artifact connection
    - wildcard file path
    - list of files
    - Overwrite
    - Upsert
- [02. Pipe_from_SqlDatabase_to_Lakehouse_deltaTable.md](<M03_Data Pipelines(Azure Data Factory)/02. Pipe_from_SqlDatabase_to_Lakehouse_deltaTable.md>)
- [03. Pipe_Load_multiple_sheets_of_excel.md](<M03_Data Pipelines(Azure Data Factory)/03. Pipe_Load_multiple_sheets_of_excel.md>)
- [04. Pipe Load Excel Sheets Dynamically to Lakehouse.md](<M03_Data Pipelines(Azure Data Factory)/04. Pipe Load Excel Sheets Dynamically to Lakehouse.md>)
- [05. Pipe Export_EMP_to_Lakehouse_Pipeline.md](<M03_Data Pipelines(Azure Data Factory)/05. Pipe Export_EMP_to_Lakehouse_Pipeline.md>)
- [06. pipe_Load_file_if_available.md](<M03_Data Pipelines(Azure Data Factory)/06. pipe_Load_file_if_available.md>)
- [07. Pipe_Branch Files using Switch.md](<M03_Data Pipelines(Azure Data Factory)/07. Pipe_Branch Files using Switch.md>)
- [08. Pipe to Incrementally load data.md](<M03_Data Pipelines(Azure Data Factory)/08. Pipe to Incrementally load data.md>)
- [09. Pipe_Scheduling and Triggers.md](<M03_Data Pipelines(Azure Data Factory)/09. Pipe_Scheduling and Triggers.md>)
- [10. Pipe_Execute_Pipeline_Activity.md](<M03_Data Pipelines(Azure Data Factory)/10. Pipe_Execute_Pipeline_Activity.md>)
- [11. Pipe Load Data from API to lakehouse table.md](<M03_Data Pipelines(Azure Data Factory)/11. Pipe Load Data from API to lakehouse table.md>)
- [12. Pipe Mail or Teams Notifications.md](<M03_Data Pipelines(Azure Data Factory)/12. Pipe Mail or Teams Notifications.md>)
- [13. Pipe_Delete_outlook_Teams_Activity.md](<M03_Data Pipelines(Azure Data Factory)/13. Pipe_Delete_outlook_Teams_Activity.md>)
- [14. Pipe_Fail_Activity.md](<M03_Data Pipelines(Azure Data Factory)/14. Pipe_Fail_Activity.md>)
- [15. Pipe_Monitor File Arrival Using Until Loop.md](<M03_Data Pipelines(Azure Data Factory)/15. Pipe_Monitor File Arrival Using Until Loop.md>)
- [ADF17_Create Dataflow equal to sql query.md](<M03_Data Pipelines(Azure Data Factory)/ADF17_Create Dataflow equal to sql query.md>)
- [ADF18_Replicate DataFlows logic in copy activity.md](<M03_Data Pipelines(Azure Data Factory)/ADF18_Replicate DataFlows logic in copy activity.md>)
- [ADF19_Split Transformation.md](<M03_Data Pipelines(Azure Data Factory)/ADF19_Split Transformation.md>)
- [ADF21_UNION_transformation.md](<M03_Data Pipelines(Azure Data Factory)/ADF21_UNION_transformation.md>)
- [ADF22_Derived_Column_Transformation.md](<M03_Data Pipelines(Azure Data Factory)/ADF22_Derived_Column_Transformation.md>)
- [ADF24_1_Transformations in Stored Procedure.md](<M03_Data Pipelines(Azure Data Factory)/ADF24_1_Transformations in Stored Procedure.md>)
- [ADF24_2_Transformations in Stored Procedure.md](<M03_Data Pipelines(Azure Data Factory)/ADF24_2_Transformations in Stored Procedure.md>)
- [ADF25_00_Transformation_in_pyspark_notebook.ipynb](<M03_Data Pipelines(Azure Data Factory)/ADF25_00_Transformation_in_pyspark_notebook.ipynb>)
- [ADF25_01_Transformation_in_pyspark_notebook.md](<M03_Data Pipelines(Azure Data Factory)/ADF25_01_Transformation_in_pyspark_notebook.md>)
- Supporting files: [master_ingestion_pipeline.json](<M03_Data Pipelines(Azure Data Factory)/master_ingestion_pipeline.json>), [nb_Metadata_Configuration.ipynb](<M03_Data Pipelines(Azure Data Factory)/nb_Metadata_Configuration.ipynb>), and `archive/`.

#### [M04_data_engineering(Synapse Notebooks)](<M04_data_engineering(Synapse Notebooks)/>)

Notebook and PySpark data engineering examples. The folder name is retained exactly as it exists in the repository:

- [PySpark_00_NotebookUtils.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_00_NotebookUtils.ipynb>)
- [PySpark_01.Read Csv File.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_01.Read Csv File.ipynb>)
- [PySpark_02.Read JSON File.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_02.Read JSON File.ipynb>)
- [PySpark_03.Read XML File.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_03.Read XML File.ipynb>)
- [PySpark_04.Read  parquet File.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_04.Read  parquet File.ipynb>)
- [PySpark_05.Read Bronze layer apply transformation and write into silver layer.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_05.Read Bronze layer apply transformation and write into silver layer.ipynb>)
- [PySpark_06.Read Bronze layer apply transformation and write into silver layer2.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_06.Read Bronze layer apply transformation and write into silver layer2.ipynb>)
- [PySpark_07_more_used_functions.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_07_more_used_functions.ipynb>)
- [PySpark_08_partition_pruning.md](<M04_data_engineering(Synapse Notebooks)/PySpark_08_partition_pruning.md>)
- [PySpark_09_Identity_columns.ipynb](<M04_data_engineering(Synapse Notebooks)/PySpark_09_Identity_columns.ipynb>)
- `archive/` contains an archived version of a PySpark functions lesson.

#### [M05_PowerBI](<M05_PowerBI/>)

- [readme.md](<M05_PowerBI/readme.md>)

#### [M06_00_DataWareHouse](<M06_00_DataWareHouse/>)

Warehouse creation, ingestion, T-SQL, transformations, query building, and access control:

- [00_Create_Datawarehouse.md](<M06_00_DataWareHouse/00_Create_Datawarehouse.md>)
- [01_Ingest data into a Warehouse using Data Pipeline.md](<M06_00_DataWareHouse/01_Ingest data into a Warehouse using Data Pipeline.md>)
- [02_Create tables with T-SQL in a warehouse.md](<M06_00_DataWareHouse/02_Create tables with T-SQL in a warehouse.md>)
- [03_Clone a table with T-SQL in a Warehouse.md](<M06_00_DataWareHouse/03_Clone a table with T-SQL in a Warehouse.md>)
- [04_Transform data with a stored procedure in a Warehouse.md](<M06_00_DataWareHouse/04_Transform data with a stored procedure in a Warehouse.md>)
- [05_Create a query with the visual query builder in a Warehouse.md](<M06_00_DataWareHouse/05_Create a query with the visual query builder in a Warehouse.md>)
- [06. Warehouse Schema-Level Access Control .md](<M06_00_DataWareHouse/06. Warehouse Schema-Level Access Control .md>)
- [07. Identity_Column.md](<M06_00_DataWareHouse/07. Identity_Column.md>)

#### [M06_01_Environment](<M06_01_Environment/>)

Environment setup, libraries, and pipeline validation resources:

- [Fabric_Environment_Resources_Guide.ipynb](<M06_01_Environment/Fabric_Environment_Resources_Guide.ipynb>)
- [Fabric_Mimesis_External_Library_Guide.ipynb](<M06_01_Environment/Fabric_Mimesis_External_Library_Guide.ipynb>)
- [Fabric_Pipeline_Validator_v3.ipynb](<M06_01_Environment/Fabric_Pipeline_Validator_v3.ipynb>)
- [Microsoft_Fabric_Custom_Library_Guide.ipynb](<M06_01_Environment/Microsoft_Fabric_Custom_Library_Guide.ipynb>)
- Supporting files: [config.yml](<M06_01_Environment/config.yml>), [helpers.py](<M06_01_Environment/helpers.py>), [lookup.csv](<M06_01_Environment/lookup.csv>), [pipeline_validator.py](<M06_01_Environment/pipeline_validator.py>), [readme.md](<M06_01_Environment/readme.md>), [sales_summary.sql](<M06_01_Environment/sales_summary.sql>), and [schema.json](<M06_01_Environment/schema.json>).

#### [M07_Azure Data Explorer](<M07_Azure Data Explorer/>)

- [readme.md](<M07_Azure Data Explorer/readme.md>)

#### [M08_Real-Time Intelligence](<M08_Real-Time Intelligence/>)

Eventhouse, Real-Time hub, KQL database transformations, dashboards, reports, and alerts:

- [01_Set up Eventhouse.md](<M08_Real-Time Intelligence/01_Set up Eventhouse.md>)
- [02_Get data in the Real-Time hub.md](<M08_Real-Time Intelligence/02_Get data in the Real-Time hub.md>)
- [03_Transform data in a KQL database Bronze and Silver.md](<M08_Real-Time Intelligence/03_Transform data in a KQL database Bronze and Silver.md>)
- [04_Create a materialized view(Gold Layer).md](<M08_Real-Time Intelligence/04_Create a materialized view(Gold Layer).md>)
- [05_Create a Real-Time Dashboard.md](<M08_Real-Time Intelligence/05_Create a Real-Time Dashboard.md>)
- [06_Create a Power BI report.md](<M08_Real-Time Intelligence/06_Create a Power BI report.md>)
- [07_Set an alert on your event stream.md](<M08_Real-Time Intelligence/07_Set an alert on your event stream.md>)

#### [M09_DataScience](<M09_DataScience/>)

- [Data Overload to Instant Insights.ipynb](<M09_DataScience/Data Overload to Instant Insights.ipynb>)
- [test.md](<M09_DataScience/test.md>)

#### [M10_AI](<M10_AI/>)

- [AI Tools in Microsoft Fabric - Data Wrangler.md](<M10_AI/AI Tools in Microsoft Fabric - Data Wrangler.md>)

#### [M11_DevOps](<M11_DevOps/>)

Deployment planning and deployment pipeline material:

- [01-deployment-pipelines.md](<M11_DevOps/01-deployment-pipelines.md>)
- [02-item-reference-variable-type.md](<M11_DevOps/02-item-reference-variable-type.md>)
- [deployment-plan.md](<M11_DevOps/deployment-plan.md>)
- Supporting images are stored in this folder and in `media/`.

#### [M201_Interview](<M201_Interview/>)

Interview practice and technical examples:

- [Getting the Latest Transaction.ipynb](<M201_Interview/Getting the Latest Transaction.ipynb>)
- [Mapping_among_pipelinename_activity_sparkpool.md](<M201_Interview/Mapping_among_pipelinename_activity_sparkpool.md>)
- [Parent_child_pipelines_mapping_in_ADF.md](<M201_Interview/Parent_child_pipelines_mapping_in_ADF.md>)
- [PySpark.md](<M201_Interview/PySpark.md>)
- [Reading_json_and getting _latest_seat_num_per_booking.ipynb](<M201_Interview/Reading_json_and getting _latest_seat_num_per_booking.ipynb>)
- [ai_test.md](<M201_Interview/ai_test.md>)

#### [M99_Architectures](<M99_Architectures/>)

- [Kappa_Architecture_Demo_NYC_Taxi.ipynb](<M99_Architectures/Kappa_Architecture_Demo_NYC_Taxi.ipynb>)
- [readme.md](<M99_Architectures/readme.md>)

#### [Module 100](<Module 100/>)

Miscellaneous exercises, questions, and course planning:

- [IQ/01.Questions.md](<Module 100/IQ/01.Questions.md>)
- [Misc/01. Load Files into One Lake Table.md](<Module 100/Misc/01. Load Files into One Lake Table.md>)
- [Misc/02. Combine two Bronze tables and load into silver lake.md](<Module 100/Misc/02. Combine two Bronze tables and load into silver lake.md>)
- [Misc/Data Analytics Solutions.md](<Module 100/Misc/Data Analytics Solutions.md>)
- [poster.md](<Module 100/poster.md>)
- [tasklist.md](<Module 100/tasklist.md>)

### Other repository resources

These are also existing repository paths, but they are supporting material rather than sequential course modules:

- **[`Labdata/`](<Labdata/>)** — sample CSV, JSON, XML, TXT, Excel, and Parquet files used by exercises, with `dev/`, `test/`, `prod/`, and `media/` subfolders.
- **[`notebooks/`](<notebooks/>)** — [01.init_setup.ipynb](<notebooks/01.init_setup.ipynb>), [02. Actual_code.ipynb](<notebooks/02. Actual_code.ipynb>), [03. add_source_data.ipynb](<notebooks/03. add_source_data.ipynb>), and [test.md](<notebooks/test.md>).
- **[`recap.md`](recap.md)** and **[`weeklyplan.md`](weeklyplan.md)** — recap and weekly planning material.
- **[`skills/`](<skills/>)** — a separate Microsoft Fabric AI skills collection, including its own documentation and plugin files. It is not a numbered course module.
- **[`CONTRIBUTING.md`](CONTRIBUTING.md)** and **[`LICENSE`](LICENSE)** — repository contribution guidance and license.

> **Navigation note:** The repository currently has a mix of module numbering and topic folders (for example, `M02_...` and `M06_...` each contain multiple folders). This README follows those names exactly so every link corresponds to an existing path. It does not rename, move, or claim to create course files.

## Suggested learning progression using the current files

The existing material can be followed approximately in this sequence:

1. Start with [M01_Introduction to Microsoft Fabric](<M01_Introduction to Microsoft Fabric/>).
2. Learn Lakehouse and Delta concepts in [M02_00_LakeHouse](<M02_00_LakeHouse/>), then explore the SQL analytics endpoint and Python/PySpark folders under the `M02_...` topic areas.
3. Practice ingestion and orchestration with [M03_Data Pipelines(Azure Data Factory)](<M03_Data Pipelines(Azure Data Factory)/>).
4. Continue with [M04_data_engineering(Synapse Notebooks)](<M04_data_engineering(Synapse Notebooks)/>) for notebook-based data engineering.
5. Explore [M06_00_DataWareHouse](<M06_00_DataWareHouse/>) for Warehouse and T-SQL examples, alongside [M05_PowerBI](<M05_PowerBI/>).
6. Study event-based analytics in [M07_Azure Data Explorer](<M07_Azure Data Explorer/>) and [M08_Real-Time Intelligence](<M08_Real-Time Intelligence/>).
7. Explore [M09_DataScience](<M09_DataScience/>) and [M10_AI](<M10_AI/>).
8. Review deployment examples in [M11_DevOps](<M11_DevOps/>), architecture examples in [M99_Architectures](<M99_Architectures/>), and practice material in [M201_Interview](<M201_Interview/>) and [Module 100](<Module 100/>).

The repository currently has different levels of coverage in different areas. Use each module's included README or lesson files for its actual instructions; topics without a corresponding file are not represented as completed lessons here.

## Prerequisites

- A Microsoft Fabric-enabled account and permission to use the relevant Fabric workloads. Access, capacity, and tenant settings depend on your organization.
- A modern web browser. Some notebooks and hands-on labs require an accessible Fabric workspace.
- No prior Fabric experience is needed to begin with the introduction. Familiarity with SQL, Python, data analytics, or Power BI will help with the corresponding advanced topics.
- Use permitted sample data only. Do not commit credentials, tokens, private data, or other secrets to the repository.

## Help and resources

- [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- [Microsoft Fabric community](https://community.fabric.microsoft.com/)
- [Repository issues](https://github.com/rritec/Microsoft-Fabric/issues)

Microsoft Fabric changes regularly. Check current Microsoft documentation for feature availability, licensing, limits, and interface steps.
