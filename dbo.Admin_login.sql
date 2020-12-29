use shopping

CREATE TABLE [dbo].[Admin_login]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [Username] VARCHAR(50) NULL, 
    [Password] VARCHAR(50) NULL
)


create table [dbo].[Product]
(
	Id int primary key identity,
	Product_name varchar(50),
	product_desc varchar(max),
	Product_price int,
	Product_qty int,
	Product_image varchar(max)
)

