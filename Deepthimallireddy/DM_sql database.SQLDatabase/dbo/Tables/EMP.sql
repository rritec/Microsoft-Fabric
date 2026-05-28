CREATE TABLE [dbo].[EMP] (
    [EMPNO]    INT          NOT NULL,
    [ENAME]    VARCHAR (20) NULL,
    [JOB]      VARCHAR (20) NULL,
    [MGR]      INT          NULL,
    [HIREDATE] DATE         NULL,
    [SAL]      MONEY        NULL,
    [COMM]     MONEY        NULL,
    [DEPTNO]   INT          NULL,
    PRIMARY KEY CLUSTERED ([EMPNO] ASC)
);


GO

