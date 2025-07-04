# Module 03: SQL Analytics Endpoint

## Microsoft Fabric SQL Analytics Endpoint
- The SQL Analytics Endpoint in Microsoft Fabric is a key component that allows users to query and analyze data stored in OneLake using SQL-based tools and services.
- It provides a **serverless SQL** experience, enabling seamless integration with **Power BI, Azure Synapse, and other analytical tools**.

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


