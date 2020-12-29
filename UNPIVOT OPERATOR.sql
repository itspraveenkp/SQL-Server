
USE UAT


Create Table tblProduct_Sales
(
 ID INT IDENTITY(1,1),
 SalesAgent nvarchar(50),
 India int,
 US int,
 UK int
)
Go


--SET IDENTITY_INSERT tblProduct_Sales ON 
--GO

Insert into tblProduct_Sales values ('David', 960, 520, 360)
Insert into tblProduct_Sales values ('John', 970, 540, 800)

--SET IDENTITY_INSERT tblProduct_Sales OFF
--Go



SELECT * FROM tblProduct_Sales


SELECT SalesAgent,Country,SalesAmount
FROM tblProduct_Sales
UNPIVOT
(
	salesAmount
	FOR Country IN (INDIA,US,UK)
) AS PIVOTEXAMPLE

