Absolutely. Since you worked through this as a real hands-on lab, the GitHub lesson should preserve both the why and the exact build/deploy sequence, with your screenshots placed at the checkpoints where they prove something.

Below is a copy-paste-ready Markdown lesson. I’ve used screenshot placeholders such as images/01-workspace.png. Save the screenshots you already captured into an images folder in your GitHub repository and rename them accordingly.

Microsoft Fabric Deployment Plans: End-to-End Lakehouse to Warehouse Deployment
Overview

This lesson demonstrates an end-to-end Microsoft Fabric Deployment Plan scenario based on the Microsoft sample where a downstream item depends on data produced by an upstream item.

The solution contains:

A Lakehouse for storing data.
A Hydrate notebook that creates source data.
A Publish notebook that transforms and publishes the final table.
A Warehouse containing a view over the Lakehouse table.
A Deployment Plan that controls deployment and notebook execution order.
A Deployment Pipeline that promotes the solution from Development to Test.

The key problem is that deploying a Lakehouse copies the item definition but does not deploy the runtime-created table data. Therefore, deploying the Warehouse immediately can fail because its view depends on a table that does not yet exist.

The Deployment Plan solves this by running the notebooks between the Lakehouse deployment and Warehouse deployment. Microsoft describes this as one of the primary deployment-plan scenarios.

1. Architecture

The logical application flow is:

Hydrate_TopCustomers
        │
        │ writes
        ▼
dbo.dev_top_customers
        │
        │ read by
        ▼
Publish_TopCustomers
        │
        │ publishes
        ▼
dbo.top_customers
        │
        │ read by
        ▼
dbo.vw_top_customers


The Fabric item containment is:

Sales_Lakehouse
├── dbo.dev_top_customers
└── dbo.top_customers

Sales_Warehouse
└── dbo.vw_top_customers


The deployment orchestration is:

Deploy Sales_Lakehouse
        │
        ▼
Run Hydrate_TopCustomers
        │
        ▼
Run Publish_TopCustomers
        │
        ▼
Sales_Lakehouse deployment group completes
        │
        ▼
Deploy Sales_Warehouse


Microsoft's sample uses the same pattern: two deployment groups, with the two notebooks running as post-deployment actions of the Lakehouse group and the Warehouse group depending on the Lakehouse group.

2. Environment

For this exercise, two Fabric workspaces are used:

Environment	WorkspaceDevelopment	ram-dev
Test	ram-test

The development workspace is connected to an Azure DevOps Git repository.

The deployment pipeline is:

ram-dev
   │
   │ Dev → Test
   ▼
ram-test

3. Create the Development Artifacts

The following artifacts are created in ram-dev:

ram-dev
│
├── Sales_Lakehouse
├── Hydrate_TopCustomers
├── Publish_TopCustomers
├── Sales_Warehouse
└── Sales_Deployment_Plan


The Lakehouse tables are intentionally created by the notebooks rather than manually.

Lakehouse tables themselves are not tracked as data by Git/deployment operations, which is central to this scenario.

4. Create Sales_Lakehouse

Create a Lakehouse named:

Sales_Lakehouse


Leave the Lakehouse empty initially.

At this point:

Sales_Lakehouse
└── Tables
    └── (empty)


The required tables will be created by the notebooks.

5. Create Hydrate_TopCustomers

Create a Fabric notebook named:

Hydrate_TopCustomers


Attach Sales_Lakehouse as the notebook's default Lakehouse.

The notebook will create the initial customer dataset and persist the data as:

dbo.dev_top_customers

5.1 Create Sample Data

Add the following PySpark code:

from pyspark.sql import functions as F

sales_data = [
    (1001, "Contoso Ltd", "United States", 125000.00),
    (1002, "Fabrikam Inc", "United States", 98500.00),
    (1003, "Adventure Works", "Canada", 87500.00),
    (1004, "Northwind Traders", "United Kingdom", 76000.00),
    (1005, "Wide World Importers", "Australia", 69000.00),
    (1006, "Tailspin Toys", "United States", 54000.00),
    (1007, "Litware", "Germany", 48000.00),
    (1008, "Proseware", "France", 41000.00),
    (1009, "Fourth Coffee", "Canada", 36000.00),
    (1010, "Wingtip Toys", "United States", 31000.00)
]

columns = [
    "customer_id",
    "customer_name",
    "country",
    "total_sales"
]

df = spark.createDataFrame(sales_data, columns)

