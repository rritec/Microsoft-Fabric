# Get data in the Real-Time hub
## Steps Overview

### 1. Create an Eventstream
- Go to **Real-Time**  ![image](https://github.com/user-attachments/assets/83d0d115-bd3a-4b1f-8719-a03a0fdd2d3b) section.
- Click ![image](https://github.com/user-attachments/assets/d6e17db3-faaf-456d-8d64-3301b0755170)  ➔ Choose **Sample scenarios** ➔ **Bicycle rentals** ➔ Connect.

![image](https://github.com/user-attachments/assets/41bd6739-4644-407a-81d2-ec2190ffc0c7)

- Name source: `rritec-Bicycles-Source`.
- Rename eventstream: `rritec-Bicycles_event_stream`.

![image](https://github.com/user-attachments/assets/a7e52182-e16b-4acf-9948-88be25180b8d)

- Click on Next
- Click on Connect

![image](https://github.com/user-attachments/assets/ebc6063f-952f-4fd3-831b-e069b84c129c)



### 2. Transform Events (Add Timestamp)
- Open **Eventstream** ➔ Click **Edit**.

![image](https://github.com/user-attachments/assets/eafc185d-eb8d-486e-b5b9-c9e0ace4e189)

- In the eventstream authoring canvas, select the down arrow on the **Transform events or add destination tile**, and then select **Manage fields**. The tile is renamed to ManageFields
- In **Manage Fields**:
  - Operation name: `rritec_TutorialTransform`.
  - Add all fields.
  - Add new field:
    - Field: `SYSTEM.Timestamp()`
    - Name: `Timestamp`
- Save transformation.

![image](https://github.com/user-attachments/assets/24c8e9a7-b594-4f14-8956-62dc5a6ace73)


### 3. Create Destination
- From `rritec_TutorialTransform` tile ➔ Add Destination ➔ **Eventhouse**.
- Settings:
  - Destination name: `rritec-TutorialDestination`
  - Workspace: Select your workspace
  - Eventhouse: `rritec_Eventhouse`
  - KQL Database: `rritec_Eventhouse`
  - Table: **Create new** ➔ Name: `RawData`
  - Data format: `Json`
- **save** and  **Publish**.

![image](https://github.com/user-attachments/assets/dfc76494-6946-4c63-8095-c6e0ea476c0f)



---

## Reference
[**Real-time events are now transformed and stored into a KQL database via Eventhouse.**](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/tutorial-2-get-real-time-events)
