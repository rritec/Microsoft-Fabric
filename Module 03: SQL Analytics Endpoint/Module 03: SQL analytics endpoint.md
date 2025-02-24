# Module 03: SQL Analytics Endpoint

## Microsoft Fabric SQL Analytics Endpoint
- The SQL Analytics Endpoint in Microsoft Fabric is a key component that allows users to query and analyze data stored in OneLake using SQL-based tools and services.
- It provides a **serverless SQL** experience, enabling seamless integration with **Power BI, Azure Synapse, and other analytical tools**.

## 1. **Basic Queries**
### **1.1 Select All Data**
```sql
SELECT * FROM emp;
SELECT * FROM dept;
```

### **1.2 Selecting Specific Columns**
```sql
SELECT emp_id, emp_name, salary FROM emp;
SELECT dept_id, dept_name FROM dept;
```

---

## 2. **Joins - Combining `emp` and `dept` Tables**
### **2.1 INNER JOIN - Employees with Departments**
```sql
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM emp e
INNER JOIN dept d ON e.dept_id = d.dept_id;
```

### **2.2 LEFT JOIN - All Employees, Even Without Departments**
```sql
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM emp e
LEFT JOIN dept d ON e.dept_id = d.dept_id;
```

### **2.3 FULL OUTER JOIN - Show All Employees and Departments**
```sql
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM emp e
FULL OUTER JOIN dept d ON e.dept_id = d.dept_id;
```

---

## 3. **Aggregations & Grouping**
### **3.1 Count Employees per Department**
```sql
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM dept d
LEFT JOIN emp e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

### **3.2 Average Salary per Department**
```sql
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM dept d
LEFT JOIN emp e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;
```

### **3.3 Employees with Salary Above Department Average**
```sql
SELECT e.emp_name, e.salary, d.dept_name
FROM emp e
JOIN dept d ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(salary) FROM emp WHERE dept_id = e.dept_id
);
```

---

## 4. **Window Functions**
### **4.1 Rank Employees by Salary per Department**
```sql
SELECT e.emp_name, e.salary, d.dept_name,
       RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS salary_rank
FROM emp e
JOIN dept d ON e.dept_id = d.dept_id;
```

### **4.2 Running Total of Salaries**
```sql
SELECT e.emp_name, e.salary,
       SUM(e.salary) OVER (ORDER BY e.salary) AS running_total
FROM emp e;
```

---

## 5. **Common Table Expressions (CTEs)**
### **5.1 Finding Highest Paid Employee per Department**
```sql
WITH RankedSalaries AS (
    SELECT e.emp_name, e.salary, e.dept_id,
           RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rnk
    FROM emp e
)
SELECT emp_name, salary, dept_id FROM RankedSalaries WHERE rnk = 1;
```

---

## 6. **Views & Materialized Views**
### **6.1 Creating a View for Employees with Department Names**
```sql
CREATE VIEW vw_emp_details AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM emp e
JOIN dept d ON e.dept_id = d.dept_id;
```

### **6.2 Querying the View**
```sql
SELECT * FROM vw_emp_details;
```

---

## 7. **Performance Optimization**
### **7.1 Creating an Index on Salary for Faster Queries**
```sql
CREATE INDEX idx_salary ON emp (salary);
```

### **7.2 Using Materialized Views for Aggregated Data**
```sql
CREATE MATERIALIZED VIEW mv_avg_salary AS
SELECT dept_id, AVG(salary) AS avg_salary
FROM emp
GROUP BY dept_id;
```
```sql
SELECT * FROM mv_avg_salary;
```

---
