Use UAT

Select Country,Sum(Salary)
From Employees
Group by Rollup(Country)

--We can write query like this
Select Country, Sum(Salary)
From Employees
Group by (Country) With Rollup

--We can also use UNION ALL operator along with GROUP BY
Select Country,Sum(Salary)
From Employees
Group by Country

UNION All

Select Null,Sum(Salary)
From Employees

--We can use Grouping Sets to Achieve the same result
Select Country,Sum(Salary)
From Employees
Group By 
	Grouping Sets
		(
			(Country),
			()
		)

Select Country,Gender,Sum(Salary)
From Employees
Group By 
	Grouping Sets
		(
			(Country,Gender),
			()
		)