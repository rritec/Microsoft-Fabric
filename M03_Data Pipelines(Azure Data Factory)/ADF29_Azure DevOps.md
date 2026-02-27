# Step 1: Create Required workspaces
1. Follow the naming standard and create three work spaces ws_{project}_{env}
    1. ws_sales_dev
    2. ws_sales_test
    3. ws_sales_prod

    <img width="676" height="885" alt="image" src="https://github.com/user-attachments/assets/67c47664-2418-43f0-b1ba-e5e58c2bcbfc" />

# Step 2: Create DevOps objects
1. Follow the naming standard and create organization name org_{lob}
    1. org_sales
1. Follow the naming standard and create projects name proj_{lob}
    1. proj_sales
1. Follow the naming standard and create repository name repo_{lob}
    1. repo_sales
1. use default branch for the dev enviornment . default branch is main.
    1. main
    
**Note:** do not create below branch manually
1. create feature branch with the naming standard as feature/{developername}.
    1. feature/ram

# Step 3: Map Workspace and git Repo
1.  developent workspace ws_sales_dev map with git repo and main branch

<img width="1746" height="847" alt="image" src="https://github.com/user-attachments/assets/614dab6c-8229-40ac-a5e5-3f4b22274255" />


# Step 4: Create lakehouse
1. create lakehouse lh_{project}
    1. lh_sales
    2. copy the lakehouse url for ref https://app.powerbi.com/groups/a7b03bc3-aab2-44cc-86c8-85e382d15370/lakehouses/b35da3f1-ee6b-400b-b1ce-3caed24d0802?experience=fabric-developer
    3. by observing above url
        1. workspace id: a7b03bc3-aab2-44cc-86c8-85e382d15370
        2. lakehouse id: b35da3f1-ee6b-400b-b1ce-3caed24d0802
    4. 
    
# Step 5: Create Deployment Pipeline
1. create deployment pipeline and name it as **dp_sales**
<img width="747" height="446" alt="image" src="https://github.com/user-attachments/assets/3d3e1704-8e35-458b-a5f0-87213c6386fd" />

2. By default three stages will be created those are Dev/Test/prod
<img width="1201" height="274" alt="image" src="https://github.com/user-attachments/assets/fbff6342-9b4b-42b4-a4d4-1ef9280537aa" />

3. Map each stage with respective workspace
<img width="1218" height="234" alt="image" src="https://github.com/user-attachments/assets/9d89661c-ac78-4ae9-b3aa-ed46cd4c4570" />

4. Select Test Stage and observe the difference of objects > Select all objects > click on deploy
5. Now Dev and Test Stages should be on same page and you should see green color
6. Go to Test workspace and observe lakehouse and click on lakehouse and observe the URL and note down Workspace id/Lakehouse ID
    1. https://app.powerbi.com/groups/048e68c9-dd2f-44cf-8b71-b869b44bfb10/lakehouses/23642408-0a80-4b96-970d-a74ac5469c7f?experience=fabric-developer
    2. Workspace id: 048e68c9-dd2f-44cf-8b71-b869b44bfb10
    3. lakehouses id: 23642408-0a80-4b96-970d-a74ac5469c7f
   
11. Deploy from test to prod stage, copy lakehouse ref url
    1. https://app.powerbi.com/groups/74dbb2ab-dca0-49a8-bfeb-68c563a5c96b/lakehouses/1f4c5ccb-d8a4-424d-bcc5-e3bd486c24a7?experience=fabric-developer
    2. Workspace id: 74dbb2ab-dca0-49a8-bfeb-68c563a5c96b
    3. lakehouses id: 1f4c5ccb-d8a4-424d-bcc5-e3bd486c24a7

# Step 6: branch out to workspace
1. You are developer so you need to create your own workspace/git branch
    1. use workspace name as ws_sales_ram
    2. use git branch name as feature/ram
2. Process: Click on Source Control > Click on git icon > click on drop down  > click on branch out to workspace
3. provide above names click on branch out
4. note down lakehouse url https://app.powerbi.com/groups/aa27dd33-f0c7-4a59-b615-0df0c3765902/lakehouses/c337adb3-8601-46a9-b603-8791b5d68366?experience=fabric-developer
5. by observing above url
        1. workspace id: aa27dd33-f0c7-4a59-b615-0df0c3765902
        2. lakehouse id: c337adb3-8601-46a9-b603-8791b5d68366

# Step 6: Create variable library
1. variable library is useful in CI/CD process
2. create as shown below and save it.

<img width="1833" height="408" alt="image" src="https://github.com/user-attachments/assets/6754b5cc-4d8a-459c-9d3f-3d6d32c324ac" />

3. commit code to git branch and make sure variable library object available in feature/ram
4. raise pull request from feature/ram to main
5. complete the mergeing process and make sure main branch has variable library object
6. open workspace ws_sales_dev and click on source sontrol > click on update all and make sure variable library object is available in workspace ws_sales_dev

<img width="1823" height="376" alt="image" src="https://github.com/user-attachments/assets/7a8f5d85-6edc-433e-ae6d-7e577a215c67" />


