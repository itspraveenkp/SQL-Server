USE UAT

SELECT NEWID() AS GUID_NUMER

DECLARE @ID UNIQUEIDENTIFIER
SET @ID = NEWID()

SELECT @ID AS GUID_NUMER

Create Table USACustomers
(
     ID int primary key identity,
     Name nvarchar(50)
)
Go

Insert Into USACustomers Values ('Tom')
Insert Into USACustomers Values ('Mike')

Select * From dbo.USACustomers



Create Table USACustomers2
(
     ID int primary key identity,
     Name nvarchar(50)
)
Go

Insert Into USACustomers2 Values ('Tom')
Insert Into USACustomers2 Values ('Mike')

Select * From dbo.USACustomers2



Create Table Customers
(
     ID int primary key,
     Name nvarchar(50)
)


INSERT INTO Customers 
SELECT * FROM dbo.USACustomers
UNION ALL
SELECT * FROM dbo.USACustomers2

--Msg 2627, Level 14, State 1, Line 45
--Violation of PRIMARY KEY constraint 'PK__Customer__3214EC274996A34C'. Cannot insert duplicate key in object 'dbo.Customers'. The duplicate key value is (1).
--The statement has been terminated.

SELECT * FROM Customers

DROP TABLE USACustomers
DROP TABLE USACustomers2

Create Table USACustomers
(
     --ID int primary key identity,
     ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	 Name nvarchar(50)
)
Go

Insert Into USACustomers Values (DEFAULT,'Tom')
Insert Into USACustomers Values (DEFAULT,'Mike')

Select * From dbo.USACustomers



Create Table USACustomers2
(
     --ID int primary key identity,
	 ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
     Name nvarchar(50)
)
Go

Insert Into USACustomers2 Values (DEFAULT,'Tom')
Insert Into USACustomers2 Values (DEFAULT,'Mike')

Select * From dbo.USACustomers2

DROP TABLE Customers

Create Table Customers
(
     ID UNIQUEIDENTIFIER primary key DEFAULT NEWID(),
     Name nvarchar(50)
)



INSERT INTO Customers
SELECT * FROM USACustomers
UNION ALL 
SELECT * FROM USACustomers2

SELECT * FROM Customers