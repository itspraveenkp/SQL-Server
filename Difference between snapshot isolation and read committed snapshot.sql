use UAT
--Transaction 1
Set transaction isolation level snapshot
Begin Transaction
Update TBLINVENTORY set ItemInStock = 8 where Id = 1
waitfor delay '00:00:10'
Commit Transaction

-- Transaction 2
Set transaction isolation level snapshot
Begin Transaction
Update tblInventory set ItemInStock = 5 where Id = 1
Commit Transaction


Alter database SampleDB SET ALLOW_SNAPSHOT_ISOLATION OFF

Alter database SampleDB SET READ_COMMITTED_SNAPSHOT ON

--Transaction 1
Set transaction isolation level read committed
Begin Transaction
Update tblInventory set ItemsInStock = 8 where Id = 1
waitfor delay '00:00:10'
Commit Transaction

-- Transaction 2
Set transaction isolation level read committed
Begin Transaction
Update tblInventory set ItemsInStock = 5 where Id = 1
Commit Transaction