display(df)


The initial dataset contains 10 customers.

5.2 Add Load Metadata

Add a timestamp that records when the data was hydrated.

df = df.withColumn(
    "loaded_at",
    F.current_timestamp()
)

display(df)


The resulting schema contains:

customer_id
customer_name
country
total_sales
loaded_at

5.3 Create dev_top_customers

Write the DataFrame to the Lakehouse as a Delta table:

df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("dev_top_customers")


Verify:

spark.sql("""
    SELECT
        customer_id,
        customer_name,
        country,
        total_sales,
        loaded_at
    FROM dev_top_customers
    ORDER BY total_sales DESC
""").show(truncate=False)


The resulting Lakehouse structure is:

Sales_Lakehouse
└── Tables
    └── dbo
        └── dev_top_customers

Screenshot
images/01-hydrate-top-customers.png


What this screenshot demonstrates: Hydrate_TopCustomers successfully created and populated dbo.dev_top_customers.

6. Configure Notebook Git Binding

For both notebooks, configure:

Git settings
    ↓
Git binding
    ↓
Lakehouse in new workspace


Apply this configuration to:

Hydrate_TopCustomers
Publish_TopCustomers


This is important because the notebook should bind to the corresponding Lakehouse when deployed into another workspace rather than continuing to reference the Development Lakehouse.

Fabric stores logical identifiers for attached notebook dependencies and can automatically bind them to corresponding resources in another workspace.

When deployed to Test, the intended relationship is:

ram-test
├── Sales_Lakehouse
├── Hydrate_TopCustomers ─────► ram-test/Sales_Lakehouse
└── Publish_TopCustomers ─────► ram-test/Sales_Lakehouse


not:

ram-test/Publish_TopCustomers
              │
              └────────► ram-dev/Sales_Lakehouse

7. Create Publish_TopCustomers

Create another notebook named:

Publish_TopCustomers


Attach:

Sales_Lakehouse


as its default Lakehouse.

The notebook implements:

dbo.dev_top_customers
        │
        ▼
Publish_TopCustomers
        │
        ▼
dbo.top_customers

7.1 Read the Development Table
source_df = spark.table("dbo.dev_top_customers")

display(source_df)


The notebook should return the 10 records generated by Hydrate_TopCustomers.

7.2 Identify Top Customers

For this exercise, a top customer is defined as a customer with:

total_sales >= 50000


Use:

from pyspark.sql import functions as F

top_customers_df = (
    source_df
    .filter(F.col("total_sales") >= 50000)
    .select(
        "customer_id",
        "customer_name",
        "country",
        "total_sales"
    )
    .withColumn(
        "published_at",
        F.current_timestamp()
    )
)

display(top_customers_df)


The transformation produces six customers:

1001  Contoso Ltd
1002  Fabrikam Inc
1003  Adventure Works
1004  Northwind Traders
1005  Wide World Importers
1006  Tailspin Toys

7.3 Publish dbo.top_customers

Write the transformed DataFrame:

top_customers_df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("dbo.top_customers")


Verify:

result_df = spark.sql("""
    SELECT
        customer_id,
        customer_name,
        country,
        total_sales,
        published_at
    FROM dbo.top_customers
    ORDER BY total_sales DESC
""")

display(result_df)


The Lakehouse now contains:

Sales_Lakehouse
└── Tables
    └── dbo
        ├── dev_top_customers
        └── top_customers

8. Add a Readiness Check

This is an important part of the deployment scenario.

A Deployment Plan considers an action complete when the notebook run completes. It does not automatically wait for downstream services such as the Lakehouse SQL analytics endpoint to synchronize.

Microsoft specifically highlights this issue in the sample and recommends keeping the readiness logic inside the action.

For this lab, the following check verifies the Spark table and then provides a synchronization buffer.

import time

max_wait_seconds = 300
poll_interval_seconds = 10

elapsed = 0

while elapsed < max_wait_seconds:
    try:
        if spark.catalog.tableExists("dbo.top_customers"):
            row_count = spark.sql("""
                SELECT COUNT(*) AS cnt
                FROM dbo.top_customers
            """).collect()[0]["cnt"]

            if row_count > 0:
                print(
                    f"dbo.top_customers is available with {row_count} rows."
                )
                break

    except Exception as e:
        print(f"Table not ready yet: {e}")

    print(
        f"Waiting for dbo.top_customers... "
        f"{elapsed}/{max_wait_seconds} seconds"
    )

    time.sleep(poll_interval_seconds)
    elapsed += poll_interval_seconds

