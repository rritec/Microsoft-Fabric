# Microsoft Fabric: Beginner-to-Advanced Course

![Course Badge](https://img.shields.io/badge/course-Microsoft%20Fabric-blue)

A structured, hands-on learning path for building, operating, and governing analytics solutions with Microsoft Fabric. The course starts with data and platform fundamentals, then progresses through ingestion, Lakehouse and Warehouse engineering, Power BI, real-time analytics, data science, security, and production operations.

> **Who this is for:** Beginners, data analysts, BI developers, data engineers, data scientists, and cloud professionals. You can start with little or no Fabric experience. SQL and Power BI familiarity are helpful, but the early modules introduce the concepts you need.

## How the course is organized

The repository is organized by **modules**. Each module is a folder, and each chapter inside it is a topic-focused Markdown file. Chapters should follow a consistent pattern: concepts, step-by-step walkthrough, hands-on exercise, expected result, review questions, and further reading.

```text
Microsoft-Fabric/
├── README.md
├── modules/
│   ├── 01-data-and-analytics-foundations/
│   │   ├── README.md
│   │   ├── 01-analytics-and-data-platforms.md
│   │   ├── 02-relational-and-analytical-data.md
│   │   └── 03-sql-files-and-data-formats.md
│   ├── 02-fabric-fundamentals/
│   │   ├── README.md
│   │   ├── 01-what-is-microsoft-fabric.md
│   │   ├── 02-workspaces-and-capacities.md
│   │   └── 03-fabric-portal-and-workloads.md
│   ├── 03-onelake-and-data-foundations/
│   │   ├── README.md
│   │   ├── 01-onelake-and-lakehouse-storage.md
│   │   ├── 02-lakehouse-files-and-tables.md
│   │   └── 03-shortcuts-and-data-sharing.md
│   ├── 04-data-ingestion-and-transformation/
│   │   ├── README.md
│   │   ├── 01-data-sources-and-connectors.md
│   │   ├── 02-dataflows-gen2-and-power-query.md
│   │   └── 03-data-pipelines-and-copy-activity.md
│   ├── 05-lakehouse-and-spark-engineering/
│   │   ├── README.md
│   │   ├── 01-notebooks-and-spark-basics.md
│   │   ├── 02-delta-tables-and-medallion-architecture.md
│   │   └── 03-data-quality-and-schema-management.md
│   ├── 06-data-warehousing-and-sql/
│   │   ├── README.md
│   │   ├── 01-fabric-warehouse-fundamentals.md
│   │   ├── 02-dimensional-modeling.md
│   │   └── 03-t-sql-and-querying-data.md
│   ├── 07-orchestration-and-reusable-data-solutions/
│   │   ├── README.md
│   │   ├── 01-pipeline-orchestration.md
│   │   ├── 02-parameters-variables-and-control-flow.md
│   │   └── 03-incremental-and-restartable-loads.md
│   ├── 08-power-bi-and-semantic-modeling/
│   │   ├── README.md
│   │   ├── 01-semantic-model-fundamentals.md
│   │   ├── 02-star-schemas-and-relationships.md
│   │   ├── 03-dax-and-measures.md
│   │   └── 04-reports-and-interactive-analytics.md
│   ├── 09-real-time-analytics-and-kql/
│   │   ├── README.md
│   │   ├── 01-eventstreams-and-event-ingestion.md
│   │   ├── 02-eventhouse-and-kql-databases.md
│   │   └── 03-kql-queries-alerts-and-real-time-dashboards.md
│   ├── 10-data-science-and-machine-learning/
│   │   ├── README.md
│   │   ├── 01-data-science-workspaces-and-notebooks.md
│   │   ├── 02-experimentation-and-model-training.md
│   │   └── 03-scoring-and-operationalization.md
│   ├── 11-security-governance-and-compliance/
│   │   ├── README.md
│   │   ├── 01-identities-roles-and-permissions.md
│   │   ├── 02-sensitivity-labels-and-protection.md
│   │   └── 03-lineage-discovery-and-governance.md
│   ├── 12-deployment-devops-and-cicd/
│   │   ├── README.md
│   │   ├── 01-development-test-and-production.md
│   │   ├── 02-git-integration-and-branching.md
│   │   └── 03-deployment-pipelines-and-automation.md
│   ├── 13-performance-monitoring-and-cost-management/
│   │   ├── README.md
│   │   ├── 01-capacity-and-workload-basics.md
│   │   ├── 02-troubleshooting-and-performance.md
│   │   └── 03-monitoring-and-cost-awareness.md
│   └── 14-solution-architecture-and-capstone/
│       ├── README.md
│       ├── 01-requirements-and-architecture.md
│       ├── 02-build-an-end-to-end-analytics-solution.md
│       └── 03-present-review-and-improve.md
├── labs/
│   ├── README.md
│   └── solutions/                 # Optional instructor solutions
├── datasets/
│   ├── README.md
│   └── sample-data/               # Small, licensed or synthetic datasets
├── projects/
│   ├── README.md
│   └── capstone/                  # Capstone brief, rubric, and deliverables
└── resources/
    ├── glossary.md
    ├── troubleshooting.md
    └── further-reading.md
```

**Naming convention:** use zero-padded numbers to preserve learning order, lowercase kebab-case for folder and file names, and descriptive topic names rather than generic names such as `chapter1.md`. Each module's `README.md` should introduce the module, list its chapters, explain prerequisites, and state what learners will build.

## Learning path and course outline

### Module 1 — Data and analytics foundations

**Goal:** Build the vocabulary and basic data skills needed to understand Fabric's workloads.

- Analytics concepts: transactional systems, analytical systems, batch, and streaming
- The data lifecycle: source, ingest, store, transform, model, serve, and govern
- Structured, semi-structured, and unstructured data
- Tables, files, schemas, keys, and relationships
- Introductory SQL: `SELECT`, filtering, sorting, grouping, and joins
- Common file formats: CSV, JSON, Parquet, and Delta tables
- Introductory dimensional-modeling concepts: facts, dimensions, and grain
- **Practice:** inspect sample files, identify their structures, and write simple SQL queries

### Module 2 — Microsoft Fabric fundamentals

**Goal:** Understand what Fabric is and how its environment is organized.

- Microsoft Fabric as an integrated analytics platform and its relationship to Power BI and Microsoft OneLake
- Fabric workloads and when to use them: Data Factory, Data Engineering, Data Warehouse, Data Science, Real-Time Intelligence, and Power BI
- The Fabric portal, navigation, item types, and workspace organization
- Workspaces, roles, domains, and capacity at an introductory level
- Understand trial and capacity considerations, permissions, and responsible use of shared resources
- Compare common workload choices without assuming that one tool fits every use case
- **Practice:** explore a workspace, identify Fabric items, and map a sample analytics scenario to workloads

### Module 3 — OneLake and data foundations

**Goal:** Learn how Fabric stores, organizes, and makes data accessible.

- OneLake concepts and the relationship between workspaces, items, and data
- Lakehouse basics: `Files` and `Tables`, managed data, and Delta format
- Organizing folders, naming conventions, and choosing a storage layout
- Shortcuts: accessing data in place and understanding the difference between a shortcut and a copy
- Data discovery, reuse, and basic lineage concepts
- **Practice:** create a Lakehouse, upload sample files, create a table, and inspect its contents

### Module 4 — Data ingestion and transformation

**Goal:** Bring data into Fabric and perform repeatable low-code transformations.

- Source systems, connectors, authentication, and gateway concepts
- Copying data and choosing between batch ingestion and other patterns
- Dataflows Gen2 and Power Query fundamentals
- Cleaning, filtering, combining, and shaping data
- Destinations and loading data to supported Fabric items
- Refresh behavior, error handling, and basic data validation
- **Practice:** ingest files or a sample source, transform the data, and load a curated result

### Module 5 — Lakehouse and Spark engineering

**Goal:** Develop engineering workflows with notebooks, Spark, and Delta tables.

- Lakehouse architecture and the bronze, silver, and gold medallion pattern
- Notebook workflow and introductory PySpark; use SQL where appropriate
- Read and write files and tables from a notebook
- Delta table fundamentals, schema enforcement, and table maintenance concepts
- Data cleansing, deduplication, joins, and aggregations
- Data quality checks, null handling, and schema evolution considerations
- **Practice:** build a notebook that turns raw data into validated, curated Lakehouse tables

### Module 6 — Data warehousing and SQL

**Goal:** Design and query a relational analytical model in a Fabric Warehouse.

- Warehouse concepts and how Warehouse and Lakehouse approaches differ
- Create tables and load data; understand supported T-SQL capabilities and product-specific considerations
- Dimensional modeling: grain, facts, dimensions, surrogate keys, and star schemas
- Write analytical SQL with joins, aggregations, common table expressions, and window functions
- Data loading and transformation patterns for a warehouse
- Query plans and introductory performance considerations
- **Practice:** create a small star schema and answer business questions with SQL

### Module 7 — Orchestration and reusable data solutions

**Goal:** Coordinate multi-step data workflows and make them easier to operate.

- Data pipelines and orchestration concepts
- Activities, dependencies, scheduling, and monitoring pipeline runs
- Parameters, variables, expressions, and reusable pipeline patterns
- Incremental loading, watermarks, and change-aware processing concepts
- Retry, failure paths, logging, and restartability
- Coordinate notebooks, Dataflows Gen2, and data movement where supported
- **Practice:** orchestrate a repeatable ingestion and transformation workflow with run monitoring

### Module 8 — Power BI and semantic modeling

**Goal:** Turn prepared data into understandable, governed business insights.

- Semantic models and the separation between data preparation and reporting
- Star schemas, relationships, filter direction, and model design
- Measures, calculated columns, and introductory DAX
- Report pages, visuals, slicers, drill-through, and accessible design
- Direct Lake, DirectQuery, and Import concepts; understand trade-offs and limitations
- Row-level security concepts and validating the user experience
- **Practice:** create a semantic model and report that answer defined business questions

### Module 9 — Real-time analytics and KQL

**Goal:** Explore event-based data processing and real-time analysis.

- Event data, telemetry, streaming, and real-time analytics scenarios
- Eventstreams and ingestion concepts, including sources and destinations available in the environment
- Eventhouse and KQL database fundamentals
- Kusto Query Language (KQL) basics: filtering, projection, aggregation, and time-based analysis
- Real-time dashboards, alerts, and operational use cases
- Considerations for retention, event volume, and late-arriving data
- **Practice:** ingest or use sample events, query them with KQL, and build a simple live-monitoring view

### Module 10 — Data science and machine learning

**Goal:** Use Fabric notebooks and data science experiences to explore and operationalize analytical models.

- Exploratory data analysis and feature preparation
- Notebook-based Python workflows and reproducibility
- Train, evaluate, and compare a baseline machine-learning model
- Track experiments and manage model artifacts using available Fabric capabilities
- Batch scoring and making predictions available to downstream analytics
- Responsible AI, privacy, bias, and model limitations
- **Practice:** train and evaluate a simple model, then communicate its results and limitations

### Module 11 — Security, governance, and compliance

**Goal:** Apply least-privilege access and understand how data is discovered and protected.

- Tenant, capacity, workspace, item, and data-level access concepts
- Workspace roles, item permissions, and identity basics
- Least privilege and separation of duties
- Sensitivity labels, information protection, and related organizational policies
- Lineage, endorsement, discovery, and data ownership concepts
- Auditing and governance responsibilities; confirm features against your organization's configuration
- **Practice:** design an access matrix for a sample project and validate access using appropriate test accounts

### Module 12 — Deployment, DevOps, and CI/CD

**Goal:** Move Fabric work through controlled development and release workflows.

- Development, test, and production environment strategy
- Git integration concepts, source control, branching, and collaboration
- Deployment pipelines and environment-specific configuration
- Parameterization, release checklists, and controlled promotion
- Fabric REST APIs and automation concepts; handle credentials securely and avoid committing secrets
- Testing data transformations and validating releases
- **Practice:** plan and execute a promotion workflow for a small solution, documenting prerequisites and rollback considerations

### Module 13 — Performance, monitoring, and cost awareness

**Goal:** Operate workloads responsibly and diagnose common issues.

- Capacity concepts, workload behavior, and shared-capacity considerations
- Monitor pipeline, notebook, query, and refresh activity using the relevant experiences
- Diagnose common ingestion, permission, schema, and query failures
- Performance fundamentals for Spark, SQL, models, and reports
- Workload sizing, concurrency, and optimization trade-offs
- Cost awareness, quotas, and responsible capacity usage
- **Practice:** investigate a deliberately introduced issue, record evidence, and recommend a measured improvement

### Module 14 — Solution architecture and capstone

**Goal:** Combine course skills into a documented, end-to-end analytics solution.

Build a solution for a realistic business scenario, such as retail sales, operations, public data, or IoT monitoring. The project should include:

1. Business questions, user needs, assumptions, and success criteria
2. A source-to-consumption architecture diagram and workload choices
3. A documented ingestion and transformation process
4. A Lakehouse medallion design, Warehouse model, or a justified combination
5. Data quality checks and repeatable orchestration
6. A semantic model, report, or real-time view appropriate to the scenario
7. Security and governance recommendations
8. A deployment and operational plan, including monitoring and cost considerations
9. A final demonstration, README, and reflection on limitations and next steps

**Assessment:** evaluate correctness, clarity, reproducibility, security, data quality, performance awareness, and the quality of the business insights—not just whether the demo runs.

## Recommended chapter template

Use a consistent chapter format so students know how to learn from every topic:

1. **Learning objectives** — observable outcomes for the chapter
2. **Why it matters** — the problem this topic solves
3. **Prerequisites** — earlier chapters, account access, permissions, and required tools
4. **Key concepts** — definitions, diagrams, and decision guidance
5. **Guided walkthrough** — numbered, verifiable steps with expected results
6. **Hands-on challenge** — a task for students to complete independently
7. **Validation and troubleshooting** — how to confirm success and address common errors
8. **Knowledge check** — review questions or a short quiz
9. **Cleanup** — stop or remove resources where appropriate
10. **Further reading** — current Microsoft Learn documentation and related course chapters

## Prerequisites and setup

- A Microsoft Fabric-enabled environment with the necessary tenant settings, permissions, and capacity or trial access. Availability can vary by organization and region; check with your administrator before class.
- A modern web browser and a Microsoft account authorized to access the learning environment.
- No prior Fabric experience is required.
- Basic spreadsheet experience is useful. SQL and Power BI are helpful but can be learned alongside the course.
- Python is introduced where needed for notebook and data-science exercises; advanced programming is not required for the introductory path.
- Use only data you are permitted to upload and process. Never commit credentials, tokens, private data, or other secrets to this repository.

## Suggested student pathways

- **New to analytics:** Modules 1–5, then 7–8, and finish with the capstone.
- **BI analyst:** Modules 1–4, then 6 and 8, followed by governance and the capstone.
- **Data engineer:** Modules 1–7, then 11–13 and the capstone.
- **Data scientist:** Modules 1–5, then 8 and 10–13, with the capstone.
- **Experienced professional:** Use module objectives and knowledge checks to identify gaps, then complete the relevant labs and capstone.

## Learning outcomes

By the end of the course, students should be able to:

- Explain Fabric's core workloads and choose an appropriate approach for a scenario.
- Organize and access data using OneLake, Lakehouses, Warehouses, and supported shortcuts.
- Ingest, transform, validate, and orchestrate data using suitable Fabric experiences.
- Use SQL, notebooks, Power Query, and KQL at an introductory practical level.
- Design an analytical model and build a Power BI report for business users.
- Describe foundational real-time analytics and machine-learning workflows.
- Apply basic security, governance, deployment, monitoring, and performance practices.
- Design and present a small end-to-end solution with documented trade-offs.

## Contributing course content

- Put each new topic in the relevant module folder as a numbered Markdown chapter.
- Update the module `README.md` and this course outline when adding or reordering chapters.
- Keep exercises reproducible, label instructor-only solutions clearly, and provide synthetic or appropriately licensed datasets.
- Link to authoritative Microsoft Learn documentation and note when a feature or interface may change.
- Prefer small, focused chapters that build progressively from concepts to guided practice and independent work.

## Help and resources

- [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- [Microsoft Fabric community](https://community.fabric.microsoft.com/)
- [Repository issues and troubleshooting](https://github.com/rritec/Microsoft-Fabric/issues)
- [Repository](https://github.com/rritec/Microsoft-Fabric)

Microsoft Fabric changes regularly. Treat this course as a learning guide, and verify feature availability, licensing, limits, and interface steps against current Microsoft documentation and your organization's environment.
