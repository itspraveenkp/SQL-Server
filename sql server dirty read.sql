CREATE TABLE TBLINVENTORY
(
	ID INT IDENTITY(1,1),
	PRODUCT NVARCHAR(100),
	ITEMINSTOCK INT
)
GO

INSERT INTO TBLINVENTORY VALUES('IPHON', 10)

SELECT * FROM TBLINVENTORY

--Transaction 1 : 
Begin Tran
Update tblInventory set ITEMINSTOCK = 9 where Id=1

-- Billing the customer
Waitfor Delay '00:00:15'
-- Insufficient Funds. Rollback transaction

Rollback Transaction

--Transaction 2 :
Set Transaction Isolation Level Read Uncommitted
Select * from tblInventory where Id=1

Select * from tblInventory (NOLOCK) where Id=1