else:
    raise TimeoutError(
        f"dbo.top_customers was not ready within {max_wait_seconds} seconds."
    )

sql_sync_wait_seconds = 30

print(
    f"Waiting {sql_sync_wait_seconds} seconds for "
    "SQL analytics endpoint metadata synchronization..."
)

time.sleep(sql_sync_wait_seconds)

print("Publish_TopCustomers completed successfully.")


Expected output:

dbo.top_customers is available with 6 rows.
Waiting 30 seconds for SQL analytics endpoint metadata synchronization...
Publish_TopCustomers completed successfully.


Note

The first part verifies Spark table availability. The 30-second delay is a synchronization buffer used for this lab. A production implementation should preferably poll the SQL analytics endpoint directly rather than rely on a fixed delay.

Screenshot
images/02-publish-readiness-check.png

9. Verify the Lakehouse SQL Analytics Endpoint

Open the SQL analytics endpoint associated with:

Sales_Lakehouse


Run:

SELECT *
FROM dbo.top_customers
ORDER BY total_sales DESC;


Expected result:

6 rows


This verifies:

Spark
   │
   ▼
Delta table
   │
   ▼
SQL analytics endpoint


The Lakehouse SQL analytics endpoint exposes Delta Lake tables through its T-SQL surface.

10. Create Sales_Warehouse

Create a Warehouse named:

Sales_Warehouse


Do not copy top_customers into the Warehouse.

The Warehouse should consume the Lakehouse table:

Sales_Lakehouse
└── dbo.top_customers
          │
          ▼
Sales_Warehouse
└── dbo.vw_top_customers

11. Add Sales_Lakehouse to the Warehouse Explorer

From the Sales_Warehouse Explorer:

+ Warehouses


Select the SQL analytics endpoint associated with:

Sales_Lakehouse


After adding the endpoint, Explorer should show both:

Sales_Warehouse
└── Schemas
    └── dbo

Sales_Lakehouse
└── Schemas
    └── dbo
        ├── dev_top_customers
        └── top_customers


Fabric supports cross-database querying between Warehouse and SQL analytics endpoint objects in the same active workspace. Cross-database queries use three-part database.schema.object naming.

12. Test Cross-Database Access

From Sales_Warehouse, run:

SELECT *
FROM [Sales_Lakehouse].[dbo].[top_customers]
ORDER BY total_sales DESC;


The query should return the same six rows.

Screenshot
images/03-cross-database-query.png


This screenshot demonstrates that Sales_Warehouse can query:

Sales_Lakehouse.dbo.top_customers


without copying the source data.

13. Create vw_top_customers

Create a view in Sales_Warehouse:

CREATE VIEW dbo.vw_top_customers
AS
SELECT
    customer_id,
    customer_name,
    country,
    total_sales
FROM [Sales_Lakehouse].[dbo].[top_customers];


Verify:

SELECT *
FROM dbo.vw_top_customers
ORDER BY total_sales DESC;


Expected result:

6 rows


The final data dependency is:

Sales_Lakehouse
└── dbo.top_customers
          │
          │ read by
          ▼
Sales_Warehouse
└── dbo.vw_top_customers

Screenshot
images/04-warehouse-view-results.png

14. Review the Development Dependency Chain

The complete application now looks like:

Hydrate_TopCustomers
        │
        │ writes
        ▼
dbo.dev_top_customers
   Sales_Lakehouse
        │
        │ read by
        ▼
Publish_TopCustomers
        │
        │ publishes
        ▼
dbo.top_customers
   Sales_Lakehouse
        │
        │ read by
        ▼
dbo.vw_top_customers
   Sales_Warehouse


The containment relationships are:

Sales_Lakehouse
├── dbo.dev_top_customers
└── dbo.top_customers

Sales_Warehouse
└── dbo.vw_top_customers

15. Review Fabric Lineage

Open the workspace lineage/dependency view.

The development workspace contains:

Sales_Lakehouse
Sales_Lakehouse SQL analytics endpoint
Hydrate_TopCustomers
Publish_TopCustomers
Sales_Warehouse

Screenshot
images/05-workspace-lineage.png


This view helps distinguish item dependencies/bindings from the runtime dependency that the deployment plan must manage.

16. Commit the Solution to Azure DevOps

After saving the artifacts, commit the Fabric workspace to Azure DevOps.

