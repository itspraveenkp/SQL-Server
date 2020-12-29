Use UAT
Select Name, Gender,Salary,
Rank() over (order by Salary Desc) As [Rank],
Dense_Rank() over (Order by Salary Desc) As [Dense_rank]
From Employee_s

Select Name,Gender,Salary,
Rank() over (partition by gender order by Salary Desc) As [Rank],
Dense_Rank() over (partition by Gender Order by Salary Desc) As [Dense_rank]
From Employee_s


--CTE
WITH Result AS
(
    SELECT Salary, RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
    FROM Employees
)
SELECT TOP 1 Salary FROM Result WHERE Salary_Rank = 2

---------------------------------------------

WITH Result AS
(
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
    FROM Employees
)
SELECT TOP 1 Salary FROM Result WHERE Salary_Rank = 2


--------------------------------------

WITH Result AS
(
    SELECT Salary, Gender,
           DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC)
           AS Salary_Rank
    FROM Employees
)
SELECT TOP 1 Salary FROM Result WHERE Salary_Rank = 3
AND Gender = 'Female'