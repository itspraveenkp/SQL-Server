USE UAT

Create table Departments
(
    DepartmentId int primary key,
    DepartmentName nvarchar(50)
)
Go

Insert into Departments values (1, 'IT')
Insert into Departments values (2, 'HR')
Insert into Departments values (3, 'Payroll')
Go

Create table Employeesss
(
    Id int primary key,
    Name nvarchar(100),
    Gender nvarchar(10),
    Salary int,
    DeptId int foreign key references Departments(DepartmentId)
)
Go

Insert into Employeesss values (1, 'Mark', 'Male', 50000, 1)
Insert into Employeesss values (2, 'Sara', 'Female', 65000, 2)

 
Insert into Employeesss values (3, 'Mike', 'Male', 48000, 3)
Insert into Employeesss values (4, 'Pam', 'Female', 70000, 1)
Insert into Employeesss values (5, 'John', 'Male', 55000, 2)
Go


--1. Copy all rows and columns from an existing table into a new table. This is extremely useful when you want to make a backup copy of the existing table.
SELECT * INTO EmployeessBackup FROM Employeess

--2. Copy all rows and columns from an existing table into a new table in an external database.
SELECT * INTO HRDB.dbo.EmployeessBackup FROM Employeess

--3. Copy only selected columns into a new table
SELECT Id, Name, Gender INTO EmployeessBackup FROM Employeess

--4. Copy only selected rows into a new table
SELECT * INTO EmployeessBackup FROM Employeess WHERE DeptId = 1

--5. Copy columns from 2 or more table into a new table
SELECT * INTO EmployeessBackup
FROM Employeess
INNER JOIN Departments
ON Employeess.DeptId = Departments.DepartmentId

--6. Create a new table whose columns and datatypes match with an existing table. 
SELECT * INTO EmployeessBackup FROM Employeess WHERE 1 <> 1

--7. Copy all rows and columns from an existing table into a new table on a different SQL Server instance. For this, create a linked server and use the 4 part naming convention
--SELECT * INTO TargetTable
--FROM [SourceServer].[SourceDB].[dbo].[SourceTable]

