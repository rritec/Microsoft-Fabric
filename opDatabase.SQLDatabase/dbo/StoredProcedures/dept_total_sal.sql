CREATE PROCEDURE dept_total_sal
    @p_bonus INT
AS
BEGIN
    -- Optional: clear old data
    DELETE FROM dname_wise_sal;

    -- Insert computed results
    INSERT INTO dname_wise_sal (dname, total_sal_expenditure)
    SELECT d.dname,
           SUM(e.sal + ISNULL(e.comm, 0) + @p_bonus) AS total_sal_expenditure
    FROM emp e
    JOIN dept d
        ON e.deptno = d.deptno
    GROUP BY d.dname;
END;

GO

