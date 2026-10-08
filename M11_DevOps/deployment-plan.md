# Microsoft Fabric Deployment Plan: End-to-End Lakehouse to Warehouse Deployment

## Overview

This hands-on lesson demonstrates how to use a Microsoft Fabric Deployment Plan to deploy a solution in which a downstream Warehouse object depends on data that must first be produced in a Lakehouse.

The solution uses:

- Development workspace: `ram-dev`
- Test workspace: `ram-test`
- `Sales_Lakehouse`
- `Hydrate_TopCustomers` notebook
- `Publish_TopCustomers` notebook
- `Sales_Warehouse`
- `dbo.vw_top_customers` Warehouse view
- `Sales_Deployment_Plan`
- A Fabric deployment pipeline from Dev to Test
- Azure DevOps Git integration for the development workspace

The central lesson is that deployment order by itself is not always sufficient. The Lakehouse definition can deploy before the Warehouse, but the Warehouse view also requires `dbo.top_customers` to exist at runtime. The deployment plan solves this by executing the notebooks after the Lakehouse deploys and before the Warehouse deploys.

---

## 1. Target Architecture

The runtime data flow is:

```text
Hydrate_TopCustomers
        |
        | writes
        v
dbo.dev_top_customers
        |
        | read by
        v
Publish_TopCustomers
        |
        | publishes
        v
dbo.top_customers
        |
        | read by
        v
dbo.vw_top_customers
```

The containment relationships are:

```text
Sales_Lakehouse
|-- dbo.dev_top_customers
`-- dbo.top_customers

Sales_Warehouse
`-- dbo.vw_top_customers
```

The required deployment sequence is:

```text
Deploy Sales_Lakehouse
        |
        v
Run Hydrate_TopCustomers
        |
        v
Run Publish_TopCustomers
        |
        v
Complete Sales_Lakehouse deployment group
        |
        v
Deploy Sales_Warehouse
```

---

## 2. Environment

This lesson uses two Fabric workspaces.

### Development

```text
ram-dev
```

`ram-dev` is connected to an Azure DevOps repository.

### Test

```text
ram-test
```

`ram-test` is the clean target workspace used to validate deployment.

The deployment pipeline maps the environments as follows:

```text
Dev                         Test
ram-dev  ---------------->  ram-test
```

---

## 3. Create the Development Artifacts

Create the following Fabric items in `ram-dev`:

```text
ram-dev
|-- Sales_Lakehouse
|-- Hydrate_TopCustomers
|-- Publish_TopCustomers
|-- Sales_Warehouse
`-- Sales_Deployment_Plan
```

Do not manually create the Lakehouse tables in the Test workspace. The notebooks are responsible for producing the tables during deployment.

---

## 4. Create `Sales_Lakehouse`

Create a Fabric Lakehouse named:

```text
Sales_Lakehouse
```

Initially, leave the Lakehouse empty.

The notebooks will later create:

```text
dbo.dev_top_customers
dbo.top_customers
```

---

## 5. Create `Hydrate_TopCustomers`

Create a Fabric notebook named:

```text
Hydrate_TopCustomers
```

Attach `Sales_Lakehouse` as its default Lakehouse.

The purpose of this notebook is to create the source customer dataset and save it as `dbo.dev_top_customers`.

### 5.1 Create the sample source data

```python
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
```

Expected result: 10 customer records.

### 5.2 Add load metadata

```python
df = df.withColumn(
    "loaded_at",
    F.current_timestamp()
)

display(df)
```

The resulting columns are:

```text
customer_id
customer_name
country
total_sales
loaded_at
```

### 5.3 Write `dev_top_customers`

```python
df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("dev_top_customers")
```

Verify the table:

```python
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
```

The Lakehouse should now contain:

```text
Sales_Lakehouse
`-- Tables
    `-- dbo
        `-- dev_top_customers
```

---

## 6. Configure Notebook Git Binding

For each notebook, configure the Git binding so the notebook uses the corresponding Lakehouse in the destination workspace.

