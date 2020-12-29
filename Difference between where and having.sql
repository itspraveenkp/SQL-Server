Create table Sales
(
    Product nvarchar(50),
    SaleAmount int
)
Go

Insert into Sales values ('iPhone', 500)
Insert into Sales values ('Laptop', 800)
Insert into Sales values ('iPhone', 1000)
Insert into Sales values ('Speakers', 400)
Insert into Sales values ('Laptop', 600)
Go


SELECT product, Sum(SaleAmount) as TotalSales 
FROM sales
GROUP By Product
HAVING Sum(SaleAmount) > 1000


SELECT product, Sum(SaleAmount) as TotalSales 
FROM sales
WHERE Product IN('iPhone','Speakers')
GROUP By Product

SELECT product, Sum(SaleAmount) as TotalSales 
FROM sales
WHERE Product IN('iPhone','Speakers')
GROUP By Product
HAVING Sum(SaleAmount) > 1000
