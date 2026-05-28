CREATE PROCEDURE emp_total_sal
AS
BEGIN
-- Drop ResultTable if it exists
IF OBJECT_ID('dbo.ResultTable', 'U') IS NOT NULL
  DROP TABLE dbo.ResultTable;
select empno,ename,sal,comm,sal+isnull(comm,0) as total_sal 
into ResultTable
from emp
END

GO