The repository contains structures similar to:

Hydrate_TopCustomers.Notebook/
├── .platform
├── notebook-content.py
└── notebook-settings.json

Publish_TopCustomers.Notebook/
├── .platform
├── notebook-content.py
└── notebook-settings.json

Sales_Lakehouse.Lakehouse/
├── .platform
├── alm.settings.json
├── lakehouse.metadata.json
└── shortcuts.metadata.json

Sales_Warehouse.Warehouse/
├── dbo/
│   └── Views/
│       └── vw_top_customers.sql
├── .gitignore
├── .platform
└── Sales_Warehouse.sqlproj


Notice that:

dev_top_customers
top_customers


do not appear as Lakehouse table files in Git.

This is expected. Fabric Git/deployment operations do not track the Lakehouse table data itself.

Screenshot
images/06-azure-devops-repository.png

17. Why a Normal Deployment Is Not Enough

Suppose the destination is completely empty.

A simple deployment would conceptually do:

Deploy Sales_Lakehouse
        ↓
Sales_Lakehouse exists
        ↓
BUT dbo.top_customers does not exist
        ↓
Deploy Sales_Warehouse
        ↓
Create vw_top_customers
        ↓
View references missing dbo.top_customers
        ↓
Deployment can fail


The critical observation is:

Deployment order answers "what deploys first?" but does not necessarily perform the runtime activity required to make downstream objects valid.

Microsoft's sample specifically uses this scenario to demonstrate why deployment plans are useful.

18. Create Sales_Deployment_Plan

Create a Fabric Deployment Plan named:

Sales_Deployment_Plan


The plan contains two deployment groups.

Group 1: Sales_Lakehouse

Deploy:

Sales_Lakehouse


Configure these After actions:

Hydrate_TopCustomers
        │
        ▼
Publish_TopCustomers


Publish_TopCustomers must depend on Hydrate_TopCustomers.

The effective group is:

GROUP: Sales_Lakehouse

Deploy
└── Sales_Lakehouse

After
├── Hydrate_TopCustomers
│
└── Publish_TopCustomers
        ↑
        │ depends on Hydrate

Group 2: Sales_Warehouse

Deploy:

Sales_Warehouse


Configure:

Sales_Warehouse
    depends on
Sales_Lakehouse group


The complete Deployment Plan becomes:

┌─────────────────────────────────────┐
│ GROUP: Sales_Lakehouse              │
│                                     │
│ Deploy Sales_Lakehouse              │
│          ↓                          │
│ Run Hydrate_TopCustomers            │
│          ↓                          │
│ Run Publish_TopCustomers            │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│ GROUP: Sales_Warehouse              │
│                                     │
│ Deploy Sales_Warehouse              │
└─────────────────────────────────────┘


Microsoft's deployment-plan sample uses this same two-group structure.

Screenshot
images/07-sales-deployment-plan.png

19. Inspect plan.yml

Commit the Deployment Plan to Azure DevOps.

Fabric stores the plan definition as:

Sales_Deployment_Plan.DeploymentPlan/
├── .platform
└── plan.yml


The generated YAML has the logical structure:

$schema: https://developer.microsoft.com/json-schemas/fabric/item/deploymentPlan/definition/plan/1.0.0/schema.json
version: 1.0.0

groups:
  - name: Sales_Lakehouse
    logicalId: <sales-lakehouse-logical-id>

    postActions:
      - name: Hydrate_TopCustomers_SynapseNotebook
        job:
          type: Execute
          logicalId: <hydrate-notebook-logical-id>

      - name: Publish_TopCustomers_SynapseNotebook
        job:
          type: Execute
          logicalId: <publish-notebook-logical-id>

        dependsOn:
          - actionName: Hydrate_TopCustomers_SynapseNotebook

  - name: Sales_Warehouse
    logicalId: <sales-warehouse-logical-id>

    dependsOn:
      - groupName: Sales_Lakehouse


The important dependencies are:

ACTION DEPENDENCY

Publish_TopCustomers
        ↓ dependsOn
Hydrate_TopCustomers


and:

GROUP DEPENDENCY

Sales_Warehouse
        ↓ dependsOn
Sales_Lakehouse


Fabric uses logicalId to identify Fabric items across workspaces, and dependsOn determines execution order rather than simply the position of objects in the YAML file.

Screenshot
images/08-plan-yaml.png

20. Prepare the Test Workspace

The target workspace is:

ram-test


