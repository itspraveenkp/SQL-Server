USE UAT

SELECT NAME,Gender,Salary,
SUM(Salary) OVER(ORDER BY SALARY) AS RUNNINGTOTAL
FROM Employees



SELECT NAME,Gender,Salary,
SUM(Salary) OVER(ORDER BY SALARY ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS RUNNINGTOTAL
FROM Employees


SELECT NAME,Gender,Salary,
SUM(Salary) OVER(ORDER BY SALARY RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS RUNNINGTOTAL
FROM Employees


SELECT NAME,Salary,Gender,
SUM(Salary) OVER(ORDER BY SALARY) AS[DEFAULT], --DEFAULT VALUES
SUM(SALARY) OVER(ORDER BY SALARY RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RANGERUNNINGTOTAL,--RETURN WITH DUPLICATE VALUE
SUM(Salary) OVER(ORDER BY SALARY ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ROWRUNNINGTOTAL-- NO DUPLICATE VALUES
FROM Employees

 