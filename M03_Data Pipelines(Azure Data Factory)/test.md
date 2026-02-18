# 01. Microsoft Fabric – Creating a Reusable Outlook Succeeded Notification Pipeline

## Objective

By the end of this exercise, the student will be able to:

* Create a **separate Outlook notification pipeline**
* Configure **pipeline parameters**
* Use **dynamic content** in Outlook activity
* Reuse this pipeline from other pipelines using **Invoke Pipeline**

## Step 1: Create a New Data Pipeline

### Navigation

**Fabric Workspace → Data Engineering → Data Pipelines → New pipeline**

### Action

* Pipeline name:

  ```
  pipe_Succeeded_Notification
  ```

### Why?

This pipeline will act as a **utility pipeline** whose only responsibility is to **send success emails**.

---

## Step 2: Open Pipeline Parameters

### Navigation

**Pipeline canvas → Top menu → Parameters**

### Action

Create the following parameters:

| Parameter Name           | Type   | Default Value                           | Purpose                  |
| ------------------------ | ------ | --------------------------------------- | ------------------------ |
| `To`                     | String | `dwramreddy@gmail.com;rritec@gmail.com` | Email recipients         |
| `pipeName`               | String | `testpipe`                              | Name of calling pipeline |
| `status`                 | String | `succeeded`                             | Execution status         |
| `workspaceid`            | String | `123`                                   | Workspace identifier     |
| `Number_of_rows_read`    | String | `NA`                                    | Source row count         |
| `Number_of_rows_written` | String | `NA`                                    | Target row count         |


<img width="761" height="364" alt="image" src="https://github.com/user-attachments/assets/80e1f65d-ee9e-4c8f-8f69-e72b6e6b0bbb" />

### Why?

Pipeline parameters make this pipeline:

* Reusable
* Environment-independent
* Easy to call from any other pipeline

---

## Step 3: Add Outlook (Office365Email) Activity

### Navigation

**Activities pane → Outlook → Drag to canvas**

### Action

Rename the activity:

```
sendSucceededMail
```

### Why?

Clear naming helps when debugging and teaching pipeline flows.

---

## Step 4: Configure Email Recipients (To)

### Navigation

**sendSucceededMail → Settings → To**

### Action

1. Click **Add dynamic content**
2. Select:

   ```
   pipeline().parameters.To
   ```

### Why?

Recipients should not be hardcoded.
They are passed dynamically from the parent pipeline.

---

## Step 5: Configure Email Subject (Dynamic)

### Navigation

**sendSucceededMail → Settings → Subject**

### Action

Use dynamic content expression:

```text
@concat(
  'Fabric Notifications ',
  pipeline().parameters.pipeName,
  ' ',
  pipeline().parameters.status
)
```

### Resulting subject example

```
Fabric Notifications testpipe succeeded
```

### Why?

The subject clearly tells:

* Which pipeline ran
* What the status is

---

## Step 6: Configure Email Body (HTML + Parameters)

### Navigation

**sendSucceededMail → Settings → Body**

### Action

Paste the following HTML content:

```html
<p>Hi Team,</p>

<p>Workspace ID: @{pipeline().parameters.workspaceid}</p>
<p>Pipeline Name: @{pipeline().parameters.pipeName}</p>
<p>Status: @{pipeline().parameters.status}</p>

<p>Number of rows read from Source:
@{pipeline().parameters.Number_of_rows_read}</p>

<p>Number of rows Written to target:
@{pipeline().parameters.Number_of_rows_written}</p>

<p>Thanks,</p>
<p>Ram.</p>
```
<img width="777" height="808" alt="image" src="https://github.com/user-attachments/assets/b98c3e83-3eb9-4fe1-b788-3dbc5fd750a5" />

### Why?

* Outlook activity supports HTML
* Metrics make the email operationally useful
* All values are parameter-driven

---

## Step 7: Verify Connection (Office 365)

