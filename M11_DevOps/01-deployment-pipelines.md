Let us implement CICD as for below document and diagram

https://learn.microsoft.com/en-us/fabric/cicd/manage-deployment#option-3---deploy-using-fabric-deployment-pipelines

<img width="878" height="396" alt="image" src="https://github.com/user-attachments/assets/26550c0b-7fb1-4b29-966e-dc6750ae83fe" />



# Step 1: Create required workspaces
- Follow the naming standard and create three workspaces: `ws_{project}_{env}`
  - `ws_sales_dev`
  - `ws_sales_test`
  - `ws_sales_prod`

  <img width="676" height="885" alt="image" src="https://github.com/user-attachments/assets/67c47664-2418-43f0-b1ba-e5e58c2bcbfc" />

# Step 2: Create DevOps objects
- Follow the naming standard and create an organization: `org_{lob}`
  - `org_sales`
- Create a project following the naming standard: `proj_{lob}`
  - `proj_sales`
- Create a repository following the naming standard: `repo_{lob}`
  - `repo_sales`
- Use the default branch for the development environment: `main`.

**Note:** Do not create the feature branch manually; it is created as part of the branch-out flow.
- Feature branch naming standard: `feature/{developername}` (example: `feature/ram`).

# Step 3: Map workspace and Git repo
- Map the development workspace `ws_sales_dev` to the Git repository and the `main` branch.

<img width="1746" height="847" alt="image" src="https://github.com/user-attachments/assets/614dab6c-8229-40ac-a5e5-3f4b22274255" />


# Step 4: Create lakehouse
- Create a lakehouse: `lh_{project}`
  - `lh_sales`
- Copy the lakehouse URL for reference. Example:

  https://app.powerbi.com/groups/a7b03bc3-aab2-44cc-86c8-85e382d15370/lakehouses/b35da3f1-ee6b-400b-b1ce-3caed24d0802?experience=fabric-developer

- From the URL you can extract:
  - workspace id: `a7b03bc3-aab2-44cc-86c8-85e382d15370`
  - lakehouse id: `b35da3f1-ee6b-400b-b1ce-3caed24d0802`


# Step 5: Create deployment pipeline
- Create a deployment pipeline and name it `dp_sales`.

  <img width="747" height="446" alt="image" src="https://github.com/user-attachments/assets/3d3e1704-8e35-458b-a5f0-87213c6386fd" />

- By default three stages are created: Dev, Test, Prod.

  <img width="1201" height="274" alt="image" src="https://github.com/user-attachments/assets/fbff6342-9b4b-42b4-a4d4-1ef9280537aa" />

- Map each stage to its respective workspace.

  <img width="1218" height="234" alt="image" src="https://github.com/user-attachments/assets/9d89661c-ac78-4ae9-b3aa-ed46cd4c4570" />

1. Select the Test stage, review object differences, select all objects, and click Deploy.
2. After deployment, Dev and Test stages should be in sync (indicated by green status).
3. In the Test workspace, open the lakehouse and copy the URL; note the Workspace ID and Lakehouse ID. Example:
   - URL: https://app.powerbi.com/groups/048e68c9-dd2f-44cf-8b71-b869b44bfb10/lakehouses/23642408-0a80-4b96-970d-a74ac5469c7f?experience=fabric-developer
   - Workspace id: `048e68c9-dd2f-44cf-8b71-b869b44bfb10`
   - Lakehouse id: `23642408-0a80-4b96-970d-a74ac5469c7f`
4. Deploy from Test to Prod and copy the Prod lakehouse URL. Example:
   - URL: https://app.powerbi.com/groups/74dbb2ab-dca0-49a8-bfeb-68c563a5c96b/lakehouses/1f4c5ccb-d8a4-424d-bcc5-e3bd486c24a7?experience=fabric-developer
   - Workspace id: `74dbb2ab-dca0-49a8-bfeb-68c563a5c96b`
   - Lakehouse id: `1f4c5ccb-d8a4-424d-bcc5-e3bd486c24a7`

# Step 6: Branch out to a workspace
- As a developer, create your own workspace and Git branch:
  - Workspace: `ws_sales_ram`
  - Git branch: `feature/ram`
- Process: Click Source control > Git icon > dropdown > Branch out to workspace, provide the names and confirm.
- Note the lakehouse URL created for the branched workspace. Example:
  - URL: https://app.powerbi.com/groups/aa27dd33-f0c7-4a59-b615-0df0c3765902/lakehouses/c337adb3-8601-46a9-b603-8791b5d68366?experience=fabric-developer
  - workspace id: `aa27dd33-f0c7-4a59-b615-0df0c3765902`
  - lakehouse id: `c337adb3-8601-46a9-b603-8791b5d68366`

# Step 6.1: Create a Pipeline and prompt upto production
- WIP

# Step 6.2: Create a Notebook and prompt upto production
- WIP

# Step 7: Create a variable library
- Variable libraries are useful in CI/CD processes.
- Create a variable library named `vl_sales` and save it.

<img width="1916" height="633" alt="image" src="https://github.com/user-attachments/assets/502a3e17-735e-49b5-abb4-bf4fe3cec8a7" />

1. Commit code to your feature branch and ensure the variable library object is present in `feature/ram`.
2. Raise a pull request from `feature/ram` to `main`.
3. Complete the merge and confirm the `main` branch contains the variable library object.
4. Open the workspace `ws_sales_dev`, go to Source control > Update all, and confirm the variable library object is available in `ws_sales_dev`.
5. In the Dev workspace, select the variable library and click Set as active.

<img width="1903" height="570" alt="image" src="https://github.com/user-attachments/assets/3482c74e-a480-4709-b02d-50c45572a686" />

6. Using the Deployment pipeline, deploy the variable library `vl_sales` from Dev -> Test -> Prod.
7. In `ws_sales_test`, open the variable library and click Set as active.

<img width="1915" height="570" alt="image" src="https://github.com/user-attachments/assets/1507f917-ba19-4206-a996-f96ec249e6e7" />

8. In `ws_sales_prod`, open the variable library and click Set as active.

<img width="1903" height="570" alt="image" src="https://github.com/user-attachments/assets/611d3449-4521-43f0-a681-875b158de2e7" />

<img width="1903" height="570" alt="image" src="https://github.com/user-attachments/assets/611d3449-4521-43f0-a681-875b158de2e7" />

# Optional

## Step 8: Create a metadata-driven framework for ingestion

1. Create one notebook that holds required metadata. If it contains too many entries, split into three notebooks and call them from a bootstrap notebook.
    - Create a schema for the metadata.
    - Create DDL scripts for tables.
    - Insert metadata rows using MERGE so duplicate inserts are skipped.
    - Call the three notebooks from a bootstrap notebook if you split them.
   
In my training room, instead of four notebooks above I used this [single notebook](https://github.com/rritec/Microsoft-Fabric/blob/main/M03_Data%20Pipelines(Azure%20Data%20Factory)/nb_Metadata_Configuration.ipynb).

## Step 9: Add required variables in the variable library

1. Open the variable library and add variables as needed. Example:

    <img width="1692" height="470" alt="image" src="https://github.com/user-attachments/assets/ee3447b7-6e65-492a-a194-86d79d37d7ee" />

## Step 10: Create master ingestion pipeline

1. Create the pipeline using this [JSON file](https://github.com/rritec/Microsoft-Fabric/blob/main/M03_Data%20Pipelines(Azure%20Data%20Factory)/master_ingestion_pipeline.json).
2. Run the pipeline and validate results.



