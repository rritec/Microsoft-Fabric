# Get data in the Real-Time hub
## Steps Overview

### 1. Create an Eventstream
- Go to **Real-Time**  ![image](https://github.com/user-attachments/assets/83d0d115-bd3a-4b1f-8719-a03a0fdd2d3b) section.
- Click **+ Connect data source** ➔ Choose **Sample scenarios** ➔ **Bicycle rentals** ➔ Connect.
- Name source: `TutorialSource`.
- Rename eventstream: `TutorialEventstream`.

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
