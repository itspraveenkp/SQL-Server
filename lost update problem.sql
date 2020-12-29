USE UAT

-- Transaction 1
BEGIN TRAN 
DECLARE @ITEMSINSTOCK INT

SELECT @ITEMSINSTOCK = ITEMINSTOCK FROM TBLINVENTORY

--transaction takes 10 seconds
waitfor delay '00:00:10'
set @ITEMSINSTOCK = @ITEMSINSTOCK -1

update TBLINVENTORY
set ITEMINSTOCK = @ITEMSINSTOCK where ID= 1

print @ITEMSINSTOCK

commit transaction

select * from tblinventory



-- Transaction 2
Begin Tran
Declare @ItemsInStock int

Select @ItemsInStock = ItemsInStock
from tblInventory where Id=1

-- Transaction takes 1 second
Waitfor Delay '00:00:1'
Set @ItemsInStock = @ItemsInStock - 2

Update tblInventory
Set ItemsInStock = @ItemsInStock where Id=1

Print @ItemsInStock

Commit Transaction
