Use UAT

Create table tblEmployee
(
 ID int identity primary key,
 Name nvarchar(100),
 Gender nvarchar(10),
 DateOfBirth DateTime
)

if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME='tblemployee')
begin
	Create table tblEmployee
	(
	 ID int identity primary key,
	 Name nvarchar(100),
	 Gender nvarchar(10),
	 DateOfBirth DateTime
	)
print	'table created successfully'
end
else 
begin
	print	'table tblemployee already exists'
end

if OBJECT_ID('tblEmployee') is null
begin 
	Create table tblEmployee
	(
	 ID int identity primary key,
	 Name nvarchar(100),
	 Gender nvarchar(10),
	 DateOfBirth DateTime
	)
	print 'table created successfully'
end
else
begin
	print 'table tblemployee already created'
end

if OBJECT_ID('tblEmployee') is not null
begin
	drop table tblEmployee
end
Create table tblEmployee
	(
	 ID int identity primary key,
	 Name nvarchar(100),
	 Gender nvarchar(10),
	 DateOfBirth DateTime
	)

if not exists (select * from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME ='EmailAddress' and TABLE_NAME= 'tblEmployee' and TABLE_SCHEMA='dbo')
Begin
	Alter table tblEmployee
	ADD EmailAddress nvarchar(50)
End
else
begin
	print 'columns emialaddress already exists'
end

If col_length('tblEmployee','EmailAddress') is not null
Begin
 Print 'Column already exists'
End
Else
Begin
 Print 'Column does not exist'
End