Apply the setting to:

```text
Hydrate_TopCustomers
Publish_TopCustomers
```

Use:

```text
Git settings
  -> Git binding
     -> Lakehouse in new workspace
```

The desired behavior after deployment is:

```text
ram-test
|-- Sales_Lakehouse
|-- Hydrate_TopCustomers ----> ram-test/Sales_Lakehouse
`-- Publish_TopCustomers ----> ram-test/Sales_Lakehouse
```

The notebooks should not continue referencing the Development Lakehouse after deployment.

---

## 7. Create `Publish_TopCustomers`

Create another notebook named:

```text
Publish_TopCustomers
```

Attach `Sales_Lakehouse` as the default Lakehouse.

This notebook reads the hydrated table, identifies top customers, and creates the published table.

The processing chain is:

```text
dbo.dev_top_customers
        |
        v
Publish_TopCustomers
        |
        v
dbo.top_customers
```

### 7.1 Read the hydrated table

```python
source_df = spark.table("dbo.dev_top_customers")

display(source_df)
```

Expected result: 10 records.

### 7.2 Select top customers

For this exercise, define a top customer as a customer whose total sales are at least 50,000.

```python
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
```

Expected customers:

```text
1001  Contoso Ltd
1002  Fabrikam Inc
1003  Adventure Works
1004  Northwind Traders
1005  Wide World Importers
1006  Tailspin Toys
```

Expected count: 6 rows.

### 7.3 Write `dbo.top_customers`

```python
top_customers_df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("dbo.top_customers")
```

Verify the published table:

```python
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
```

The Lakehouse should now contain:

```text
Sales_Lakehouse
`-- Tables
    `-- dbo
        |-- dev_top_customers
        `-- top_customers
```

---

## 8. Add a Readiness Check to `Publish_TopCustomers`

The Warehouse deployment must not begin before `dbo.top_customers` is available.

Add the following as the final cell of `Publish_TopCustomers`.

```python
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
```

Expected output:

```text
dbo.top_customers is available with 6 rows.
Waiting 30 seconds for SQL analytics endpoint metadata synchronization...
Publish_TopCustomers completed successfully.
```

> **Important:** The table polling in this lab verifies the Spark table. The 30-second wait is a synchronization buffer for the SQL analytics endpoint. For production workloads, prefer a deterministic readiness test against the downstream system instead of relying only on a fixed delay.

---

## 9. Validate the Lakehouse SQL Analytics Endpoint

Open the SQL analytics endpoint associated with `Sales_Lakehouse`.

Run:

```sql
SELECT *
FROM dbo.top_customers
ORDER BY total_sales DESC;
```

Expected result: 6 rows.

This validates the path:

```text
Spark write
    |
    v
Delta table
    |
    v
Lakehouse SQL analytics endpoint
```

---

## 10. Create `Sales_Warehouse`

Create a Fabric Warehouse named:

```text
Sales_Warehouse
```

Do not create another physical copy of `top_customers` inside the Warehouse.

The target architecture is:

```text
Sales_Lakehouse
`-- dbo.top_customers
        |
        | read by
        v
Sales_Warehouse
`-- dbo.vw_top_customers
```

---

## 11. Add the Lakehouse SQL Endpoint to the Warehouse Explorer

Open `Sales_Warehouse`.

In Explorer, select:

```text
+ Warehouses
```

Add the SQL analytics endpoint associated with `Sales_Lakehouse`.

The Explorer should show both objects:

```text
Sales_Warehouse
`-- Schemas
    `-- dbo

Sales_Lakehouse
`-- Schemas
    `-- dbo
        |-- dev_top_customers
        `-- top_customers
```

---

## 12. Test the Cross-Database Query

From `Sales_Warehouse`, run:

```sql
SELECT *
FROM [Sales_Lakehouse].[dbo].[top_customers]
ORDER BY total_sales DESC;
```

Expected result: 6 rows.

This validates that the Warehouse can read the Lakehouse table using three-part naming:

```text
database.schema.object
```

In this example:

```text
Sales_Lakehouse.dbo.top_customers
```

---

## 13. Create `dbo.vw_top_customers`

Create the Warehouse view:

```sql
CREATE VIEW dbo.vw_top_customers
AS
SELECT
    customer_id,
    customer_name,
    country,
    total_sales