### Navigation

**Manage → Connections → Office 365**

### Check

* A valid Outlook / Office 365 connection exists
* The pipeline is linked automatically

### Why?

Connections are stored securely and reused across pipelines.

---

## Step 8: Save and Publish the Pipeline

### Navigation

**Top menu → Save → Publish**

### Important Note

🚫 Do **NOT** trigger this pipeline manually in real projects
✅ It is meant to be called using **Invoke Pipeline**

---

## Step 9: How Other Pipelines Reuse This

### In Any Business Pipeline

#### Navigation

**Pipeline canvas → Activities → Invoke Pipeline**

#### Configuration

* Invoked pipeline:

  ```
  pipe_Succeeded_Notification
  ```

#### Parameters to pass:

| Parameter                | Value                  |
| ------------------------ | ---------------------- |
| `To`                     | Email list             |
| `pipeName`               | `@pipeline().Pipeline` |
| `status`                 | `Succeeded`            |
| `workspaceid`            | Workspace ID           |
| `Number_of_rows_read`    | Activity output        |
| `Number_of_rows_written` | Activity output        |

---

## Step 10: Execution Flow (Conceptual)

```
Business Pipeline
   |
   |--- Data Load / Transform
   |
   |--- Invoke Pipeline
            |
            |--- pipe_Succeeded_Notification
                    |
                    |--- Outlook Email Sent
```

---

## Key Learning Takeaways for Students

✔ Separate notification logic from business logic

✔ Use parameters instead of hardcoding

✔ Use dynamic content in Outlook activity

✔ Reuse pipelines using Invoke Pipeline

✔ Design pipelines like enterprise solutions


---

Absolutely — let’s do the **FAILED notification pipeline** in the **same student-friendly, navigation-first format**, so learners can **recreate it 1:1 in Microsoft Fabric UI** 👌
No JSON copying required.

---

### Json
<details>
<summary>Click to expand the JSON</summary>
```json
  {
    "name": "pipe_Succeeded_Notification",
    "objectId": "5aa297c9-4e92-4f28-8ca1-1d9acfb4271f",
    "properties": {
        "activities": [
            {
                "name": "sendSucceededMail",
                "type": "Office365Email",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "to": {
                        "value": "@pipeline().parameters.To",
                        "type": "Expression"
                    },
                    "subject": {
                        "value": "@concat('Fabric Notifications ',pipeline().parameters.pipeName,' ' ,pipeline().parameters.status)",
                        "type": "Expression"
                    },
                    "body": "<p>Hi Team,</p>\n<p>Workspace ID: @{pipeline().parameters.workspaceid}</p>\n<p>Pipeline Name: @{pipeline().parameters.pipeName}</p>\n<p>Status: @{pipeline().parameters.status}</p>\n<p>Number of rows read from Source:@{pipeline().parameters.Number_of_rows_read}</p>\n<p>Number of rows Written to target: @{pipeline().parameters.Number_of_rows_written}</p>\n<p>Thanks,</p>\n<p>Ram.</p>\n<p><br></p>\n<p><br></p>"
                },
                "externalReferences": {
                    "connection": "62e96cf1-f327-4387-b2b4-9ff9c89ea6f0"
                }
            }
        ],
        "parameters": {
            "To": {
                "type": "string",
                "defaultValue": "dwramreddy@gmail.com;rritec@gmail.com"
            },
            "pipeName": {
                "type": "string",
                "defaultValue": "testpipe"
            },
            "status": {
                "type": "String",
                "defaultValue": "succeeded"
            },
            "workspaceid": {
                "type": "string",
                "defaultValue": "123"
            },
            "Number_of_rows_read": {
                "type": "string",
                "defaultValue": "NA"
            },
            "Number_of_rows_written": {
                "type": "string",
                "defaultValue": "NA"
            }
        },
        "lastModifiedByObjectId": "07dffa9c-d10a-43aa-a4dc-89568542f3c3",
        "lastPublishTime": "2026-02-18T14:48:44Z"
    }
}
```
  
