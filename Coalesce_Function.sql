Create table Employee
(
	Id int identity(1,1),
	FirstName varchar(250),
	MiddleName varchar(250),
	LastName varchar(250)
)

insert into Employee(FirstName,MiddleName,LastName) 
values('Sam','Null','Null'),('Null','Tod','Tanzan'),('Null','Null','Sara'),('Ben','Parker','Null'),('james','Nick','nancy')

Select * from Employee

Select Id, coalesce(FirstName,MiddleName,LastName) as Name
from Employee