Before deployment, the workspace is intentionally empty.

ram-test
└── EMPTY


This provides a clean test proving that the target tables are produced by the deployment-plan actions rather than being manually created.

Screenshot
images/09-empty-test-workspace.png

21. Configure the Deployment Pipeline

The Deployment Pipeline is:

ram-deployment-pipeline


with:

Dev                         Test
ram-dev  ────────────────►  ram-test

Screenshot
images/10-deployment-pipeline.png

22. Select the Deployment Plan

Start the deployment from:

Dev


to:

Test


In the deployment configuration select:

with plan:
Sales_Deployment_Plan


This step is critical.

Without selecting the Deployment Plan, the special notebook execution sequence will not be provided by this plan.

Screenshot
images/11-select-deployment-plan.png

23. Review the Items Being Deployed

The deployment shows five items:

Deployment Plan
Lakehouse
Notebook
Notebook
Warehouse


All items initially show:

Only in source


because ram-test started empty.

Screenshot
images/12-deployment-items.png


At this point execute the deployment.

24. Deployment Execution Sequence

With the Deployment Plan selected, the effective orchestration is:

ram-dev
   │
   ▼
Deploy Sales_Lakehouse
   │
   ▼
Run Hydrate_TopCustomers
   │
   ▼
Create dbo.dev_top_customers
   │
   ▼
Run Publish_TopCustomers
   │
   ▼
Create dbo.top_customers
   │
   ▼
Readiness/synchronization check
   │
   ▼
Sales_Lakehouse group complete
   │
   ▼
Deploy Sales_Warehouse
   │
   ▼
Create dbo.vw_top_customers
   │
   ▼
ram-test ready


The notebooks are actions within the Lakehouse deployment group, not separate deployment groups.

25. Validate the Deployment in ram-test

After deployment, open:

ram-test
    ↓
Sales_Lakehouse


Both tables should exist:

Sales_Lakehouse
└── Tables
    └── dbo
        ├── dev_top_customers
        └── top_customers


The published table should contain six records.

Screenshot
images/13-test-lakehouse-results.png


This is one of the most important pieces of evidence in the lab.

The target originally contained no tables.

The Deployment Plan executed:

Hydrate_TopCustomers
        ↓
Publish_TopCustomers


which generated those tables in the target environment.

26. Verify Notebook Execution in Fabric Monitor

Open Monitor.

The notebook executions should show:

Hydrate_TopCustomers     Succeeded
Publish_TopCustomers     Succeeded


with the execution location:

ram-test

Screenshot
images/14-monitor-notebook-runs.png


This proves that the notebooks actually executed in the Test workspace as Deployment Plan actions.

27. Final Warehouse Validation

Open:

ram-test
    ↓
Sales_Warehouse


Run:

SELECT *
FROM dbo.vw_top_customers
ORDER BY total_sales DESC;


Expected result:

1001  Contoso Ltd            United States   125000
1002  Fabrikam Inc           United States    98500
1003  Adventure Works        Canada           87500
1004  Northwind Traders      United Kingdom   76000
1005  Wide World Importers   Australia        69000
1006  Tailspin Toys          United States    54000


Successful execution proves the complete dependency chain:

Hydrate
   ↓
dev_top_customers
   ↓
Publish
   ↓
top_customers
   ↓
Warehouse deployment
   ↓
vw_top_customers
   ↓
SUCCESS

28. What This Exercise Demonstrates

This exercise highlights an important difference between three concepts.

Deployment dependency

Controls which Fabric item must deploy before another item.

Example:

Sales_Lakehouse
        ↓
Sales_Warehouse

Runtime/data dependency

Represents data that must actually exist before a downstream object can work.

Example:

dbo.top_customers
        ↓
dbo.vw_top_customers

Deployment action

Executes the workload required to satisfy the runtime dependency.

Example:

Hydrate_TopCustomers
        ↓
Publish_TopCustomers


The final orchestration combines all three:

DEPLOYMENT
    │
    ▼
Sales_Lakehouse
    │
    ▼
ACTION
Hydrate_TopCustomers
    │
    ▼
dbo.dev_top_customers
    │
    ▼
ACTION
Publish_TopCustomers
    │
    ▼
dbo.top_customers
    │
    ▼
DEPLOYMENT
Sales_Warehouse
    │
    ▼
dbo.vw_top_customers

29. Key Lessons Learned
1. Deployment does not imply data population