</details>

# 02. Microsoft Fabric – Creating a Reusable Outlook **Failed** Notification Pipeline

## Objective

By the end of this exercise, the student will be able to:

* Create a **failed notification pipeline**
* Capture **error message dynamically**
* Send **failure alerts using Outlook activity**
* Reuse this pipeline from any Fabric pipeline using **Invoke Pipeline**



## Step 1: Create a New Data Pipeline

### Navigation

**Fabric Workspace → Data Engineering → Data Pipelines → New pipeline**

### Action

Pipeline name:

```
pipe_Failed_Notification
```

### Why?

This pipeline is dedicated to **failure alerts only**, keeping:

* Error handling centralized
* Business pipelines clean
* Notification logic reusable

---

## Step 2: Define Pipeline Parameters

### Navigation

**Pipeline canvas → Top menu → Parameters**

### Action

Create the following parameters:

| Parameter Name | Type   | Default Value                           | Purpose                        |
| -------------- | ------ | --------------------------------------- | ------------------------------ |
| `To`           | String | `dwramreddy@gmail.com;rritec@gmail.com` | Failure alert recipients       |
| `pipeName`     | String | `testpipe`                              | Name of failed pipeline        |
| `status`       | String | `Failed`                                | Execution status               |
| `workspaceid`  | String | `123`                                   | Workspace identifier           |
| `errorMsg`     | String | `NA`                                    | Failure reason / error message |

### Why?

Failure notifications need **context**.
These parameters allow the parent pipeline to pass:

* Where it failed
* Why it failed
* In which workspace

---

## Step 3: Add Outlook (Office365Email) Activity

### Navigation

**Activities pane → Outlook → Drag to canvas**

### Action

Rename the activity:

```
sendFailedMail
```

### Why?

Clear activity naming helps quickly identify failure-handling logic.

---

## Step 4: Configure Email Recipients (To)

### Navigation

**sendFailedMail → Settings → To**

### Action

1. Click **Add dynamic content**
2. Select:

   ```
   pipeline().parameters.To
   ```

### Why?

Different environments or teams may require different alert recipients.

---

## Step 5: Configure Email Subject (Failure-Focused)

### Navigation

**sendFailedMail → Settings → Subject**

### Action

Enter the dynamic expression:

```text
@concat(
  'Fabric Notifications ',
  pipeline().parameters.pipeName,
  ' ',
  pipeline().parameters.status
)
```

### Resulting subject example

```
Fabric Notifications testpipe Failed
```

### Why?

* Clearly indicates **pipeline failure**
* Easy to filter and prioritize in inbox

---

## Step 6: Configure Email Body (Error-Centric)

### Navigation

**sendFailedMail → Settings → Body**

### Action

Paste the following HTML:

```html
<p>Hi Team,</p>

<p>Workspace ID: @{pipeline().parameters.workspaceid}</p>
<p>Pipeline Name: @{pipeline().parameters.pipeName}</p>
<p>Status: @{pipeline().parameters.status}</p>

<p>Error Message:</p>
<p>@{pipeline().parameters.errorMsg}</p>

<p>Thanks,</p>
<p>Ram.</p>
```

### Why?

* Error message is the **most important signal**
* HTML formatting improves readability
* All values are parameter-driven

---

## Step 7: Verify Office 365 Connection

### Navigation

**Manage → Connections → Office 365**

### Check

* Outlook connection exists
* No credentials are hardcoded in the pipeline

### Why?

Centralized connection management is secure and reusable.

---

## Step 8: Save and Publish the Pipeline

### Navigation

**Top menu → Save → Publish**

### Important Note

🚫 This pipeline is **not triggered manually**
✅ It is called only via **Invoke Pipeline** from other pipelines

---

## Step 9: Call Failed Notification from a Business Pipeline

