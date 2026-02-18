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

## HomeWork (think about it)

🔁 **Merge Success + Failure into ONE generic notification pipeline**
(using `status` + conditional formatting)





