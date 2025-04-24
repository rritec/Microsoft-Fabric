Notify on Variable Set Failure in Microsoft Fabric

## 🎯 Objective
This pipeline demonstrates error handling in Microsoft Fabric using:
- A **Set Variable** activity.
- A **Teams** activity to send a message upon failure.
- A **Fail** activity to stop the pipeline with a custom error message.

---

## 🧱 Pipeline Name: `NotifyOnVariableSetFailure`

---

## 📝 Step-by-Step Navigation

### 🥇 Step 1: Create a New Pipeline
1. Go to **Microsoft Fabric** → **Data Engineering** workspace.
2. Navigate to **Data Pipelines**.
3. Click **New Pipeline**.
4. Rename the pipeline to: `NotifyOnVariableSetFailure`.

---

### 🧮 Step 2: Create a Pipeline Variable
1. Click the **Variables** panel on the right.
2. Add a new variable:
   - **Name**: `testVariable`
   - **Type**: `Integer`

---

### ✍️ Step 3: Add 'Set Variable' Activity
1. From the **Activities** pane, drag **Set Variable** onto the canvas.
2. Rename it to: `Set Test Variable`.
3. In the **Settings** tab:
   - **Variable name**: `testVariable`
   - **Value**: `edfg` *(String value which will cause type mismatch error)*

---

### 📣 Step 4: Add a 'Teams' Activity

#### 🔧 Purpose:
To notify a Microsoft Teams group **if** setting the variable fails.

#### 🧭 Navigation:
1. Drag a **Teams** activity to the canvas.
2. Rename it to: `Notify via Teams`.
3. Connect it to the `Set Test Variable` activity:
   - Click on the arrow → **Add dependency**
   - Set condition: **Failed**
4. Select `Notify via Teams`, go to the **Settings** tab.
5. Configure the Teams message:
   
  ![image](https://github.com/user-attachments/assets/59a29941-7af9-41d9-aa91-22b2d34b4460)

---

### ❌ Step 5: Add a 'Fail' Activity
1. Drag a **Fail** activity to the canvas.
2. Rename it to: `Stop with Error`.
3. Connect it from `Notify via Teams` using **Succeeded** condition.
4. In the **Settings** tab:
   - **Message**: `Variable Value Wrong`
   - **Error Code**: `400`

---