### Scenario

A data load activity fails in a business pipeline.

---

### Navigation

**Business Pipeline → Canvas → Invoke Pipeline**

### Configuration

* Invoked pipeline:

  ```
  pipe_Failed_Notification
  ```

---

### Parameter Mapping (Critical Step)

| Parameter     | Value                                        |
| ------------- | -------------------------------------------- |
| `To`          | Alert email list                             |
| `pipeName`    | `@pipeline().Pipeline`                       |
| `status`      | `Failed`                                     |
| `workspaceid` | Workspace ID                                 |
| `errorMsg`    | `@activity('FailingActivity').error.message` |

### Dependency

* Connect Invoke Pipeline using **On Failure** condition

---

## Step 10: Execution Flow (Visual Understanding)

```
Business Pipeline
   |
   |--- Activity Fails
   |
   |--- On Failure
           |
           |--- Invoke Pipeline
                   |
                   |--- pipe_Failed_Notification
                           |
                           |--- Outlook Failure Email
```

---

## Key Learning Takeaways for Students

✔ Separate failure handling from business logic
✔ Capture runtime error messages dynamically
✔ Use Invoke Pipeline for reuse
✔ Build production-grade alerting in Fabric
✔ Follow enterprise pipeline design principles

---

## Exam / Interview Ready Statement

> “We implemented a reusable failed-notification pipeline in Microsoft Fabric and invoked it on failure paths, passing the error message dynamically to send actionable Outlook alerts.”

---

Excellent — this is the **final missing puzzle piece** 👌
Below are **student-ready, navigation-focused notes** explaining **how this main pipeline orchestrates copy + success/failure notifications** using the **two reusable Outlook pipelines** you already built.

I’ll keep the **same teaching style** so students can **reproduce it end-to-end in Microsoft Fabric UI**.

---

# 03. Microsoft Fabric – Orchestrating Copy + Outlook Notifications

### (Success & Failure using Invoke Pipeline)

## Pipeline Name

```
pipe_notifications_using_outlook_teams
```

## Objective

By the end of this exercise, the student will be able to:

* Perform a **Copy activity** in Microsoft Fabric
* Capture **rows read / rows written**
* Handle **Success and Failure paths**
* Call **separate reusable Outlook pipelines**
* Pass runtime metadata using **Invoke Pipeline**





## 1. Pipeline Role (Big Picture)

### Navigation

**Fabric Workspace → Data Engineering → Data Pipelines → pipe_notifications_using_outlook_teams**

### Notes

This is a **business orchestration pipeline**:

* Performs actual data movement
* Decides **which notification pipeline to call**
* Does NOT contain any email logic itself

This keeps architecture **clean and enterprise-grade**.

---

## 2. Activity 1 – Copy Data (Business Logic)

### Navigation

**Pipeline canvas → Activities → Copy data**

### Activity Name

```
Copy data1
```

---

### 2.1 Source Configuration (Lakehouse – CSV)

#### Navigation

**Copy data1 → Source**

#### Configuration Summary

* Source type: **Delimited Text**
* Storage: **Lakehouse**
* Folder:

  ```
  Files/bronze
  ```
* File:

  ```
  emp1234.csv
  ```
* First row as header: ✅

### Why?

This simulates a **real ingestion scenario** from Bronze layer.

---

### 2.2 Sink Configuration (Fabric SQL Database)

#### Navigation

**Copy data1 → Sink**

#### Configuration Summary

* Sink type: **Fabric SQL Database**
* Schema: `dbo`
* Table:

  ```
  emp20260216
  ```
* Table option: **Auto create**
* Write behavior: **Insert**

### Why?

* Demonstrates Lakehouse → Warehouse pattern
* Auto-create simplifies student labs

---

### 2.3 Copy Metrics (Important for Notifications)

The Copy activity automatically produces:

