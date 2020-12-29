Use UAT	

--if table exists drop and recreate
if(Exists (Select * 
		   from INFORMATION_SCHEMA.TABLES
		   where TABLE_NAME = 'tblProductSales'))

Begin
	Drop table tblProductSales
End

if(Exists(Select *
		  from INFORMATION_SCHEMA.TABLES
		  where TABLE_NAME = 'tblProduct'))

Begin
	Drop table tblProduct
End

-- Recreate tables
Create Table tblProduct
(
 [Id] int identity primary key,
 [Name] nvarchar(50),
 [Description] nvarchar(250)
)

Create Table tblProductSales
(
 Id int primary key identity,
 ProductId int foreign key references tblProducts(Id),
 UnitPrice int,
 QuantitySold int
)

--INSERT SAMPLE DATA INTO TBLPRODUCTS TABLE
DECLARE @ID INT
SET @ID = 1

WHILE(@ID <= 10000)
BEGIN 
	INSERT INTO tblProduct VALUES('PRODUCT - ' + CAST(@ID AS NVARCHAR(20)),'PRODUCT - ' 
	+ CAST(@ID AS nvarchar(20)) + 'DESCRIPTION')

	PRINT @ID
	SET @ID = @ID + 1
END

--select upper('select * from tblProduct')
SELECT * FROM TBLPRODUCT

Declare @LL int 
set @LL = 1

Declare @UL int
Set @UL = 5

--SELECT ROUND(((@UL - @LL) * RAND() + 1),0)

DECLARE @RAND INT
WHILE(1 = 1)
BEGIN
	SELECT @RAND = ROUND(((@UL - @LL) * RAND() + 1),0)
	PRINT(@RAND)

	IF(@RAND < 1 OR @RAND >= 5)
	BEGIN
		PRINT 'ERROR - ' + CAST(@RAND AS NVARCHAR(5))
		BREAK
	END	
END


-- Declare variables to hold a random ProductId, 
-- UnitPrice and QuantitySold
declare @RandomProductId int
declare @RandomUnitPrice int
declare @RandomQuantitySold int

-- Declare and set variables to generate a 
-- random ProductId between 1 and 100000
declare @UpperLimitForProductId int
declare @LowerLimitForProductId int

set @LowerLimitForProductId = 1
set @UpperLimitForProductId = 100000

-- Declare and set variables to generate a 
-- random UnitPrice between 1 and 100
declare @UpperLimitForUnitPrice int
declare @LowerLimitForUnitPrice int

set @LowerLimitForUnitPrice = 1
set @UpperLimitForUnitPrice = 100

-- Declare and set variables to generate a 
-- random QuantitySold between 1 and 10
declare @UpperLimitForQuantitySold int
declare @LowerLimitForQuantitySold int

set @LowerLimitForQuantitySold = 1
set @UpperLimitForQuantitySold = 10

--Insert Sample data into tblProductSales table
Declare @Counter int
Set @Counter = 1

While(@Counter <= 450000)
Begin
 select @RandomProductId = Round(((@UpperLimitForProductId - @LowerLimitForProductId) * Rand() + @LowerLimitForProductId), 0)
 select @RandomUnitPrice = Round(((@UpperLimitForUnitPrice - @LowerLimitForUnitPrice) * Rand() + @LowerLimitForUnitPrice), 0)
 select @RandomQuantitySold = Round(((@UpperLimitForQuantitySold - @LowerLimitForQuantitySold) * Rand() + @LowerLimitForQuantitySold), 0)
 
 Insert into tblProductsales 
 values(@RandomProductId, @RandomUnitPrice, @RandomQuantitySold)

 Print @Counter
 Set @Counter = @Counter + 1
End
