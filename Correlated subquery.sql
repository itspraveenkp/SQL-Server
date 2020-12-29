SELECT ID,NAME,DESCRIPTION
FROM tblProducts
WHERE ID NOT IN (SELECT DISTINCT PRODUCTID FROM tblProductSales)

Select [Name],
(Select SUM(QuantitySold) from tblProductSales where ProductId = tblProducts.Id) as TotalQuantity
from tblProducts
order by Name