FROM [Sales_Lakehouse].[dbo].[top_customers];
```

Validate the view:

```sql
SELECT *
FROM dbo.vw_top_customers
ORDER BY total_sales DESC;
```

Expected result: 6 rows.

The completed Development dependency chain is:

```text
Hydrate_TopCustomers
        |
        | writes
        v
dbo.dev_top_customers
   Sales_Lakehouse
        |
        | read by
        v
Publish_TopCustomers
        |
        | publishes
        v
dbo.top_customers
   Sales_Lakehouse
        |
        | read by
        v
dbo.vw_top_customers
   Sales_Warehouse
```

---

## 14. Commit the Fabric Items to Azure DevOps

Save and commit the Fabric items from `ram-dev` to Azure DevOps.

The repository will contain item definitions similar to:

```text
Hydrate_TopCustomers.Notebook/
|-- .platform
|-- notebook-content.py
`-- notebook-settings.json

Publish_TopCustomers.Notebook/
|-- .platform
|-- notebook-content.py
`-- notebook-settings.json

Sales_Lakehouse.Lakehouse/
|-- .platform
|-- alm.settings.json
|-- lakehouse.metadata.json
`-- shortcuts.metadata.json

Sales_Warehouse.Warehouse/
|-- dbo/
|   `-- Views/
|       `-- vw_top_customers.sql
|-- .gitignore
|-- .platform
`-- Sales_Warehouse.sqlproj
```

An important observation is that the runtime-created Lakehouse tables are not represented like the Warehouse view definition.

This is precisely why the notebooks must execute in the target environment.

---

## 15. Understand Why an Ordinary Deployment Is Not Enough

Consider an empty target workspace.

If the deployment only copied item definitions, the flow would effectively be:

```text
Deploy Sales_Lakehouse
        |
        v
Sales_Lakehouse exists
        |
        v
dbo.top_customers does not yet exist
        |
        v
Deploy Sales_Warehouse
        |
        v
Attempt to create dbo.vw_top_customers
        |
        v
View references a table that has not yet been produced
        |
        v
Potential deployment failure
```

The important distinction is:

> Deployment order answers which item deploys first. It does not necessarily perform the runtime work required to make the next item valid.

For this solution, runtime work must occur between the Lakehouse and Warehouse deployments.

---

## 16. Create `Sales_Deployment_Plan`

Create a Fabric Deployment Plan named:

```text
Sales_Deployment_Plan
```

The plan contains two deployment groups.

---

## 17. Configure the `Sales_Lakehouse` Deployment Group

Add `Sales_Lakehouse` as the first deployment group.

The group deploys:

```text
Sales_Lakehouse
```

Add two **After** actions:

```text
Hydrate_TopCustomers
Publish_TopCustomers
```

Configure the action dependency so that:

```text
Hydrate_TopCustomers
        |
        v
Publish_TopCustomers
```

`Publish_TopCustomers` must not start until `Hydrate_TopCustomers` has finished.

The group is logically:

```text
GROUP: Sales_Lakehouse

Deploy
`-- Sales_Lakehouse

After
|-- Hydrate_TopCustomers
|       |
|       v
`-- Publish_TopCustomers
```

---

## 18. Configure the `Sales_Warehouse` Deployment Group

Add `Sales_Warehouse` as the second deployment group.

The group deploys:

```text
Sales_Warehouse
```

Connect the groups so that:

```text
Sales_Lakehouse group
        |
        v
Sales_Warehouse group
```

The Warehouse group depends on completion of the entire Lakehouse group, including both post-deployment notebook actions.

The complete plan is:

```text
+--------------------------------------+
| GROUP: Sales_Lakehouse               |
|                                      |
| Deploy Sales_Lakehouse               |
|          |                           |
|          v                           |
| Run Hydrate_TopCustomers             |
|          |                           |
|          v                           |
| Run Publish_TopCustomers             |
+-------------------+------------------+
                    |
                    v
