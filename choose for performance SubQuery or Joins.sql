use UAT

Select Id, Name, Description
from tblProduct
where ID IN
(
 Select ProductId from tblProductSales
)

--At this stage please clean the query and execution plan cache using the following T-SQL command. 
CHECKPOINT; 
GO 
DBCC DROPCLEANBUFFERS; -- Clears query cache
Go
DBCC FREEPROCCACHE; -- Clears execution plan cache
GO

Select distinct tblProduct.Id, Name, Description
from tblProduct
inner join tblProductSales
on tblProduct.Id = tblProductSales.ProductId


Select Id, Name, [Description]
from tblProduct
where Not Exists(Select * from tblProductSales where ProductId = tblProduct.Id)

Select tblProducts.Id, Name, [Description]
from tblProducts
left join tblProductSales
on tblProducts.Id = tblProductSales.ProductId
where tblProductSales.ProductId IS NULL 