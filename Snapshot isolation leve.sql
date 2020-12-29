
--Transaction 1

use UAT
Set transaction isolation level serializable

Begin Transaction
update TBLINVENTORY set ITEMINSTOCK = 5 where id= 1
waitfor delay '00:00:10'
commit transaction 

-- Transaction 2
Set transaction isolation level serializable
Select ItemInStock from tblInventory where Id = 1


--Transaction 1
Set transaction isolation level serializable
Begin Transaction
Update tblInventory set ItemInStock = 5 where Id = 1
waitfor delay '00:00:10'
Commit Transaction

-- Transaction 2
-- Enable snapshot isloation for the database
Alter database SampleDB SET ALLOW_SNAPSHOT_ISOLATION ON
-- Set the transaction isolation level to snapshot
Set transaction isolation level snapshot
Update tblInventory set ItemInStock = 8 where Id = 1


