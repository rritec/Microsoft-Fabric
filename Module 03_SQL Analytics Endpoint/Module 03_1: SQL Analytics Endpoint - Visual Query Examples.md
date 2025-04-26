# Microsoft Fabric SQL Analytics Endpoint - Visual Query Examples

## Example 1: Visual Query to Analyze Employee Salary Distribution
### **Step 1: Open the Visual Query Editor**
1. Go to **Microsoft Fabric** and navigate to your **SQL Analytics Endpoint**.
2. Select your database and click on **Visual Query**.

### **Step 2: Add Tables**
1. Drag and drop the `emp` table onto the canvas.
2. Drag and drop the `dept` table onto the canvas.

### **Step 3: Create a Join**
1. Connect `emp.deptno` with `dept.deptno` to create an **INNER JOIN**.
2. Select **Columns to Include**:
   - `emp.ename`
   - `emp.job`
   - `emp.sal`
   - `dept.dname`

### **Step 4: Add Aggregations**
1. Click on **Aggregations**.
2. Choose **Average Salary (AVG)** for `sal` grouped by `dept.dname`.
3. Click **Run** to execute the query.

![image](https://github.com/user-attachments/assets/7eb8494b-d637-490a-98b7-b3f42ab954ac)

---

## Example 2: Visual Query to Filter High-Earning Employees
### **Step 1: Open the Visual Query Editor**
1. Navigate to **Visual Query** in your **SQL Analytics Endpoint**.
2. Drag the `emp` table to the canvas.

### **Step 2: Apply Filters**
1. Click on `sal` and add a filter **Greater than 5000**.
2. Select columns to display:
   - `emp.ename`
   - `emp.job`
   - `emp.sal`

### **Step 3: Sort Results**
1. Sort `sal` in **Descending Order**.
2. Click **Run**.

### **Generated SQL Query:**
```sql
SELECT ename, job, sal 
FROM emp 
WHERE sal > 5000 
ORDER BY sal DESC;
```
![image](https://github.com/user-attachments/assets/07fd9761-9d10-4566-8f9d-bd7235046319)

---
