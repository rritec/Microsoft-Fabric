# Module 04: Datawarehouse

- Fabric Data Warehouse: In a Microsoft Fabric workspace, a Fabric warehouse is labeled as **Warehouse** in the **Type** column.
  
  ![image](https://github.com/user-attachments/assets/3c827a1c-4e1c-406c-a5e6-52784b6149e8)

- When you need the full power and transactional capabilities (DDL and DML query support) of a data warehouse, this is the fast and simple solution for you.
- The warehouse can be populated by any one of the supported data ingestion methods such as COPY INTO, Pipelines, Dataflows, or cross database ingestion options such as CREATE TABLE AS SELECT (CTAS), INSERT..SELECT, or SELECT INTO.

## Warehouse or lakehouse

- Here are some general guidelines to help you make the decision:
    - Choose a **data warehouse** when you need an enterprise-scale solution with open standard format, no knobs performance, and minimal setup.  Best suited for semi-structured and structured data formats, the data warehouse is suitable for both beginner and experienced data professionals, offering simple and intuitive experiences.
    - Choose a **lakehouse** when you need a large repository of highly unstructured data from heterogeneous sources, leveraging low-cost object storage and want to use SPARK as your primary development tool. Acting as a 'lightweight' data warehouse, you always have the option to use the SQL endpoint and T-SQL tools to deliver reporting and data intelligence scenarios in your lakehouse.

## Lab
1. Complete all activites from [MSFT document](https://learn.microsoft.com/en-us/fabric/data-warehouse/tutorial-introduction)
## Reference 
1. [Warehouse Overview](https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing)
