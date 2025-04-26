# Module 04: Datawarehouse

## Introduction

- Fabric Data Warehouse: In a Microsoft Fabric workspace, a Fabric warehouse is labeled as **Warehouse** in the **Type** column.
  
  ![image](https://github.com/user-attachments/assets/3c827a1c-4e1c-406c-a5e6-52784b6149e8)

- When you need the full power and transactional capabilities (DDL and DML query support) of a data warehouse, this is the fast and simple solution for you.
- The warehouse can be populated by any one of the supported data ingestion methods such as COPY INTO, Pipelines, Dataflows, or cross database ingestion options such as CREATE TABLE AS SELECT (CTAS), INSERT..SELECT, or SELECT INTO.
- Listen my old videos about OLTP  and DW.

- [![Watch the video](https://img.youtube.com/vi/NAuWUWmdmsE/default.jpg)](https://youtu.be/NAuWUWmdmsE)
- [![Watch the video](https://img.youtube.com/vi/KeJi1xDHQtA/default.jpg)](https://youtu.be/KeJi1xDHQtA)
- [![Watch the video](https://img.youtube.com/vi/XeMpv1Q3aJ8/default.jpg)](https://youtu.be/XeMpv1Q3aJ8)

## Warehouse or lakehouse

- Here are some general guidelines to help you make the decision:
    - Choose a **data warehouse** when you need an enterprise-scale solution with open standard format, no knobs performance, and minimal setup.  Best suited for semi-structured and structured data formats, the data warehouse is suitable for both beginner and experienced data professionals, offering simple and intuitive experiences.
    - Choose a **lakehouse** when you need a large repository of highly unstructured data from heterogeneous sources, leveraging low-cost object storage and want to use SPARK as your primary development tool. Acting as a 'lightweight' data warehouse, you always have the option to use the SQL endpoint and T-SQL tools to deliver reporting and data intelligence scenarios in your lakehouse.

## Create a warehouse

- Select ![image](https://github.com/user-attachments/assets/98fc64c0-6254-45ea-b4d2-54ff1f0ce348)  to display the full list of available item types.
- From the list, in the Store data section, select the **Warehouse** item type.
  
![image](https://github.com/user-attachments/assets/3f05b3ef-340a-4528-a190-77010aa06415)

- In the New warehouse window, enter the name **rritec_DW**.> Click on Create

![image](https://github.com/user-attachments/assets/96500816-0c36-4a0f-b03f-74203e218e8a)

- Observe the interface

![image](https://github.com/user-attachments/assets/5d89c921-dc84-4620-b33c-12b65fd62721)




## Lab
1. Complete all activites from [MSFT document](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction)
## Reference 
1. [Warehouse Overview](https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing)
