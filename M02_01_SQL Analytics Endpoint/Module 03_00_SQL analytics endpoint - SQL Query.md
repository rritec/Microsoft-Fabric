# Module 03: SQL Analytics Endpoint

## Microsoft Fabric SQL Analytics Endpoint
- The SQL Analytics Endpoint in Microsoft Fabric is a key component that allows users to query and analyze data stored in OneLake using SQL-based tools and services.
- It provides a **serverless SQL** experience, enabling seamless integration with **Power BI, Azure Synapse, and other analytical tools**.
- Fabric SQL Analytics Endpoint is a ```read-only``` analytical SQL layer over OneLake.It does not support DML, DDL for tables, indexes, stored procedures, temp tables, or fine-grained security. It is optimized for Power BI and ad-hoc analytics using snapshot isolation.


## Sample Data Setup

1. Create a new Lakehouse or open an existing one.  
2. Upload the `emp.csv` and `dept.csv` files from the **labdata** folder into the **Lakehouse data** folder.  
3. For each file, right-click and choose **Create Table**, assigning it to the `dbo` schema.

![image](https://github.com/user-attachments/assets/d83b1ed2-ec83-4ed9-a0cd-6ec48f957c7f)

4. Click on SQL analytics endpoint

![image](https://github.com/user-attachments/assets/090fccf8-5b4a-4d28-a4f0-e7ef887deeb1)

5. Click on **New SQL Query**

![image](https://github.com/user-attachments/assets/bf160a8b-20ef-4bb8-ac4a-5b83dfcc443f)






## 1. **Basic Queries**
### **1.1 Select All Data**
```sql
SELECT * FROM emp;
SELECT * FROM dept;
```
![image](https://github.com/user-attachments/assets/60678e18-d068-4059-8c18-7369d4cfeee0)

### **1.2 Selecting Specific Columns**

1. [what-is-column-pruning](https://github.com/rritec/Microsoft-Fabric/blob/main/M100_Interview/PySpark.md#-what-is-column-pruning-in-pyspark)
```sql
SELECT empno, ename, job, sal FROM emp;
SELECT deptno, dname, loc FROM dept;
```

---

## 2. **Joins - Combining `emp` and `dept` Tables**
### **2.1 INNER JOIN - Employees with Departments**
```sql
SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
FROM emp e
INNER JOIN dept d ON e.deptno = d.deptno;
```

### **2.2 LEFT JOIN - All Employees, Even Without Departments**
```sql
SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
FROM emp e
LEFT JOIN dept d ON e.deptno = d.deptno;
```

### **2.3 Right JOIN - All Departments, Even Without Employees**
```sql
SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
FROM emp e
RIGHT JOIN dept d ON e.deptno = d.deptno;
```

### **2.4 FULL OUTER JOIN - Show All Employees and Departments**
```sql
SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
FROM emp e
FULL OUTER JOIN dept d ON e.deptno = d.deptno;
```


### **2.5 Cross  JOIN - Show All Possibilities of data**
```sql
%%sql
select dept.deptno,emp.deptno,ename,sal,dname from emp, dept
---

## 3. **Aggregations & Grouping**
### **3.1 Count Employees per Department**
```sql
SELECT d.dname, COUNT(e.empno) AS employee_count
FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname;
```

### **3.2 Average Salary per Department**
```sql
SELECT d.dname, AVG(e.sal) AS avg_salary
FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname;
```

### **3.3 Employees with Salary Above Department Average**
```sql
SELECT e.ename, e.sal, d.dname
FROM emp e
JOIN dept d ON e.deptno = d.deptno
WHERE e.sal > (
    SELECT AVG(sal) FROM emp WHERE deptno = e.deptno
);
```

### **3.4 Understand all**
```

SELECT 
    d.dname,
    
    COUNT(*) AS total_rows,                                -- Total rows (including NULLs in LEFT JOIN)
    COUNT(e.empno) AS employee_count,                      -- Total employees (excluding NULLs from unmatched departments)
    
    SUM(e.sal) AS total_salary,                            -- Total salary in the department
    AVG(e.sal) AS avg_salary,                              -- Average salary
    MIN(e.sal) AS min_salary,                              -- Minimum salary
    MAX(e.sal) AS max_salary,                              -- Maximum salary    


    COUNT(DISTINCT e.job) AS distinct_jobs,                -- Number of distinct job roles
    COUNT(DISTINCT e.sal) AS distinct_salaries           -- Number of distinct salaries


FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname;
```
---

## 4. **Window Functions**
### **4.1 Rank Employees by Salary per Department**
```sql
SELECT 
    e.empno,
    e.ename,
    --e.job,
    --e.mgr,
    --e.hiredate,   
    --e.comm,
    e.deptno,
    d.dname,
     e.sal,

    -- -- RANKING FUNCTIONS
    RANK() OVER (ORDER BY e.sal DESC) AS salary_rank
    -- DENSE_RANK() OVER (ORDER BY e.sal DESC) AS salary_dense_rank,
    -- ROW_NUMBER() OVER (ORDER BY e.sal DESC) AS salary_row_number,
    -- NTILE(4) OVER (ORDER BY e.sal DESC) AS salary_quartile,

    -- -- AGGREGATE WINDOW FUNCTIONS
    -- SUM(e.sal) OVER (PARTITION BY e.deptno) AS dept_total_salary,
    -- AVG(e.sal) OVER (PARTITION BY e.deptno) AS dept_avg_salary,
    -- MIN(e.sal) OVER (PARTITION BY e.deptno) AS dept_min_salary,
    -- MAX(e.sal) OVER (PARTITION BY e.deptno) AS dept_max_salary,
    -- COUNT(*) OVER (PARTITION BY e.deptno) AS dept_emp_count,

    -- -- RUNNING TOTALS
    -- SUM(e.sal) OVER (ORDER BY e.sal ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_salary,
    -- AVG(e.sal) OVER (ORDER BY e.sal ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg_salary,

    -- -- LAG/LEAD
    -- LAG(e.sal, 1) OVER (ORDER BY e.sal DESC) AS prev_salary,
    -- LEAD(e.sal, 1) OVER (ORDER BY e.sal DESC) AS next_salary,

    -- -- FIRST_VALUE, LAST_VALUE
    -- FIRST_VALUE(e.sal) OVER (PARTITION BY e.deptno ORDER BY e.sal DESC) AS dept_highest_salary,
    -- LAST_VALUE(e.sal) OVER (PARTITION BY e.deptno ORDER BY e.sal DESC 
    --     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS dept_lowest_salary



FROM emp e
JOIN dept d ON e.deptno = d.deptno
order by sal desc;

```

### **4.2 Running Total of Salaries**
```sql
SELECT e.ename, e.sal,
       SUM(e.sal) OVER (ORDER BY e.sal) AS running_total
FROM emp e;
```

---

## 5. **Common Table Expressions (CTEs)**
### **5.1 Finding Highest Paid Employee per Department**
```sql
WITH RankedSalaries AS (
    SELECT e.ename, e.sal, e.deptno,
           RANK() OVER (PARTITION BY e.deptno ORDER BY e.sal DESC) AS rnk
    FROM emp e
)
SELECT ename, sal, deptno FROM RankedSalaries WHERE rnk = 1;
```
### **5.2 Department-Level Salary Summary + Rank Each Employee Within Their Department**
```
WITH DeptStats AS (
    SELECT 
        deptno,
        SUM(sal) AS dept_total_salary,
        AVG(sal) AS dept_avg_salary
    FROM emp
    GROUP BY deptno
),
EmpRanked AS (
    SELECT 
        e.empno,
        e.ename,
        e.sal,
        e.deptno,
        d.dname,
        RANK() OVER (PARTITION BY e.deptno ORDER BY e.sal DESC) AS salary_rank
    FROM emp e
    JOIN dept d ON e.deptno = d.deptno
)
SELECT 
    er.empno,
    er.ename,
    er.sal,
    er.dname,
    er.salary_rank,
    ds.dept_total_salary,
    ds.dept_avg_salary,
    ROUND(er.sal - ds.dept_avg_salary, 2) AS diff_from_avg,
    CASE
        WHEN er.sal > ds.dept_avg_salary THEN 'Above Avg'
        WHEN er.sal < ds.dept_avg_salary THEN 'Below Avg'
        ELSE 'At Avg'
    END AS salary_position
FROM EmpRanked er
JOIN DeptStats ds ON er.deptno = ds.deptno
ORDER BY er.dname, er.salary_rank;

```
---

## 6. Views

# **6.1 Creating a View for Employees with Department Names**
```sql
CREATE VIEW vw_emp_details AS
SELECT e.empno, e.ename, e.job, e.sal, d.dname, d.loc
FROM emp e
JOIN dept d ON e.deptno = d.deptno;
```

### **6.2 Querying the View**
```sql
SELECT * FROM vw_emp_details;
```

---

# Q & A


### **1. Which operation is NOT supported in Fabric SQL Analytics Endpoint?**

* A. SELECT queries
* B. CREATE VIEW
* C. INSERT INTO table
* D. JOIN operations

**✅ Answer:** C
**Explanation:** SQL Analytics Endpoint is **read-only**; DML operations like INSERT, UPDATE, DELETE are not supported.

---

### **2. Which type of table can be created in SQL Analytics Endpoint?**

* A. Managed tables
* B. External tables
* C. Temporary tables
* D. None

**✅ Answer:** D
**Explanation:** You cannot create tables (managed, external, or temp) in SQL Analytics Endpoint.

---

### **3. Which SQL object creation is supported in Fabric SQL Analytics Endpoint?**

* A. Stored Procedures
* B. User Defined Functions
* C. Views
* D. Triggers

**✅ Answer:** C
**Explanation:** Only **views** are supported for logical abstraction.

---

### **4. Which isolation model does Fabric SQL Analytics Endpoint use?**

* A. Read Uncommitted
* B. Read Committed
* C. Snapshot Isolation
* D. Serializable

**✅ Answer:** C
**Explanation:** Fabric SQL endpoint uses **snapshot isolation**, ensuring consistent reads without locking writers.

---

### **5. Which feature is NOT supported for transactional workloads?**

* A. ACID compliance
* B. Row-level locking
* C. Consistent reads
* D. Versioned reads

**✅ Answer:** B
**Explanation:** Row-level locking is not supported because the endpoint is **analytical and read-only**.

---

### **6. Which data modification statement is allowed in SQL Analytics Endpoint?**

* A. INSERT
* B. UPDATE
* C. DELETE
* D. None

**✅ Answer:** D
**Explanation:** All DML statements are blocked.

---

### **7. Can you create stored procedures in Fabric SQL Analytics Endpoint?**

* A. Yes
* B. Only read-only procedures
* C. Only with Spark integration
* D. No

**✅ Answer:** D
**Explanation:** Stored procedures are **not supported**.

---

### **8. Which type of security is LIMITED in Fabric SQL Analytics Endpoint?**

* A. Authentication
* B. Encryption at rest
* C. Row-Level Security (RLS)
* D. Network security

**✅ Answer:** C
**Explanation:** Fine-grained security like **RLS and CLS is limited** compared to dedicated SQL engines.

---

### **9. Which indexing option is available in SQL Analytics Endpoint?**

* A. Clustered index
* B. Non-clustered index
* C. Columnstore index
* D. None

**✅ Answer:** D
**Explanation:** You cannot create or manage indexes in SQL Analytics Endpoint.

---

### **10. Which workload is NOT suitable for SQL Analytics Endpoint?**

* A. Power BI reporting
* B. Ad-hoc analytical queries
* C. High-volume OLTP workloads
* D. Data exploration

**✅ Answer:** C
**Explanation:** SQL Analytics Endpoint is **not designed for OLTP**.

---

### **11. Can SQL Analytics Endpoint be paused or scaled manually?**

* A. Yes, both
* B. Only scaled
* C. Only paused
* D. No

**✅ Answer:** D
**Explanation:** Compute management is **fully abstracted**.

---

### **12. Which feature related to schema evolution is NOT supported directly?**

* A. Automatic schema inference
* B. ALTER TABLE ADD COLUMN
* C. Schema enforcement
* D. Versioned schema

**✅ Answer:** B
**Explanation:** Schema changes must be done via **Spark or pipelines**, not SQL endpoint.

---

### **13. Which statement about temporary objects is correct?**

* A. Local temp tables are supported
* B. Global temp tables are supported
* C. Both are supported
* D. None are supported

**✅ Answer:** D
**Explanation:** Temporary tables are **not supported**.

---

### **14. Which SQL feature commonly used in Dedicated SQL Pools is missing here?**

* A. Views
* B. Window functions
* C. Stored procedures
* D. SELECT

**✅ Answer:** C
**Explanation:** Stored procedures are not supported.

---

### **15. What is the primary reason Fabric SQL Analytics Endpoint has limitations?**

* A. Licensing restrictions
* B. Designed only for OLTP
* C. Optimized for analytical read workloads
* D. Hardware constraints

**✅ Answer:** C
**Explanation:** It is optimized for **read-only analytics**, not transactional processing.

---