+--------------------------------------+
| GROUP: Sales_Warehouse               |
|                                      |
| Deploy Sales_Warehouse               |
+--------------------------------------+
```

Save the Deployment Plan.

---

## 19. Commit the Deployment Plan to Git

Commit `Sales_Deployment_Plan` from `ram-dev` to Azure DevOps.

The repository should contain:

```text
Sales_Deployment_Plan.DeploymentPlan/
|-- .platform
`-- plan.yml
```

The generated `plan.yml` follows this logical structure:

```yaml
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
```

There are two important dependency levels.

### Action dependency

```text
Publish_TopCustomers
        |
        | dependsOn
        v
Hydrate_TopCustomers
```

### Group dependency

```text
Sales_Warehouse
        |
        | dependsOn
        v
Sales_Lakehouse
```

The execution order is determined by these dependency relationships.

---

## 20. Prepare the Test Workspace

Use the target workspace:

```text
ram-test
```

Before deployment, keep the workspace empty.

Do not manually create:

```text
Sales_Lakehouse
Hydrate_TopCustomers
Publish_TopCustomers
Sales_Warehouse
dbo.dev_top_customers
dbo.top_customers
dbo.vw_top_customers
```

The empty target is important because it proves that the deployment and Deployment Plan create the required solution.

---

## 21. Configure the Deployment Pipeline

Use the Fabric deployment pipeline:

```text
ram-deployment-pipeline
```

Map the stages as:

```text
Dev                         Test
ram-dev  ---------------->  ram-test
```

---

## 22. Select the Deployment Plan During Deployment

Start a deployment from Dev to Test.

Configure:

```text
Deploy from: Dev
Target:      Test
With plan:   Sales_Deployment_Plan
```

Selecting the Deployment Plan is critical because the plan contains the notebook execution actions and required ordering.

The deployment selection contains the solution items, including:

```text
Deployment Plan
Lakehouse
Notebook
Notebook
Warehouse
```

For a clean Test environment, the items initially appear only in the source environment.

Start the deployment.

---

## 23. Expected Deployment Execution

The deployment should execute logically as follows:

```text
ram-dev
   |
   v
Deploy Sales_Lakehouse into ram-test
   |
   v
Run Hydrate_TopCustomers in ram-test
   |
   v
Create dbo.dev_top_customers
   |
   v
Run Publish_TopCustomers in ram-test
   |
   v
Create dbo.top_customers
   |
   v
Perform readiness/synchronization wait
   |
   v
Complete Sales_Lakehouse group
   |
   v
Deploy Sales_Warehouse
   |
   v
Create dbo.vw_top_customers
   |
   v
Deployment complete
```

The two notebooks are actions within the Lakehouse deployment group. They are not separate deployment groups.

---

## 24. Validate the Lakehouse in `ram-test`

After deployment, open:

```text
ram-test
  -> Sales_Lakehouse
```

The Lakehouse should now contain:

```text
Sales_Lakehouse
`-- Tables
    `-- dbo
        |-- dev_top_customers
        `-- top_customers
```

Expected counts:

```text
dbo.dev_top_customers = 10 rows
dbo.top_customers     = 6 rows
```

The existence of these tables demonstrates that the notebook actions ran in the target environment.

---

## 25. Validate Notebook Execution in Fabric Monitor

Open Fabric Monitor and locate the notebook activities.

Expected results:

```text
Hydrate_TopCustomers     Succeeded
Publish_TopCustomers     Succeeded
```

The execution location should be:

```text
ram-test
```

This is important evidence that the Deployment Plan executed the notebooks in the target workspace rather than merely copying notebook definitions.

---

## 26. Validate the Warehouse View

Open:

```text
ram-test
  -> Sales_Warehouse
