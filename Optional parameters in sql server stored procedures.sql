if exists (Select * from INFORMATION_SCHEMA.TABLES Where TABLE_NAME='tblEmployee')
Begin
	Drop table tblEmployee
	print 'Droped successfully'
End
else
Begin

CREATE TABLE tblEmployee
(
 Id int IDENTITY PRIMARY KEY,
 Name nvarchar(50),
 Email nvarchar(50),
 Age int,
 Gender nvarchar(50),
 HireDate date,
)
print 'table created successfully'
End
-----------------------------------------------------
if OBJECT_ID('tblEmployee') is not null
Begin
	Drop table tblEmployee
	print 'Droped'
End
CREATE TABLE tblEmployee
(
 Id int IDENTITY PRIMARY KEY,
 Name nvarchar(50),
 Email nvarchar(50),
 Age int,
 Gender nvarchar(50),
 HireDate date,
)
print 'created'


Insert into tblEmployee values
('Sara Nan','Sara.Nan@test.com',35,'Female','1999-04-04')
Insert into tblEmployee values
('James Histo','James.Histo@test.com',33,'Male','2008-07-13')
Insert into tblEmployee values
('Mary Jane','Mary.Jane@test.com',28,'Female','2005-11-11')
Insert into tblEmployee values
('Paul Sensit','Paul.Sensit@test.com',29,'Male','2007-10-23')


create procedure spsearchEmployes
@Name nvarchar(50),
@Email nvarchar(50),
@Age int,
@Gender nvarchar(50)
as
Begin
	Select * from tblEmployee 
	where
	(Name = @Name or @Name is null) and 
	(Email = @Email or @Email is null) and
	(Age = @Age or @Age is null) and 
	(Gender = @Gender or @Gender is null)
End

exec spsearchEmployes 'pk','it@gmail',26,'Male'
declare @Genderi nvarchar(50)