Deploying a Lakehouse does not mean the runtime-created Delta tables/data will automatically appear in a clean destination.

2. Lineage/dependency alone may not solve runtime prerequisites

Fabric can understand item relationships, but runtime data may still need to be produced before a downstream item becomes valid.

3. Deployment Plans add orchestration

A Deployment Plan provides explicit control over:

Deployment
    ↓
Action
    ↓
Action
    ↓
Deployment


Deployment Plans support deployment groups plus pre-deployment and post-deployment actions.

4. Notebook actions should bind to the target environment

Notebook Git binding is important so a deployed notebook references the corresponding Lakehouse in the destination workspace rather than the Development resource. Fabric uses logical identifiers to support this binding behavior.

5. Action completion does not guarantee downstream readiness

A deployment-plan action completes when the action item's run finishes. If a downstream system needs additional synchronization time, the readiness logic should be handled inside the action itself.

6. dependsOn controls execution order

The ordering in plan.yml is not merely visual. Dependencies explicitly determine the execution relationship:

dependsOn:


This applies both to action dependencies and group dependencies.

30. Final Architecture
                     MICROSOFT FABRIC

┌──────────────────────────────────────────────────────┐
│                    ram-dev                           │
│                                                      │
│  Sales_Lakehouse                                     │
│       │                                              │
│       ├── dbo.dev_top_customers                      │
│       └── dbo.top_customers                          │
│                                                      │
│  Hydrate_TopCustomers                                │
│  Publish_TopCustomers                                │
│                                                      │
│  Sales_Warehouse                                     │
│       └── dbo.vw_top_customers                       │
│                                                      │
│  Sales_Deployment_Plan                               │
└─────────────────────────┬────────────────────────────┘
                          │
                          │ Deployment Pipeline
                          │ + Deployment Plan
                          ▼
┌──────────────────────────────────────────────────────┐
│                    ram-test                          │
│                                                      │
│  Sales_Lakehouse                                     │
│       │                                              │
│       ├── dbo.dev_top_customers                      │
│       └── dbo.top_customers                          │
│                                                      │
│  Hydrate_TopCustomers     [Executed]                 │
│  Publish_TopCustomers     [Executed]                 │
│                                                      │
│  Sales_Warehouse                                     │
│       └── dbo.vw_top_customers                       │
└──────────────────────────────────────────────────────┘

31. Screenshot Directory

For a clean GitHub repository, store the screenshots under:

images/


Recommended naming:

images/
├── 01-hydrate-top-customers.png
├── 02-publish-readiness-check.png
├── 03-cross-database-query.png
├── 04-warehouse-view-results.png
├── 05-workspace-lineage.png
├── 06-azure-devops-repository.png
├── 07-sales-deployment-plan.png
├── 08-plan-yaml.png
├── 09-empty-test-workspace.png
├── 10-deployment-pipeline.png
├── 11-select-deployment-plan.png
├── 12-deployment-items.png
├── 13-test-lakehouse-results.png
└── 14-monitor-notebook-runs.png


Then GitHub Markdown automatically renders, for example:

## Deployment Plan

images/07-sales-deployment-plan.png

References
Microsoft Learn: Deployment plan examples in Microsoft Fabric. This lesson follows the "deploy an item that depends on data another item produces" pattern.
Microsoft Learn: Create a deployment plan in Microsoft Fabric. Deployment plans define deployment groups, dependencies, and pre/post deployment actions and can be used with deployment pipelines.
Microsoft Learn: Notebook source control and deployment. Notebook dependencies can use logical identifiers to support binding to corresponding resources in another workspace.
Microsoft Learn: Lakehouse Git integration and deployment pipelines. Lakehouse tables themselves are not Git-tracked as table data.
Microsoft Learn: Cross-Warehouse Query. Fabric supports three-part naming for cross-database queries.
Summary

In this hands-on lesson, we built a complete Microsoft Fabric CI/CD scenario where a Warehouse depends on a Lakehouse table that does not exist merely because the Lakehouse was deployed.

The solution used a Deployment Plan to guarantee:

Deploy Lakehouse
      ↓
Hydrate data
      ↓
Publish data
      ↓
Wait for readiness
      ↓
Deploy Warehouse
      ↓
Query Warehouse view successfully


The key takeaway is:

Deployment dependencies control when items deploy. Deployment actions control the runtime work that must happen between those deployments.

That distinction is what makes Deployment Plans useful for Fabric solutions containing runtime data dependencies.
