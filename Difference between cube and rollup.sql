USE UAT

--Difference between cube and rollup

--CUBE generates a result set that shows aggregates for all combinations of values in the selected columns, 
--where as ROLLUP generates a result set that shows aggregates for a hierarchy of values in the selected columns.

--QL Script to create and populate Sales table
Create table Sales
(
    Id int primary key identity,
    Continent nvarchar(50),
    Country nvarchar(50),
    City nvarchar(50),
    SaleAmount int
)
Go

Insert into Sales values('Asia','India','Bangalore',1000)
Insert into Sales values('Asia','India','Chennai',2000)
Insert into Sales values('Asia','Japan','Tokyo',4000)
Insert into Sales values('Asia','Japan','Hiroshima',5000)
Insert into Sales values('Europe','United Kingdom','London',1000)
Insert into Sales values('Europe','United Kingdom','Manchester',2000)
Insert into Sales values('Europe','France','Paris',4000)
Insert into Sales values('Europe','France','Cannes',5000)
Go

--Select * from sys.tables
--Select * from TableChanges

Select Continent,Country,City,Sum(SaleAmount) 
From Sales
Group by rollup(Continent,Country,City)


Select Continent,Country,City,Sum(SaleAmount) 
From Sales
Group by Continent,Country,City with rollup

-- And Cube

Select Continent,Country,City,Sum(SaleAmount)
From Sales
Group By cube(Continent,Country,City)


Select Continent,Country,City,Sum(SaleAmount)
From Sales
Group By Continent,Country,City With cube