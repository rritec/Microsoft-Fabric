# Clone a table with T-SQL in a Warehouse
## Clone a table within the same schema

``` sql
--Create a clone of the dbo.emp table.
 CREATE TABLE [dbo].[emp1] AS CLONE OF [dbo].[emp];
```

## Clone a table across schemas within the same warehouse
``` sql
--Create a new schema within the warehouse named dbo1.
 CREATE SCHEMA dbo1;
 GO

 --Create a clone of dbo.emp table in the dbo1 schema.
 CREATE TABLE [dbo1].[emp1] AS CLONE OF [dbo].[emp];
```

## update any one row
1. before updating notedown UTC timestamp
``` sql
--Retrieve the current (UTC) timestamp.
 SELECT CURRENT_TIMESTAMP;
```
2. Update one row

``` sql
update emp
set sal = 801
where empno='7369'
```
## create a table clone as of a past point in time
``` sql
--Create a clone of the dbo.emp table at a specific point in time.   
CREATE TABLE [dbo].[emp2] AS CLONE OF [dbo].[emp] AT '2025-01-01T10:00:00.000';
```
