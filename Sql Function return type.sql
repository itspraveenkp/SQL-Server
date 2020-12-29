use DBtest

Alter procedure sp_ReturnTypeProcedure
(
	@ID int,	
	@LastName	varchar(255),
	@FirstName	varchar(255),
	@Age varchar(255),	
	@Salary varchar(255)
)
As

Set nocount on;
Insert into DBtest.dbo.Persons(ID,LastName,FirstName,Age,Salary)values(@ID,@LastName,@FirstName,@Age,@Salary)
return

exec sp_ReturnTypeProcedure 5,'Gupta','Raj',23,'25000'

Select * from DBtest.dbo.Persons

alter table DBtest.dbo.Persons
add Salary nvarchar(255)

update DBtest.dbo.Persons
set Salary = '20000'
where id =2 or id= 3 or id=4


 ID	LastName	FirstName	Age	Salary
1	Barier	Johny	40	20000
2	Barier	Johny	40	20000
3	frier	Anku	39	20000