* `rowsRead`
* `rowsCopied`
* `executionDetails`
* `errors` (if failed)

These outputs are later **passed to notification pipelines**.

---

## 3. Success Path – Invoke Succeeded Notification Pipeline

### Trigger Condition

```
Copy data1 → Succeeded
```

### Navigation

**Copy data1 → On Success → Invoke Pipeline**

---

### Activity Name

```
Invoke pipeline1
```

### Invoked Pipeline

```
pipe_Succeeded_Notification
```

---

### 3.1 Parameter Mapping (Success)

#### Navigation

**Invoke pipeline1 → Settings → Parameters**

| Parameter                | Value                                                       | Purpose                 |
| ------------------------ | ----------------------------------------------------------- | ----------------------- |
| `To`                     | Email list                                                  | Notification recipients |
| `pipeName`               | `@pipeline().PipelineName`                                  | Parent pipeline name    |
| `status`                 | `@activity('Copy data1').output.executionDetails[0].status` | Success status          |
| `workspaceid`            | `@pipeline().DataFactory`                                   | Workspace identifier    |
| `Number_of_rows_read`    | `@activity('Copy data1').output.rowsRead`                   | Rows read               |
| `Number_of_rows_written` | `@activity('Copy data1').output.rowsCopied`                 | Rows written            |

### Why?

This sends a **rich success email** with:

* Pipeline name
* Status
* Operational metrics

---

## 4. Failure Path – Invoke Failed Notification Pipeline

### Trigger Condition

```
Copy data1 → Failed
```

### Navigation

**Copy data1 → On Failure → Invoke Pipeline**

---

### Activity Name

```
Invoke pipeline1_copy1
```

### Invoked Pipeline

```
pipe_Failed_Notification
```

---

### 4.1 Parameter Mapping (Failure)

#### Navigation

**Invoke pipeline1_copy1 → Settings → Parameters**

| Parameter     | Value                                                       | Purpose                  |
| ------------- | ----------------------------------------------------------- | ------------------------ |
| `To`          | Email list                                                  | Failure alert recipients |
| `pipeName`    | `@pipeline().PipelineName`                                  | Failed pipeline name     |
| `status`      | `@activity('Copy data1').output.executionDetails[0].status` | Failed                   |
| `workspaceid` | `@pipeline().DataFactory`                                   | Workspace identifier     |
| `errorMsg`    | `@activity('Copy data1').output.errors[0].Message`          | Error message            |

### Why?

Failure emails must answer **one key question**:

> *Why did it fail?*

This captures the **actual runtime error** from Fabric.

---

## 5. Dependency Design (Very Important Concept)

### Visual Flow

```
Copy data1
   |
   |-- Succeeded --> pipe_Succeeded_Notification
   |
   |-- Failed ----> pipe_Failed_Notification
```

### Notes

* Business pipeline decides the outcome
* Notification pipelines only **send emails**
* No branching logic inside notification pipelines

This is **perfect separation of concerns**.

---

## 6. Pipeline Parameters (Optional Extension)

### Navigation

**Pipeline → Parameters**

```text
workspacename = rr-master-workspace
```

### Notes

* Can be passed instead of `DataFactory`
* Useful for:

  * Dev / Test / Prod clarity
  * Teaching environment awareness

---

## 7. What Students Learn from This Pipeline

✔ Real data movement using Copy activity
✔ Capturing runtime metrics
✔ Success vs Failure dependency handling
✔ Invoking reusable pipelines
✔ Enterprise notification architecture

---

## 8. Teaching Summary (Very Important Slide)

> “This pipeline performs the business logic and delegates notification responsibilities to reusable pipelines using Invoke Pipeline based on success or failure outcomes.”

---

## 9. Interview-Ready Explanation (Power Answer)

> “We use a central orchestration pipeline that executes data movement and conditionally invokes reusable Outlook notification pipelines for success and failure, passing runtime metrics and error details dynamically.”

---








