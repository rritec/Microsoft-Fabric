# Transformations in Stored Procedure

1. If you are good with coding do transformations inside stored procedure
   
## Create Stored Procedure

1. create Stored procedure inside database


```sql
-- if already procedure available drop it.
DROP PROCEDURE emp_total_sal

-- create procedure
CREATE PROCEDURE emp_total_sal
AS
BEGIN
drop table [dbo].ResultTable
select empno,ename,sal,comm,sal+isnull(comm,0) as total_sal 
into ResultTable
from emp
END
```
## Call this Stored procedure and verify results
``` sql
-- Call the stored procedure
EXEC emp_total_sal;

-- Check the contents of the ResultTable
SELECT * FROM ResultTable;

```

## Questions
## Answers