```

Run:

```sql
SELECT *
FROM dbo.vw_top_customers
ORDER BY total_sales DESC;
```

Expected result:

```text
1001  Contoso Ltd           United States   125000
1002  Fabrikam Inc          United States    98500
1003  Adventure Works       Canada           87500
1004  Northwind Traders     United Kingdom   76000
1005  Wide World Importers  Australia        69000
1006  Tailspin Toys         United States    54000
```

If this query succeeds, the complete deployment chain has been validated.

```text
Hydrate_TopCustomers
        |
        v
dbo.dev_top_customers
        |
        v
Publish_TopCustomers
        |
        v
dbo.top_customers
        |
        v
Deploy Sales_Warehouse
        |
        v
dbo.vw_top_customers
        |
        v
SUCCESS
```

---

## 27. Key Concepts Demonstrated

### 27.1 Containment

Containment describes which Fabric item owns an object.

```text
Sales_Lakehouse
|-- dbo.dev_top_customers
`-- dbo.top_customers

Sales_Warehouse
`-- dbo.vw_top_customers
```

Containment is not the same as a data dependency.

### 27.2 Data dependency

A data dependency describes which object requires data from another object.

```text
dbo.dev_top_customers
        |
        v
Publish_TopCustomers
```

and:

```text
dbo.top_customers
        |
        v
dbo.vw_top_customers
```

### 27.3 Deployment dependency

A deployment dependency controls which deployment group must complete before another group starts.

```text
Sales_Lakehouse group
        |
        v
Sales_Warehouse group
```

### 27.4 Deployment action

A deployment action executes runtime work before or after an item deploys.

In this lesson:

```text
Post-deploy action 1: Hydrate_TopCustomers
Post-deploy action 2: Publish_TopCustomers
```

### 27.5 Action dependency

The second notebook depends on the first notebook.

```text
Hydrate_TopCustomers
        |
        v
Publish_TopCustomers
```

### 27.6 Readiness is different from job completion

A notebook finishing does not always mean every downstream service has immediately synchronized its metadata.

The desired pattern is:

```text
Write table
    |
    v
Verify readiness
    |
    v
Finish action
    |
    v
Start dependent deployment
```

---

## 28. What the Deployment Plan Solves

Without the Deployment Plan:

```text
Deploy Lakehouse
    |
    v
Lakehouse definition exists
    |
    v
Required runtime table is missing
    |
    v
Deploy Warehouse
    |
    v
Warehouse view depends on missing table
    |
    v
Deployment can fail
```

With the Deployment Plan:

```text
Deploy Lakehouse
    |
    v
Run Hydrate notebook
    |
    v
Create staging table
    |
    v
Run Publish notebook
    |
    v
Create published table
    |
    v
Wait for readiness
    |
    v
Deploy Warehouse
    |
    v
Create dependent view
    |
    v
SUCCESS
```

This is the main lesson:

> **Deployment dependencies control when Fabric items deploy. Deployment actions perform the runtime work required between those deployments.**

---

## 29. Final Architecture

```text
+------------------------------------------------------+
|                      ram-dev                         |
|                                                      |
|  Sales_Lakehouse                                     |
|  |-- dbo.dev_top_customers                           |
|  `-- dbo.top_customers                               |
|                                                      |
|  Hydrate_TopCustomers                                |
|  Publish_TopCustomers                                |
|                                                      |
|  Sales_Warehouse                                     |
|  `-- dbo.vw_top_customers                            |
|                                                      |
|  Sales_Deployment_Plan                               |
+--------------------------+---------------------------+
                           |
                           | Deployment Pipeline
                           | + Deployment Plan
                           v
