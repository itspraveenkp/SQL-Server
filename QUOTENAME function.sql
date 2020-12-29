Create table [USA Customers]
(
     ID int primary key identity,
     FirstName nvarchar(50),
     LastName nvarchar(50),
     Gender nvarchar(50)
)
Go

Insert into [USA Customers] values ('Mark', 'Hastings', 'Male')
Insert into [USA Customers] values ('Steve', 'Pound', 'Male')
Insert into [USA Customers] values ('Ben', 'Hoskins', 'Male')
Insert into [USA Customers] values ('Philip', 'Hastings', 'Male')
Insert into [USA Customers] values ('Mary', 'Lambeth', 'Female')
Insert into [USA Customers] values ('Valarie', 'Vikings', 'Female')
Insert into [USA Customers] values ('John', 'Stanmore', 'Male')
Go


select * from [USA Customers]


Declare @sql nvarchar(max)
Declare @tablename nvarchar(50)
set @tablename = 'USA Customers'
set @sql = 'Select * from ' + @tablename
Execute sp_executesql @sql

--When we execute the above script, we get the following error
--Msg 102, Level 15, State 1, Line 20
--Incorrect syntax near 'from USA

--Bad Dclarelation
Declare @sql nvarchar(max)
Declare @tablename nvarchar(50)
set @tablename = '[USA Customers] drop database testDB'
set @sql = 'Select * from ' + @tablename
Execute sp_executesql @sql

--Bad Declaration
--create database testDB
Declare @sql nvarchar(max)
Declare @tablename nvarchar(50)
set @tablename = 'USA Customers] drop database testDB--'
set @sql = 'Select * from [' + @tablename  + ']'
Execute sp_executesql @sql


--Good Declaration
Declare @sql nvarchar(max)
Declare @tablename nvarchar(50)
set @tablename = 'USA Customers'
set @sql = 'Select * from ' + quotename(@tablename)
Execute sp_executesql @sql

Declare @sql nvarchar(max)
Declare @tablename nvarchar(50)
set @tablename = 'USA Customers'
set @sql = 'Select * from ' + quotename('dbo') + '.' + quotename(@tablename)
Execute sp_executesql @sql

select QUOTENAME('Indian customer', '"')

select QUOTENAME('Indian customer', '''')

select QUOTENAME('Indian customer', '}')
select QUOTENAME('Indian customer', ']')
select QUOTENAME('Indian ] customer')
select QUOTENAME('Indian customer')

Declare @tableName nvarchar(50)
set @tablename = 'indian ] Customer]'
set @tablename	= QUOTENAME(@tablename)
print @tablename
set @tablename = PARSENAME(@tablename,1)
print @tablename