Create table Emloyees
(
	Id int primary key,
	Name varchar(50),
	Gender varchar(50)
)

Select * from Emloyees

--Start From Here
create type EmpTableType as Table
(
	Id int primary key,
	Name varchar(50),
	Gender varchar(50)
)

Create procedure SpinsertEmployees
@EmpTableType EmpTableType readonly
As
	Begin
		insert into Emloyees
		Select * from @EmpTableType
	End

DECLARE @EmployeeTableType EmpTableType

INSERT INTO @EmployeeTableType VALUES (1, 'Mark', 'Male')


INSERT INTO @EmployeeTableType VALUES (2, 'Mary', 'Female')
INSERT INTO @EmployeeTableType VALUES (3, 'John', 'Male')
INSERT INTO @EmployeeTableType VALUES (4, 'Sara', 'Female')
INSERT INTO @EmployeeTableType VALUES (5, 'Rob', 'Male')

EXECUTE spInsertEmployees @EmployeeTableType