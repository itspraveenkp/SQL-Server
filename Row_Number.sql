Use UAT

Select Name,Gender,Salary,
Row_Number() OVER(partition by Gender Order by Gender)
From Employee_s

SELECT Name, Gender, Salary,
        ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY Gender) AS RowNumber
FROM Employee_s

