Create Table tblProducts
(
 [Id] int identity primary key,
 [Name] nvarchar(50),
 [Description] nvarchar(250)
)

Create Table tbl_ProductSales
(
 Id int primary key identity,
 ProductId int foreign key references tblProducts(Id),
 UnitPrice int,
 QuantitySold int
)

Insert into tblProducts values ('TV', '52 inch black color LCD TV')
Insert into tblProducts values ('Laptop', 'Very thin black color acer laptop')
Insert into tblProducts values ('Desktop', 'HP high performance desktop')

Insert into tbl_ProductSales values(3, 450, 5)
Insert into tbl_ProductSales values(2, 250, 7)
Insert into tbl_ProductSales values(3, 450, 4)
Insert into tbl_ProductSales values(3, 450, 9)

Select Id,Name,[Description] 
from tblProducts
where Id not in(select distinct productid from tbl_ProductSales)


Select p.Id,name, [Description]
from tblProducts as p
inner join tbl_ProductSales
on p.Id = tbl_ProductSales.ProductId

Select p.Id,name, [Description]
from tblProducts as p
Left join tbl_ProductSales as ps
on p.Id = ps.ProductId
where ps.ProductId is null

SELECT Name,
(SELECT SUM(QUANTITYSOLD) FROM tbl_ProductSales WHERE ProductId = tblProducts.Id) AS QTYSOLD
FROM tblProducts
ORDER BY Name

SELECT Name,SUM(QUANTITYSOLD) AS QTYSOLD
FROM tblProducts
LEFT JOIN tbl_ProductSales
ON tblProducts.Id= tbl_ProductSales.ProductId
GROUP BY NAME

