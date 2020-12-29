
Create TABLE [dbo].[customer](
	[customer_id] [int]  NOT NULL,
	[CustomerName] [varchar](250) NULL,
	[CustomerAddress] [varchar](250) NULL,
	[Email] [varchar](250) NULL,
)
GO

Create TABLE [dbo].[customers_History](
	[customer_id] [int]  NOT NULL,
	[CustomerName] [varchar](250) NULL,
	[CustomerAddress] [varchar](250) NULL,
	[Email] [varchar](250) NULL,
)
GO
Select * from dbo.customer
Select * from dbo.customers_History

update dbo.customers
set CustomerName = '',CustomerAddress ='',Email =''
where customer_id = 0
set IDENTITY_INSERT dbo.Customers OFF
set IDENTITY_INSERT dbo.customers_History ON
set IDENTITY_INSERT dbo.Customers OFF
insert into dbo.customer(CustomerName,CustomerAddress,Email) values('KJHHK','KhJHKJHar','IJYTH@gmail.com')

Create trigger dbo.history_New on dbo.Customer
After Insert 
As
Begin
	Declare @Customer_id int;
	Declare @CustomerName varchar(250);
	Declare @CustomerAddress varchar(250);
	Declare @Email varchar(250);

	Select @Customer_id = customerList.Customer_id from inserted customerList;
	Select @CustomerName = customerNameList.CustomerName from inserted customerNameList;
	Select @CustomerAddress = customerAddressList.CustomerAddress from inserted customerAddresslist;
	Select @Email = EmailList.Email from inserted EmailList;

	insert into dbo.customers_History(Customer_id,CustomerName,CustomerAddress,Email)
	Values(@Customer_id,@CustomerName,@CustomerAddress,@Email)

End
GO


Create Trigger dbo.DeleteTable on dbo.orders
after Delete
As
Begin
Insert into dbo.orders_History select * from deleted 
End
GO

Select * from dbo.orders
Select * from orders_History

Delete from dbo.orders
where order_id = 1

