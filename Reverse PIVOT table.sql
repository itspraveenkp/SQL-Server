USE UAT

Create Table tbl__ProductSales
(
     SalesAgent nvarchar(10),
     Country nvarchar(10),
     SalesAmount int
)
Go

Insert into tbl__ProductSales values('David','India',960)
Insert into tbl__ProductSales values('David','US',520)
			
 			
Insert into tbl__ProductSales values('John','India',970)
Insert into tbl__ProductSales values('John','US',540)
Go

SELECT * FROM tbl__ProductSales

--PIVOT
SELECT SalesAgent,INDIA,US
FROM tbl__ProductSales
PIVOT
(
	SUM(SalesAmount)
	FOR Country IN(INDIA,US)
) AS PIVOTTABLE



SELECT SALESAGENT,COUNTRY,SALESAMOUNT
FROM
(SELECT SalesAgent,INDIA,US
FROM tbl__ProductSales
PIVOT
(
	SUM(SalesAmount)
	FOR Country IN(INDIA,US)
) AS PIVOTTABLE) P
UNPIVOT
(
	SALESAMOUNT
	FOR COUNTRY IN(INDIA,US)
) AS UNPIVOTTABLE