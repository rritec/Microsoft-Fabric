Perfect 👍
Below are **step-by-step Microsoft Fabric notes written exactly for students**, so they can **navigate the UI and reproduce the same pipeline** from scratch **without copying JSON**.

I’m writing this in a **“do this → see this → why this”** style, which works very well for classrooms and self-learning.

---

# Microsoft Fabric – Creating a Reusable Outlook Succeeded Notification Pipeline

## Objective

By the end of this exercise, the student will be able to:

* Create a **separate Outlook notification pipeline**
* Configure **pipeline parameters**
* Use **dynamic content** in Outlook activity
* Reuse this pipeline from other pipelines using **Invoke Pipeline**

---

![Image](https://learn.microsoft.com/en-us/fabric/data-factory/media/parameters/use-dynamic-content.png)

![Image](https://learn.microsoft.com/en-us/fabric/data-factory/media/outlook-activity/email-details.png)

---

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

## Interview / Exam Ready Statement

> “We implemented a reusable Outlook notification pipeline in Microsoft Fabric and invoked it from all business pipelines using parameters to pass execution metadata.”

---

If you want next (recommended for students):

* 🔴 **Failure notification pipeline**
* 🔁 **Single pipeline handling success + failure**
* 🧪 **Lab assignment with expected output**
* 📊 **HTML table email version**

Tell me what you want to add next, and I’ll structure it the same way 👌
