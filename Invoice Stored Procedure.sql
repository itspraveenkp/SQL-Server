
--https://www.red-gate.com/simple-talk/sql/t-sql-programming/using-stored-procedures-to-provide-an-applications-business-logic-layer/
--create database Stored_Procedure
--Use Stored_Procedure

create procedure dbo.Maintain_Invoice_Header
--start
--***********************************************
--action =0 Query, =1 insert, =2 Update/save, =3 Delete
(
@action			TINYINT,	
@InvoiceNo		VARCHAR(20)	=NULL,
@invoiceDate	DATE =NULL,
@CustomerID		VARCHAR(20) =NULL,
@CustomerName	VARCHAR(100) =NULL,
@CustomerAddr1	VARCHAR(100) =NULL,
@CustomerAddr2	VARCHAR(100) =NULL,
@CustomerZipCode VARCHAR(10) =NULL
)

AS
	BEGIN;
		SET NOCOUNT ON;
--**********************************************************
--DECLARE SECTION
	
	DECLARE @ERROR_CODE INT =0,
			@NEXTINVOICENO VARCHAR(MAX),
			@INVOICEPREFIX VARCHAR(5);

	DECLARE @INVOICE	TABLE
	(
		InvoiceNo		VARCHAR NULL,
		InvoiceDate		DATE	NULL,
		CustomerID		VARCHAR(20) NULL,
		CustomerName	VARCHAR(100) NULL,
		CustomerAddr1	VARCHAR(100) NULL,
		CustomerAddr2	VARCHAR(100) NULL,
		CustomerZipCode	VARCHAR(10) NULL
	);

	--Cleanse/transform the input parameters
	SELECT @action				=CASE
								 WHEN @action IN (0, 1, 2, 3) THEN @action ELSE -1
								 END

	--Convert blanks passed to parameters to NULL
	--in case the developers didn't
	,@InvoiceNo		= NULLIF (@InvoiceNo, '')
	,@CustomerID	=NULLIF	(@CustomerID, '')
	,@CustomerName	=NULLIF(@CustomerName, '')
	,@CustomerAddr1	=NULLIF(@CustomerAddr1, '')
	,@CustomerAddr2 =NULLIF(@CustomerAddr2, '')
	,@CustomerZipCode =NULLIF(@CustomerZipCode, '')

	--Parameters Auditing System

	--After cleansing, @action should be 0, 1, 2, 3
	IF @ERROR_CODE = 0 AND @action NOT IN (0, 1, 2, 3)
		SELECT @ERROR_CODE = 1;

	--@InvoiceNo required on query or delete
	IF @ERROR_CODE = 0 AND @action IN (0,3) AND @InvoiceNo IS NULL
		SELECT @ERROR_CODE = 2;

	--@InvoiceNo not allowed on insert (generated on save)
	IF @ERROR_CODE = 0 AND @action = 1 AND @InvoiceNo IS NOT NULL 
		SELECT @ERROR_CODE = 3;

	--@CustomerID is required on insert
	IF @ERROR_CODE = 0 AND @action = 1 AND @CustomerID IS NULL
		SELECT @ERROR_CODE = 4;

	--Validate required (NOT NULL) field on update/save
	IF @ERROR_CODE = 0 AND @action = 2 AND @invoiceDate IS NULL
		SELECT @ERROR_CODE = 5;

	ELSE IF @ERROR_CODE = 0 AND @action = 2 AND @CustomerID IS NULL
		SELECT @ERROR_CODE = 6;

	ELSE IF @ERROR_CODE = 0 AND @action = 2 AND  @CustomerName IS NULL
		SELECT @ERROR_CODE = 7;

	ELSE IF @ERROR_CODE = 0 AND @action = 2 AND @CustomerAddr1 IS NULL
		SELECT @ERROR_CODE = 8;

	--ELSE IF @ERROR_CODE = 0 AND @action = 2 AND @CustomerAddr2 IS NULL
	--	SELECT @ERROR_CODE = 9;

	ELSE IF @ERROR_CODE = 0 AND @action = 2 AND @CustomerZipCode IS NULL
		SELECT @ERROR_CODE = 9;










































