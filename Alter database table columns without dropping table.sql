Create table tblEmployee
(
 ID int primary key identity,
 Name nvarchar(50),
 Gender nvarchar(50),
 Salary nvarchar(50)
)

Insert into tblEmployee values('Sara Nani','Female','4500')
Insert into tblEmployee values('James Histo','Male','5300')
Insert into tblEmployee values('Mary Jane','Female','6200')
Insert into tblEmployee values('Paul Sensit','Male','4200')
Insert into tblEmployee values('Mike Jen','Male','5500')

select * from tblEmployee

select Gender, SUM(Salary) from tblEmployee
group by Gender

Alter table tblEmployee
Alter column salary int

