# Step 1 of 3 — Create Azure AD Security Group
1. Go to **portal.azure.com** > Search for **Groups** in the top search bar >	Click **+ New Group**
2. Fill in the fields as follows:
  - Group type	> Security
  - Group name	reporting-team-group
  - Group description	Reporting team — dbo1 read access
  - Membership type	**Assigned**
3. Under Members, click **No members selected** and add all reporting team users
4. Click Create

# Step 2 of 3 — Configure SQL Permissions in the Warehouse

``` sql
-- Step 1: Create a SQL role for the reporting team
CREATE ROLE reporting_team_role;

-- Step 2: Allow role to connect to the warehouse
GRANT CONNECT TO reporting_team_role;

-- Step 3: Grant SELECT on dbo1 schema only (NOT dbo)
GRANT SELECT ON SCHEMA::dbo1 TO reporting_team_role;

-- Step 4: Add the AAD Security Group to the role
ALTER ROLE reporting_team_role ADD MEMBER [reporting-team-group];

-- Step 5: Verify
SELECT
    r.name AS role_name,
    m.name AS member_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name = 'reporting_team_role';

```

# Step 3 of 3 — Share Warehouse via OneLake

7.	Go to ram-workspace in the Fabric portal
8.	Locate warehouse b20260311_dwh in the workspace item list
9.	Click the ... menu next to the warehouse
10.	Select Share
11.	In the Grant people access dialog, enter: reporting-team-group
12.	Check the following permission:
  - Read all OneLake data (ReadAll) and subscribe to events(subscribe one lake events)
  - Build reports on the default semantic model
  - share granted permissions(Reshare)
13.	Click on Grant





