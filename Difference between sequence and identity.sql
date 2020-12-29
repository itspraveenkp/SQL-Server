--Example : Identity property tied to the Id column of the Employees table. 

CREATE TABLE Employees
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50),
    Gender NVARCHAR(10)
)

--Example : Sequence object not tied to any specific table

CREATE SEQUENCE [dbo].[SequenceObject]
AS INT
START WITH 1
INCREMENT BY 1


--Example : Sharing sequence object value with multiple tables.

--Step 1 : Create Customers and Users tables

CREATE TABLE Customers
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    Gender NVARCHAR(10)
)
GO

CREATE TABLE Users
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    Gender NVARCHAR(10)
)
GO

--Step 2 : Insert 2 rows into Customers table and 3 rows into Users table. Notice the same sequence object is generating the ID values for both the tables.

INSERT INTO Customers VALUES
   (NEXT VALUE for [dbo].[SequenceObject], 'Ben', 'Male')
INSERT INTO Customers VALUES
   (NEXT VALUE for [dbo].[SequenceObject], 'Sara', 'Female')

INSERT INTO Users VALUES
   (NEXT VALUE for [dbo].[SequenceObject], 'Tom', 'Male')
INSERT INTO Users VALUES
   (NEXT VALUE for [dbo].[SequenceObject], 'Pam', 'Female')
INSERT INTO Users VALUES
   (NEXT VALUE for [dbo].[SequenceObject], 'David', 'Male')
GO

--Step 3 : Query the tables
SELECT * FROM Customers
SELECT * FROM Users
GO


--Example : Generating Identity value by inserting a row into the table

INSERT INTO Employees VALUES ('Todd', 'Male')

--Example : Generating the next sequence value using NEXT VALUE FOR clause.

SELECT NEXT VALUE FOR [dbo].[SequenceObject]


--Example : Specifying maximum value for the sequence object using the MAXVALUE option

CREATE SEQUENCE [dbo].[SequenceObject]
START WITH 1
INCREMENT BY 1
MAXVALUE 5

--Example : Specifying the CYCLE option of the Sequence object, so the sequence will restart automatically when the max value is exceeded

CREATE SEQUENCE [dbo].[SequenceObject]
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 5
CYCLE