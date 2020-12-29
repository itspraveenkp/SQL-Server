Create table Location
(
	LocationID int primary key,
	LocationName nvarchar(250)
)

Insert into Location(LocationID,LocationName) Values(1,'Mumbai')
Insert into Location(LocationID,LocationName) Values(2,'Bandra')

Create table Manager
(
 ManagerID int primary key,
 ManagerName nvarchar(250)
)

Insert into Manager(ManagerID,ManagerName) Values(1,'Sumit')
Insert into Manager(ManagerID,ManagerName) Values(2,'Sanjay')

Drop table StatusRrt
(
	StatusID int primary key,
	Active nvarchar(250),
	Deactive nvarchar(250)
)

insert into StatusRrt (StatusID,Active,Deactive) values(1,'1','0')
insert into StatusRrt (StatusID,Active,Deactive) values(2,'1','0')

Create table Employee
(
	empid int identity primary key,
	FirstName nvarchar(250),
	LastName nvarchar(250),
	Email nvarchar(250),
	HireDate datetime,
	LocationsID int foreign key references Location(LocationID), -- Foreign Key
	Managersid int foreign key references Manager(ManagerID), --Foreign key
	StatussID int foreign key references StatusRrt(StatusID), -- Foreign Key
	HiredofSet datetime,
)

Create table EmployeeHistory
(
	empid int ,
	FirstName nvarchar(250),
	LastName nvarchar(250),
	Email nvarchar(250),
	HireDate datetime,
	LocationsID int , -- Foreign Key
	Managersid int, --Foreign key
	StatussID int, -- Foreign Key
	HiredofSet datetime,
)

--SET IDENTITY_INSERT EmployeeHistory ON
 --Set identity_Insert dbo.EmployeeHistory Off
 --Set identity_Insert dbo.Employee On
 --SET IDENTITY_INSERT  [ database_name . ] schema_name . ] table_name { ON | OFF }
 
 exec sp_settriggerorder Tgr_Employee, first, 'INSERT'

 Set identity_Insert dbo.Employee On
 insert into dbo.Employee (empid,FirstName,LastName,Email,HireDate,LocationsID,Managersid,StatussID,HiredofSet)
--Values (@empid,@FirstName,@LastName,@Email,@HireDate,@LocationsID,@Managersid,@StatussID,@HiredofSet)
Values(2,'Yonuo','Tyhom','Yonuo@gmail.com',getdate(),2,2,2,GETDATE())
Set identity_Insert dbo.Employee OFF
