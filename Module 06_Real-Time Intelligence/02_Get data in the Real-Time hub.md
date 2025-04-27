# Get data in the Real-Time hub
## Steps Overview

### 1. Create an Eventstream
- Go to **Real-Time**  ![image](https://github.com/user-attachments/assets/83d0d115-bd3a-4b1f-8719-a03a0fdd2d3b) section.
- Click ![image](https://github.com/user-attachments/assets/d6e17db3-faaf-456d-8d64-3301b0755170)  ➔ Choose **Sample scenarios** ➔ **Bicycle rentals** ➔ Connect.

![image](https://github.com/user-attachments/assets/41bd6739-4644-407a-81d2-ec2190ffc0c7)

- Name source: `rritec-Bicycles-Source`.
- Rename eventstream: `rritec-Bicycles_event_stream`.

![image](https://github.com/user-attachments/assets/a7e52182-e16b-4acf-9948-88be25180b8d)


### 2. Transform Events (Add Timestamp)
- Open **Eventstream** ➔ Click **Edit**.
- In **Manage Fields**:
  - Operation name: `TutorialTransform`.
  - Add all fields.
  - Add new field:
    - Field: `SYSTEM.Timestamp()`
    - Name: `Timestamp`
- Save transformation.

### 3. Create Destination
- From `TutorialTransform` tile ➔ Add Destination ➔ **Eventhouse**.
- Settings:
  - Destination name: `TutorialDestination`
  - Workspace: Select your workspace
  - Eventhouse: `Tutorial`
  - KQL Database: `Tutorial`
  - Table: **Create new** ➔ Name: `RawData`
  - Data format: `Json`
- Activate ingestion and **Publish**.

---

## ✅ Goal
**Real-time events are now transformed and stored into a KQL database via Eventhouse.**
