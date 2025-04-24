Error Handling Pipeline with Teams Notification
📘 Objective:
This pipeline demonstrates:

Setting a variable.

Sending a message to Microsoft Teams if the variable set fails.

Explicitly failing the pipeline with a custom error message if Teams message is sent.

🧱 Pipeline Name: NotifyOnVariableSetFailure
📌 Steps to Navigate and Create This Pipeline in Microsoft Fabric Data Pipelines:
Step 1: Create a new pipeline
Go to Microsoft Fabric > Data Engineering workspace.

Navigate to Data Pipelines.

Click New Pipeline and name it: NotifyOnVariableSetFailure.

Step 2: Create a pipeline variable
On the canvas, click Variables (right-side panel).

Add a variable:

Name: testVariable

Type: Integer

Step 3: Add 'Set Variable' Activity
Drag Set Variable to the canvas.

Rename it to: Set Test Variable.

In Settings:

Variable name: testVariable

Value: edfg (This will fail since edfg is a string and the type is Integer)
