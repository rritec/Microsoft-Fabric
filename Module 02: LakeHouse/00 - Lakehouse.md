# Lakehouse

## Introduction

- Traditionally, organizations have been building modern data warehouses for their transactional and structured data analytics needs. And data lakehouses for big data (semi/unstructured) data analytics needs. These two systems ran in parallel, creating silos, data duplication, and increased total cost of ownership.
- Fabric with its unification of data store and standardization on Delta Lake format allows you to eliminate silos, remove data duplication, and drastically reduce total cost of ownership.
- With the flexibility offered by Fabric, you can implement either lakehouse or data warehouse architectures or combine them together to get the best of both with simple implementation.
- It uses the **medallion architecture** where the bronze layer has the raw data, the silver layer has the validated and deduplicated data, and the gold layer has highly refined data. You can take the same approach to implement a lakehouse for any organization from any industry.

## Exercise 1: Create Lake House

1. On the left navigation pane, click on Workspaces.
2. Select the Workspace where you want to create the Lakehouse.
3. Inside the selected Workspace, click ![image](https://github.com/user-attachments/assets/17d0c5e3-1bea-4d74-9df2-01760eee25ed)

4. Search for Lakehouse >  Click on Lakehouse

![image](https://github.com/user-attachments/assets/f7f31b24-ef1b-4aa6-a795-276558968547)

5. Enter a **Lakehouse name** (e.g., rritec_Lakehouse).

![image](https://github.com/user-attachments/assets/050037c3-267c-48ae-8445-0193f075642c)


6. Click **Create**.
7. Observe that with in Lakehouse, two child objects created those are Semantic Model and SQL Analytics Endpoint
8. A SQL analytics endpoint for SQL querying and a default Power BI semantic model for reporting.

![image](https://github.com/user-attachments/assets/596e4548-32a5-4d2d-a5d8-1c8b363e00bc)



- 

## Exercise 2: Upload file from local Machine

1. Open Lakehouse by clciking on it.
2. Create a subfolder with the name of **data**

![image](https://github.com/user-attachments/assets/ebe76025-9538-4127-8f88-0e451f0125d0)

![image](https://github.com/user-attachments/assets/b72e2206-cfa5-476b-a318-c1a724caf4ed)


3. Download the file emp.csv from labdata folder
4. Right click on data folder and upload the emp.csv file
![alt text](image.png)
4. 

## Exercise 3: Create table using csv file

1. Right click on emp.csv file > Load to Tables > New Table
![image](https://github.com/user-attachments/assets/7e907de9-2f9c-47eb-ac47-fcd3cbea2604)

2. Provide schema as **dbo** and table name as **emp** click on **Load**
3. Right click on emp table observe properties

![image](https://github.com/user-attachments/assets/3d5a7b31-5964-4a07-af10-703c10b2fad8)

4. Do research on what is **Delta** table .
5. Right click on emp table observe view files and research on **parquet** file format.

## Exercise 4: Ingest data using New Dataflow Gen2

1. Open Lakehouse by clciking on it.
2. Click on **Get data** > Click on **New Dataflow Gen2**
4. On the new dataflow screen, select **Import from a Text/CSV file**
5. Provide the URL https://raw.githubusercontent.com/microsoft/fabric-samples/689e78676174d4627fc3855165bde9100cb4d19e/docs-samples/data-engineering/dimension_customer.csv
6. Click on next

![image](https://github.com/user-attachments/assets/92f5a0b7-944b-4160-b813-b69de0ae526a)

7. Click on Create

![image](https://github.com/user-attachments/assets/c30cd005-4fec-4a3c-ac9a-56138752b5fb)

8. Change Query Name as dim_customer
9. Click on Publish

![image](https://github.com/user-attachments/assets/e189e271-aacf-4d1b-b0fc-d756451f79c7)


9. A spinning circle next to the dataflow's name indicates publishing is in progress in the item view. When publishing is complete, select the **...** and select **Properties**. **Rename** the dataflow to **Load Lakehouse Table** and select **Save**.
10. Select the **Refresh now** option next to the data flow name to refresh the dataflow. This option runs the data flow and moves data from the source file to lakehouse table. While it's in progress, you see a spinning circle under Refreshed column in the item view

![image](https://github.com/user-attachments/assets/2d8553e0-78a3-4ea4-81b8-a172fad307c9)

11. Once the dataflow is refreshed, select your lakehouse in the navigation bar to view the **dim_customer** Delta table

![image](https://github.com/user-attachments/assets/dfd356ba-ad46-4aab-b255-6b3c94349028)


12. 

## Exercise 5: Ingest data using New Pipeline

1. Open Lakehouse by clciking on it.
2. Click on **Get data** > Click on **New Data Pipeline**
3. Name it as **PipelineToIngestDataFromSourceToLakehouse** > Click on **Create**

![image](https://github.com/user-attachments/assets/3289ebc2-941e-4cfe-b804-7d8c08fa35d9)

4. Search for **Http** and select it.

![image](https://github.com/user-attachments/assets/88af9a6c-acbe-456b-942b-015830bbebb8)

5. In the Connect to data source window, enter the details from the table below and select **Next**

| Property	| Value |
| ---- | ---- |
| URL	| https://assetsprod.microsoft.com/en-us/wwi-sample-dataset.zip |
| Connection	| Create a new connection |
| Connection name	| wwisampledata |
| Data gateway	| None |
| Authentication kind	| Anonymous |

![image](https://github.com/user-attachments/assets/eb256e2d-d503-494e-bc76-103f03c6286d)

7. Enable the **Binary copy** and choose **ZipDeflate (.zip)** as the Compression type since the source is a .zip file. Keep the other fields at their default values and click **Next**.

![image](https://github.com/user-attachments/assets/27c4ed58-751c-4aba-a99f-5c26e10f2a95)

8. In the Connect to data destination window, specify the Root folder as **Files** > folder path as **data** >> Click on **Next**


9. In connect to data distance window if binary available select else we will select take care after few mins

![image](https://github.com/user-attachments/assets/5e81be66-ecf1-4d81-8003-6724823f774b)

10. In **Review + Save** Window disable the start **data transfer Immediately** > Click on **OK**
11. Select **copy Data** activity > Click on **Distination** tab and make sure File Format as **Binary**
12. Click on **Run** > Click on **Save and Run** > It may take 15 mins or more
13. Once pipeline completed you will see below all folders and Files

![image](https://github.com/user-attachments/assets/104dd29f-a5f3-45b7-8f09-ca479e1e0cce)

## Exercise 6: Prepare and transform data in the lakehouse

1. Open Lakehouse by clciking on it.
2. Read about [V-Order and Optimization](https://learn.microsoft.com/en-us/fabric/data-engineering/delta-optimization-and-v-order?tabs=sparksql)
3. Download the notebooks from our github module 2
4. From the workspace, select Import > Notebook > From this computer.
5. Select all the notebooks that you downloaded in first step of this section.
6. From the list of existing notebooks, select the 01 - Create Delta Tables notebook and select Open.
7. In the open notebook in the lakehouse Explorer, you see the notebook is already linked to your opened lakehouse if not add your lakehouse.
8. run one by one script and observe new tables are created
9. open second notebook 02 - Data Transformation - Business Aggregates run all scripts to load the data
10. Verify one by one table and note down count od records in each table.

![image](https://github.com/user-attachments/assets/cbdbf6a0-544a-42f2-be08-374108488128)

    



## Questions
1. you know navigation to get **SQL connection string** ???
2. Session job connection string vs Batch job connection string
3. 

## Answers
1. Click on **Settings** > SQL Analytics Endpoint
2. Click on **Settings** > Livy Endpoint 
    - Use Session Jobs if you need real-time interaction (e.g., testing, debugging, and exploratory analysis).
    - Use Batch Jobs for scheduled workloads like ETL pipelines, data transformations, or running full scripts.)
3. 