+------------------------------------------------------+
|                      ram-test                        |
|                                                      |
|  Sales_Lakehouse                                     |
|  |-- dbo.dev_top_customers                           |
|  `-- dbo.top_customers                               |
|                                                      |
|  Hydrate_TopCustomers      [executed]                |
|  Publish_TopCustomers      [executed]                |
|                                                      |
|  Sales_Warehouse                                     |
|  `-- dbo.vw_top_customers                            |
+------------------------------------------------------+
```

---

## 30. End-to-End Checklist

### Development

- [ ] Create `Sales_Lakehouse`.
- [ ] Create `Hydrate_TopCustomers`.
- [ ] Attach `Sales_Lakehouse` as the default Lakehouse.
- [ ] Configure Git binding to use the Lakehouse in the new workspace.
- [ ] Create and validate `dbo.dev_top_customers`.
- [ ] Create `Publish_TopCustomers`.
- [ ] Attach `Sales_Lakehouse` as the default Lakehouse.
- [ ] Configure Git binding to use the Lakehouse in the new workspace.
- [ ] Create and validate `dbo.top_customers`.
- [ ] Add the readiness logic.
- [ ] Validate the Lakehouse SQL analytics endpoint.
- [ ] Create `Sales_Warehouse`.
- [ ] Add the Lakehouse SQL endpoint to Warehouse Explorer.
- [ ] Validate the cross-database query.
- [ ] Create `dbo.vw_top_customers`.
- [ ] Validate the Warehouse view.
- [ ] Commit all item definitions to Azure DevOps.

### Deployment Plan

- [ ] Create `Sales_Deployment_Plan`.
- [ ] Add the `Sales_Lakehouse` deployment group.
- [ ] Add `Hydrate_TopCustomers` as an After action.
- [ ] Add `Publish_TopCustomers` as an After action.
- [ ] Make Publish depend on Hydrate.
- [ ] Add the `Sales_Warehouse` deployment group.
- [ ] Make the Warehouse group depend on the Lakehouse group.
- [ ] Save the plan.
- [ ] Commit the plan to Azure DevOps.
- [ ] Review `plan.yml`.

### Test Deployment

- [ ] Start with an empty `ram-test` workspace.
- [ ] Confirm the deployment pipeline maps `ram-dev` to `ram-test`.
- [ ] Start the Dev-to-Test deployment.
- [ ] Select `Sales_Deployment_Plan`.
- [ ] Deploy the solution.
- [ ] Verify `dbo.dev_top_customers` exists in Test.
- [ ] Verify `dbo.top_customers` exists in Test.
- [ ] Verify both notebooks succeeded in Fabric Monitor.
- [ ] Verify notebook execution occurred in `ram-test`.
- [ ] Verify `dbo.vw_top_customers` exists in `Sales_Warehouse`.
- [ ] Query the final view and confirm six rows.

---

## 31. References

Microsoft Learn documentation used as the basis for this exercise:

- Deployment plan examples in Microsoft Fabric: <https://learn.microsoft.com/en-us/fabric/cicd/deployment-plan/deployment-plan-sample-plans>
- Create a deployment plan in Microsoft Fabric: <https://learn.microsoft.com/en-us/fabric/cicd/deployment-plan/how-to-create-deployment-plan>
- Notebook source control and deployment: <https://learn.microsoft.com/en-us/fabric/data-engineering/notebook-source-control-deployment>
- Lakehouse Git integration and deployment pipelines: <https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-git-deployment-pipelines>
- Query the Warehouse or SQL analytics endpoint: <https://learn.microsoft.com/en-us/fabric/data-warehouse/query-warehouse>
- Cross-Warehouse Query tutorial: <https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-sql-cross-warehouse-query-editor>

---

## Summary

In this lesson, we built and deployed a Fabric solution where a Warehouse view depends on a Lakehouse table that must be produced at runtime.

The final orchestration was:

```text
Deploy Sales_Lakehouse
        |
        v
Run Hydrate_TopCustomers
        |
        v
Create dbo.dev_top_customers
        |
        v
Run Publish_TopCustomers
        |
        v
Create dbo.top_customers
        |
        v
Wait for readiness
        |
        v
Deploy Sales_Warehouse
        |
        v
Create dbo.vw_top_customers
        |
        v
Validate in ram-test
```

The most important takeaway is:

> **Use a Fabric Deployment Plan when successful deployment requires runtime actions to execute between dependent item deployments.**
