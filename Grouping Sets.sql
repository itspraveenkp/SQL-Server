Use UAT

--SQL Script to create and populate Employees table
Create Table Employees
(
    Id int primary key,
    Name nvarchar(50),
    Gender nvarchar(10),
    Salary int,
    Country nvarchar(10)
)
Go
--Drop table Employees

Insert Into Employees Values (1, 'Mark', 'Male', 5000, 'USA')
Insert Into Employees Values (2, 'John', 'Male', 4500, 'India')
Insert Into Employees Values (3, 'Pam', 'Female', 5500, 'USA')
Insert Into Employees Values (4, 'Sara', 'Female', 4000, 'India')
Insert Into Employees Values (5, 'Todd', 'Male', 3500, 'India')
Insert Into Employees Values (6, 'Mary', 'Female', 5000, 'UK')
Insert Into Employees Values (7, 'Ben', 'Male', 6500, 'UK')
Insert Into Employees Values (8, 'Elizabeth', 'Female', 7000, 'USA')
Insert Into Employees Values (9, 'Tom', 'Male', 5500, 'UK')
Insert Into Employees Values (10, 'Ron', 'Male', 5000, 'USA')
Go


Select country,gender, sum(salary) 
From Employees
Group by Country,Gender

UNION All

Select Country, Null,Sum(Salary)  
From Employees
Group By Country

UNION ALL

Select Null,Gender,Sum(Salary)
From Employees
Group By Gender

UNION ALL

Select Null,Null,Sum(Salary)
From Employees

-- insteed of this use Grouping Sets

Select Country, Gender,Sum(Salary)
From Employees
Group BY 
	Grouping Sets
		(
			(Country,Gender),
			(Country),
			(Gender),
			()
		)
Order by Grouping(Country),Grouping(Gender),Gender
