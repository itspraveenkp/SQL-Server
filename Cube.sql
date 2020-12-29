USE UAT

Select Country,Gender, Sum(Salary) as ToatlSalary
From Employees
Group by Cube(Country,Gender)

--OR

Select Country,Gender,Sum(Salary) as totalSalary
From Employees
Group by Country,Gender with Cube

-- The Above query is equivalent to the following Grouping Sets Query
Select Country,Gender,Sum(Salary)
From Employees
Group By 
	Grouping Sets
	(
		(Country,Gender),
		(Country),
		(Gender),
		()
	)

--The above query is equivalent to the following UNION ALL query. 
--While the data in the result set is the same, the ordering is not. 
--Use ORDER BY to control the ordering of rows in the result set.

SELECT Country, Gender, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Country, Gender

UNION ALL

SELECT Country, NULL, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Country

UNION ALL

SELECT NULL, Gender, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Gender

UNION ALL

SELECT NULL, NULL, SUM(Salary) AS TotalSalary
FROM Employees