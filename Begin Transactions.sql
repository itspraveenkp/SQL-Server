use UAT

Create Table tblMailingAddress
(
   AddressId int NOT NULL primary key,
   EmployeeNumber int,
   HouseNumber nvarchar(50),
   StreetAddress nvarchar(50),
   City nvarchar(10),
   PostalCode nvarchar(50)
)


Insert into tblMailingAddress values (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW')


 

Create Table tblPhysicalAddress
(
 AddressId int NOT NULL primary key,
 EmployeeNumber int,
 HouseNumber nvarchar(50),
 StreetAddress nvarchar(50),
 City nvarchar(10),
 PostalCode nvarchar(50)
)

Insert into tblPhysicalAddress values (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW')


Select *from tblMailingAddress
Select * from tblPhysicalAddress

create procedure spUpdateAddress
As
Begin
	Begin try
	begin transaction
	update tblMailingAddress set City ='LONDON'
	where AddressId = 1 and EmployeeNumber = 101

	update tblPhysicalAddress set City='LONDON'
	where AddressId = 1 and EmployeeNumber = 101
	commit Transaction
	End try
	Begin Catch
	Rollback Transaction
	End catch
End

Alter procedure spUpdateAddress
As
Begin
	Begin try
	begin transaction
	update tblMailingAddress set City ='LONDON2'
	where AddressId = 1 and EmployeeNumber = 101

	update tblPhysicalAddress set City='LONDON2'
	where AddressId = 1 and EmployeeNumber = 101
	commit Transaction

	End try
	Begin Catch
	Rollback Transaction

	End catch
End
