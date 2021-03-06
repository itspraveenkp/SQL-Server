USE [LAKSHYA]
GO
/****** Object:  StoredProcedure [cdgmaster].[usp_PFReprocessPurchaseFinalPlantwise]    Script Date: 9/19/2019 12:33:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--V20190503
ALTER PROCEDURE [cdgmaster].[usp_PFReprocessPurchaseFinalPlantwise]
( 	
    @PlantCode VARCHAR(10) = '-1'
)

/*
	exec [cdgmaster].[usp_PFReprocessPurchaseFinalPlantwise] @PlantCode=5333
	EXEC [cdgmaster].[usp_PFReprocessPurchaseFinalPlantwise] @PlantCode 5311
	exec [cdgmaster].[usp_PFReprocessPurchaseFinalPlantwise]
	select * from cdgmaster.purchasefinal where statusFlag='E'

	20130601 VikasPawar Reprocess SAP
*/
  
AS
BEGIN
	SET NOCOUNT ON	
		DECLARE @dbug INT
		SET @dbug=0
		
	DECLARE @uploadFileCode BIGINT	
	IF(@dbug>0)
	
		PRINT 'Reached Here'
			
			
	DELETE FROM cdgmaster.PurchaseTemp  Where invoicenumber in (
		select InvoiceNumber from cdgmaster.purchaseFinal pf (nolock) where 
				 pf.invoicenumber not in
				(Select pf2.invoicenumber from cdgmaster.PurchaseFinal pf2 (nolock) where pf.invoicenumber=pf2.invoicenumber and pf2.statusflag='E')
		)
		and uploadfileCode in (select fileUploadedCode from cdgmaster.fileuploaded (nolock) where type='PFSAPInv' and IsError in ('N'))

	CREATE TABLE #Error   
	(   
		Invno FLOAT, 
		FileUploadedCode VARCHAR(200),
		Row_Num VARCHAR(100),
		Row_Delimed VARCHAR(2000),
		Err_Cols VARCHAR(200),
		prodcode VARCHAR(50)
	)  

	CREATE TABLE #DistError   
	(   
		Invno FLOAT,		
		FileUploadedCode VARCHAR(200),
		Row_Num VARCHAR(100),
		Row_Delimed VARCHAR(2000),
		Err_Cols VARCHAR(200),
		DistCode VARCHAR(50)
	)  
	
	CREATE TABLE #PlantError
	(
		Invno FLOAT,		
		FileUploadedCode VARCHAR(200),
		Row_Num VARCHAR(100),
		Row_Delimed VARCHAR(2000),
		Err_Cols VARCHAR(200),
		PlantCode VARCHAR(50)
	)

	CREATE TABLE #UnitError   
	(  
		Invno FLOAT,    
		FileUploadedCode VARCHAR(200),
		Row_Num VARCHAR(100),
		Row_Delimed VARCHAR(2000),
		Err_Cols VARCHAR(200),
		productcode VARCHAR(50)
	)

	CREATE TABLE #UnitError1   
	(   
		Invno FLOAT,   
		FileUploadedCode VARCHAR(200),
		Row_Num VARCHAR(100),
		Row_Delimed VARCHAR(2000),
		Err_Cols VARCHAR(200),
		productcode VARCHAR(50)
	)

		--Start.Code added by Poojan on 16th June 2017.New Requirement for GST--
		create table #MRPError
		(
		--bid int ,
		Invno numeric ,
		FileUploadedCode varchar(200),
		Row_Num varchar(100),
		Row_Delimed varchar(2000),
		Err_Cols varchar(200),
		StateCode varchar(20) ,
		ProductCode varchar(20) ,
		BatchCode varchar(20) ,
		DistCode varchar(20)
		)
		-- end --
	
	DECLARE @serno BIGINT
	Select top 1 @serno=serno from cdgmaster.rerunlogs (nolock) where Jobcode='Reprocess' and isProcessed='N' and pPlantID=@PlantCode
	UPDATE CDGMASTER.RERUNLOGS SET ISPROCESSED='P' WHERE  Jobcode='Reprocess' AND ISPROCESSED ='N' AND serno=@serno and pPlantID=@PlantCode

	DECLARE PUR_FINAL_UPLOADCODE_CURSOR CURSOR LOCAL FAST_FORWARD READ_ONLY
	
	FOR	SELECT DISTINCT fileUploadedCode FROM cdgmaster.purchasefinal with(Nolock) WHERE StatusFlag='E' 
		and isnull(fileUploadedCode,'')<>'' AND (PLANTCODE=@PlantCode OR ISNULL(@PlantCode,'-1')='-1')
	
	OPEN PUR_FINAL_UPLOADCODE_CURSOR
	FETCH NEXT FROM PUR_FINAL_UPLOADCODE_CURSOR INTO @uploadFileCode
		
	WHILE @@FETCH_STATUS=0
		BEGIN
			-------commented on 29Jun2017 ---start
			---DELETE FROM cdgmaster.FileUpLoadedErrorDetail WHERE FileUploadedCode=@uploadFileCode AND Err_Cols IN ('13UUOM','13CUOM','13SUOM','13BUOM','13ConUOM','5IID','9IID','1IID','13CNSKUUOM','13CNSKUBUOM','45BBUOM','44BSKUQty')
			------added on 29Jun2017 --start
			DELETE FROM cdgmaster.FileUpLoadedErrorDetail WHERE FileUploadedCode=@uploadFileCode AND Err_Cols IN ('13UUOM','13CUOM','13SUOM','13BUOM','13ConUOM','5IID','9IID','1IID','13CNSKUUOM','13CNSKUBUOM','45BBUOM','44BSKUQty','53MRPMISMTC','53MRPMIS')
			---end
			
			SELECT	PF.*, PT.xlRowNum INTO #PurchaseFinal
			FROM	cdgmaster.PurchaseFinal PF with(Nolock)
					INNER JOIN cdgmaster.PurchaseTemp PT with(Nolock) ON (PT.intCode=PF.Intcnt)	
			WHERE	PF.FileUploadedCode = @uploadFileCode AND PF.StatusFlag='E' AND (PF.PLANTCODE=@PlantCode OR ISNULL(@PlantCode,'-1')='-1')	
				
           	DECLARE @FileUploaded VARCHAR(10)
			SET @FileUploaded='N' 
			
			---Product Checking
			INSERT INTO #Error  
				SELECT	DISTINCT Invoicenumber AS Invno
						, FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '5IID' AS Err_Cols
						, LTRIM(RTRIM(Productcode)) AS prodcode
				FROM	#PurchaseFinal 
				WHERE	LTRIM(RTRIM(Productcode)) NOT IN( SELECT sapid FROM cdgmaster.sku with (Nolock) WHERE isActive='Y' AND isDeleted='N')
												
			INSERT INTO cdgmaster.FileUpLoadedErrorDetail
				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #Error				
							
			--Distributor Checking
			INSERT INTO #DistError  
				SELECT	DISTINCT Invoicenumber AS Invno
						, p.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + p.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + p.Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						
						AS Row_Delimed
						, '9IID' AS Err_Cols
						, LTRIM(RTRIM(p.DistributorCode)) AS DistCode
				FROM	#PurchaseFinal AS p 
						LEFT JOIN cdgmaster.customer AS c with(Nolock) ON p.Distributorcode=c.sapid AND c.isActive='Y'
				WHERE	c.sapid IS NULL
			
			INSERT INTO cdgmaster.FileUpLoadedErrorDetail
				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #DistError	
				
			--Plant Checking
			INSERT INTO #PlantError
				SELECT 	DISTINCT Invoicenumber AS Invno
						, FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(p.PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						
						 AS Row_Delimed
						, '1IID' AS Err_Cols
						, p.PlantCode AS PlantCode
				FROM	#PurchaseFinal AS p 
						LEFT JOIN cdgmaster.Plant AS s with(Nolock) ON p.PlantCode=s.PlantID AND s.Active='Y'
				WHERE	s.PlantID IS NULL
				
			INSERT INTO cdgmaster.FileUpLoadedErrorDetail
				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #PlantError
								
			--Unit
			INSERT INTO #unitError1
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13UUOM' AS Err_Cols
						, LTRIM(RTRIM(a.Productcode)) AS productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.Invoicenumber=b.Invno AND a.productcode= b.prodcode 
				WHERE	uom NOT IN (SELECT DISTINCT unitid FROM cdgmaster.unit with(Nolock)) 
				AND		b.prodcode IS NULL
								
			INSERT INTO cdgmaster.FileUpLoadedErrorDetail
				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #unitError1			
											
			--CASE UOM is Blank in lakshya Product Master
			INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13CUOM' AS Err_Cols
						, a.Productcode 
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.Invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode  
				WHERE	a.Productcode IN(SELECT DISTINCT sapid FROM cdgmaster.sku with(Nolock) WHERE uom=0 OR uom IS NULL) 
				AND		b.prodcode is null 
				AND		c.productcode is null 
				
--			INSERT INTO cdgmaster.FileUpLoadedErrorDetail
--				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #unitError				
					
			--SALE UOM is Blank in lakshya Product Master
			INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13SUOM' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 
				WHERE	a.productcode  IN(SELECT DISTINCT sapid FROM cdgmaster.sku with(Nolock) WHERE saleuom=0 OR saleuom IS NULL) 
						AND b.prodcode IS NULL 
						AND c.productcode IS NULL 
						AND e.productcode IS NULL 

			--BASE UOM is Blank in lakshya Product Master
			INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13BUOM' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 
				WHERE	a.productcode  IN(SELECT DISTINCT sapid FROM cdgmaster.sku with(Nolock) WHERE Baseuom=0 OR Baseuom IS NULL)
				AND		b.prodcode IS NULL 
				AND		c.productcode IS NULL 
				AND		e.productcode IS NULL 
				
				-- Add by Ramesh Murugan
				-- To Check if Conversion ratio between UOM and BBUOM is available in cdgmaster.skuunitConvrsndtl table
				
				INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '45BBUOM' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 
				WHERE	a.productcode 
				not IN(select distinct SKUID from cdgmaster.skuunitConvrsndtl where SKUID=a.productcode and UnitID1=a.UOM and UnitID2=a.BBUOM)
				AND		b.prodcode IS NULL 
				AND		c.productcode IS NULL 
				AND		e.productcode IS NULL 
				AND     a.UOM <> a.BBUOM
				
				---- Billed qty * Converstion factor = BSKUQty if NOT matching
				
				INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '44BSKUQty' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 
						left join cdgmaster.skuunitConvrsndtl f on f.SKUID=a.productcode and f.UnitID1=a.UOM and f.UnitID2=a.BBUOM and a.Uom!='PC'
				----commented as per requirement need to add round functionality on 5Jul2017 poojan
				--WHERE	a.BSKUQty!=(a.Qty*ConvrcnRatio) and a.productcode=f.SKUID and a.UOM <> a.BBUOM
				--added round functionality on 5Jul2017 poojan
				WHERE	round(a.BSKUQty,0)!=round((a.Qty*ConvrcnRatio),0) and a.productcode=f.SKUID and a.UOM <> a.BBUOM
				AND		b.prodcode IS NULL 
				AND		c.productcode IS NULL 
				AND		e.productcode IS NULL 
				
				INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '44BSKUQty' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 						
				WHERE
				/*--Commented by Prashant on 04-07-2018 for RDR Point no. 13
				a.BSKUQty!=a.Qty 
				--Added round function to a.BSKUQty and a.Qty
				*/
				Round(a.BSKUQty,0)!=Round(a.Qty,0)
				--End Prashant
				AND		a.UOM='PC'
				AND		b.prodcode IS NULL 
				AND		c.productcode IS NULL 
				AND		e.productcode IS NULL 
				

			--Conversion ratio is Blank in Lakshya Product Master
			--INSERT INTO #unitError
				SELECT	DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13ConUOM' AS Err_Cols
						, a.productcode
				FROM	#PurchaseFinal AS a 
						LEFT JOIN #Error AS b ON a.invoicenumber=b.Invno AND a.productcode= b.prodcode 
						LEFT JOIN #unitError1 AS c ON a.invoicenumber=c.invno AND a.productcode=c.productcode 
						LEFT JOIN #unitError AS e ON a.invoicenumber=e.invno AND a.productcode=e.productcode 
				WHERE	a.uom not IN (SELECT UnitId1 FROM cdgmaster.SKUUnitConvrsnDtl with(Nolock) WHERE UnitId2= 'PC' AND isnull(deletionMark,'') <> 'Y'
				AND		UnitId1=a.UOM AND skuid=a.productcode) AND a.uom <> 'PC'
				AND		b.prodcode IS NULL 
				AND		c.productcode IS NULL 
				AND		e.productcode IS NULL  
		/*********************RDR PF-2014-003**********************************/

		/* Error - All the SKU's for which conversion is not found and uom doesnot match with any of the uom of SKU - raise conversion error*/
		insert into #unitError
		SELECT DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + a.Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						AS Row_Delimed
						, '13CNSKUUOM' AS Err_Cols
						, a.productcode
		from #PurchaseFinal as a 
		inner join 
		(select distinct pt.productCode,pt.UOM from #PurchaseFinal pt
			inner join cdgmaster.unit u with(Nolock) on pt.UOM= u.unitid 
			inner join cdgmaster.sku s with(Nolock) on s.sapid = pt.productCode
			where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode 
			and pt.uom not in (select unitid1 from cdgmaster.SKUUnitConvrsnDtl sc  with(Nolock) where s.sapid=sc.skuid)) as tt
		on a.productcode = tt.productCode and a.UOM=tt.UOM

		/* Error - All the SKU's for which conversion is found and uom doesnot match with any of the uom of SKU. Also conversion 
		factor of uploaded UOM with respect to baseuom of the product is not found*/
		insert into #unitError
		select DISTINCT Invoicenumber AS Invno
						, a.FileUploadedCode
						, xlRowNum as Row_Num
						, (CAST(PlantCode AS VARCHAR) + '~' + CAST(CAST(InvoiceNumber AS BIGINT) AS VARCHAR)
						+ '~' + CAST(Ordernumber AS VARCHAR) + '~~' + a.Productcode + '~' + Batchcode 
						+ '~' + BillT + '~~' + Distributorcode + '~~~~' + a.Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + Invoicedate 
						+ '~~~~~' + CAST(CAST(Qty  AS INT) AS VARCHAR) + '~~~~' + cast(Tax as varchar) + '~~' + cast(subTotal4 as varchar) + '~~~~' 
						+ Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode AS VARCHAR) + '~' + ManuName + '~'
						----commented on 29 Jun 2017
						---+ ManuLoc) 
						----added on 29Jun2017 -- GST related fields --start--------
						+ isnull(ManuLoc,'null') 
						+'~'+isnull(cast(Ship_To_Party as varchar),'null')
						+'~'+isnull(cast(PONum as varchar),'null')
						+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
						+'~'+isnull(cast(TaxableAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
						+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
						+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) 
						------end ------
						 AS Row_Delimed
						, '13CNSKUBUOM' AS Err_Cols
						, a.productcode
		from #PurchaseFinal as a 
		inner join 
		(select distinct pt.productCode,pt.UOM
			from #PurchaseFinal pt inner join cdgmaster.unit u with(Nolock) on pt.UOM= u.unitid 
			inner join cdgmaster.sku s  with(Nolock) on s.sapid = pt.productCode
			left outer join cdgmaster.SKUUnitConvrsnDtl sc with(Nolock) on s.sapid=sc.skuid 
			where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode and sc.unitid1=pt.uom 
			and sc.unitid2 !=(select unitid from cdgmaster.unit with(Nolock) where unitcode=s.baseuom)) as tt
		on a.productcode = tt.productCode and a.UOM=tt.UOM

		INSERT INTO cdgmaster.FileUpLoadedErrorDetail
				SELECT FileUploadedCode, Row_Num, Row_Delimed, Err_Cols FROM #unitError	


		-----Added MRP Error: on 29 Jun 2017 start pjn-------
		 --insert into #MRPError

		print getdate()   print convert(nvarchar(10),getdate(),108)
		print 'insert data in #MRPError'	
		
		select * into #temp_MRP
		from 
		(
		 select InvoiceNumber as Invno ,FileUploadedCode, Row_Num, Row_Delimed, Err_Cols,
		 sapid as StateCode , ProductCode , Batchcode  , DistributorCode as DistCode  from 
		(
		select distinct a.DistributorCode , st.SAPID , a.Batchcode ,  cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) as ASCIIVal, bm.BatchFrom ,
			bm.BatchTo  , a.ProductCode  , CAST(CAST(a.InvoiceNumber AS BIGINT) AS VARCHAR) as invno , a.mrp as mrpfrompurchase  , bm.mrp mrpfrombatch , a.invoicenumber  ,
			a.FileUploadedCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
				+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
				+ '~' + BillT + '~~' + a.DistributorCode + '~~~~' + Uom + '~~~~~~~~' + CAST(EANNumber AS VARCHAR) + '~~~~~' + InvoiceDate + '~~~~~' 
				+  cast(cast(Qty  as int) as varchar) + '~~~~'
				+ cast(Tax as varchar) + '~~'+ cast(subTotal4 as varchar) + '~~~~' 
				+ Mfgdate + '~' + ExpDate + '~~'
				+ isnull(cast(BSKUQty as varchar),'null') 
				+'~'+ isnull(BBUOM,'null') +'~~~~~~~~~~~~~~' + isnull(Invdate,'null') + '~' + 
				isnull(CommGrp,'null') + '~' + 
				isnull(Cast(ManuCode as varchar),'null') + '~' + isnull(ManuName,'null') + '~'
				+ isnull(ManuLoc,'null')) 
				+'~'+isnull(cast(Ship_To_Party as varchar),'null')
				+'~'+isnull(cast(PONum as varchar),'null')
				+'~'+isnull(cast(RefInvoiceNum as varchar),'null')
				+'~'+isnull(cast(TaxableAmt as varchar),'null')
				+'~'+isnull(cast(SGST_TaxAmt as varchar),'null')
				+'~'+isnull(cast(UTGST_TaxAmt as varchar),'null')
				+'~'+isnull(cast(CGST_TaxAmt as varchar),'null')
				+'~'+isnull(cast(IGST_TaxAmt as varchar),'null')
				+'~'+isnull(cast(SGST_TaxPercent as varchar),'null')
				+'~'+isnull(cast(UTGST_TaxPercent as varchar),'null')
				+'~'+isnull(cast(CGST_TaxPercent as varchar),'null')
				+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')
				as Row_Delimed,
				--'13MRP' as Err_Cols,
				-- Added by Poojan on 26th June 2017.Code added to round off the MRP values of JandJConsoleLive.dbo.BatchMaster_StateWise and #PurchaseTemp tables while comparing them
				--This was done as per the logic shared by J&J team.
			 (
			   case 
			   when  cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) between  bm.BatchFrom and bm.BatchTo  and( round(isnull(a.MRP,0),0)   <> round(isnull(bm.MRP,0),0))  then '53MRPMISMTC'
			   when bm.BatchId is null then  '53MRPMIS' --cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) not between  bm.BatchFrom and bm.BatchTo then '2MRPMis'
			   else '0'
			   end  
			) as Err_Cols 
			-- End
		from cdgmaster.#PurchaseFinal (nolock) a
		inner join  cdgmaster.Customer cust (nolock) on a.DistributorCode = cust.SAPID
		inner join cdgmaster.[State] (nolock) st on  st.StateCode  = cust.StateCode 
		left join JandJConsoleLive.dbo.BatchMaster_StateWise bm (nolock)
		on 
		(
			bm.ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS =  a.ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS 
			and 
			((bm.[State] COLLATE SQL_Latin1_General_CP1_CI_AS = st.SAPID COLLATE SQL_Latin1_General_CP1_CI_AS )
			or  --added OR condition RDR #CLICK-2019-001
			(bm.[State] COLLATE SQL_Latin1_General_CP1_CI_AS = st.Govt_StateId COLLATE SQL_Latin1_General_CP1_CI_AS)
			)
			and
			cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) between  bm.BatchFrom and bm.BatchTo  

		) where upper(ltrim(rtrim(BillT))) ='ZF2D' and subTotal2 >0 --added subTotal2>0 condition on 12Jul2017
		) as t where Err_Cols in ('53MRPMISMTC','53MRPMIS' ,'0')
		)as t1


		insert into #MRPError
		select * from #temp_MRP where Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode))) not  in 
		(
		--	select Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode))) 
		--	from (
			select Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode)))  
			as col1 from #temp_MRP  where Err_Cols = '0' --) as t1
		)
		--or bid is null  

		-- 

		--select 'hi' as t,* from #mrperror

		insert into cdgmaster.FileUpLoadedErrorDetail
			select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #MRPError

		print 'insert data in #MRPError Completed'	
------Added MRP Error: end-------



		select * into #PurchaseFinal2 from #PurchaseFinal

		update tt1 set tt1.Qty=tt1.Qty * tt.convrcnRatio, uom = tt.unitid2 from cdgmaster.PurchaseFinal as tt1 with(Nolock)
		inner join (
			select distinct pt.productCode,pt.UOM,sc.unitid1,sc.unitid2,sc.convrcnRatio
			from #PurchaseFinal2 pt inner join cdgmaster.unit u with(Nolock) on pt.UOM= u.unitid 
			inner join cdgmaster.sku s with(Nolock) on s.sapid = pt.productCode
			left outer join cdgmaster.SKUUnitConvrsnDtl sc with(Nolock) on s.sapid=sc.skuid 
			where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode and sc.unitid1=pt.uom 
			and sc.unitid2=(select unitid from cdgmaster.unit with(Nolock) where unitcode=s.baseuom)) as tt 
		on (tt1.productcode=tt.productCode and tt1.UOM=tt.UOM)
			where tt1.productcode not in(select productcode from #unitError1 
										union  
										select productcode from #unitError) and tt1.uom <>'PC'


		update cdgmaster.PurchaseFinal set uom=tt.unitid from cdgmaster.PurchaseFinal as tt1 with(Nolock)
		inner join (
					select x.productcode,x.uom,y.unitid,y.convrcnRatio from  
					(select distinct a.productcode,a.uom,d.convrcnRatio from #PurchaseFinal2 a, cdgmaster.sku b with(Nolock), cdgmaster.unit c with(Nolock), 
					 cdgmaster.SKUUnitConvrsnDtl d with(Nolock) where a.productcode = b.sapid and c.unitid=a.uom and b.uom=c.unitcode
					 and a.productcode=d.skuid and d.unitid1=a.uom and c.unitcode<>b.saleuom and c.unitcode<>b.baseuom) x, 
					(select distinct a.productcode,c.unitid,d.convrcnRatio from #PurchaseFinal2 a, cdgmaster.sku b with(Nolock),
					cdgmaster.unit c with(Nolock), cdgmaster.SKUUnitConvrsnDtl d with(Nolock) where a.productcode = b.sapid and c.unitcode=b.saleuom
					and a.productcode=d.skuid and d.unitid1=c.unitid) y 
					where x.productcode = y.productcode and x.convrcnRatio = y.convrcnRatio) as tt
		on tt1.productcode=tt.productcode and tt1.UOM=tt.UOM
		   where tt1.productcode not in(select productcode from #unitError1 
										union  
										select productcode from #unitError) and tt1.uom <>'PC'
										
		/*********************RDR PF-2014-003*********************************/
			--Update Status
			UPDATE	cdgmaster.Purchasefinal 
			SET		StatusFlag='S' 
			WHERE	FileUploadedCode=@uploadFileCode 
			AND		StatusFlag='E' AND (PLANTCODE=@PlantCode OR ISNULL(@PlantCode,'-1')='-1')
			AND		(Distributorcode NOT IN (SELECT DISTINCT DistCode FROM #DistError) OR invoicenumber NOT IN (SELECT DISTINCT invno FROM #DistError ) )
			AND		(productcode NOT IN (SELECT DISTINCT prodcode FROM #Error) OR invoicenumber NOT IN (SELECT DISTINCT invno FROM #Error ) )
			AND		(productcode NOT IN (SELECT DISTINCT productcode FROM #unitError) OR invoicenumber NOT IN (SELECT DISTINCT Invno FROM #unitError) )
			AND		(productcode NOT IN (SELECT DISTINCT productcode FROM #unitError1) OR invoicenumber NOT IN (SELECT DISTINCT Invno FROM #unitError1))
			AND		(PlantCode NOT IN (SELECT DISTINCT PlantCode FROM #PlantError) OR invoicenumber NOT IN (SELECT DISTINCT invno FROM #PlantError))
			-----added to track MRP error  on 29Jun2017 ---start
			and (productcode not in (select distinct productcode from #MRPError) or invoicenumber not in (select distinct Invno from #MRPError))
			--end--


			SELECT @FileUploaded='Y' FROM cdgmaster.purchasefinal with(Nolock) WHERE StatusFlag='E' AND FileUploadedCode=@uploadFileCode
			AND (PLANTCODE=@PlantCode OR ISNULL(@PlantCode,'-1')='-1')

			DECLARE @recFound char(1)
			SET @recFound='N'
			SELECT @recFound='Y' FROM cdgmaster.fileUploaded with(Nolock)	WHERE	fileuploadedcode=@uploadFileCode

			IF(@recFound='Y')
			BEGIN
				IF(@FileUploaded='Y')
				BEGIN
					UPDATE cdgmaster.FileUploaded SET IsError='Y' WHERE FileUploadedCode=@uploadFileCode
					
				END
				IF(@FileUploaded='N')
				BEGIN
					UPDATE cdgmaster.FileUploaded SET IsError='N' WHERE FileUploadedCode=@uploadFileCode
					
				END					
			END

			DROP TABLE #PurchaseFinal
			DROP TABLE #PurchaseFinal2
			TRUNCATE TABLE #Error
			TRUNCATE TABLE #UnitError
			TRUNCATE TABLE #UnitError1
			TRUNCATE TABLE #DistError  
			TRUNCATE TABLE #PlantError
			DROP TABLE #temp_MRP --added on 6Jul2017
			TRUNCATE TABLE #MRPError --added on 29Jun2017



			FETCH NEXT FROM PUR_FINAL_UPLOADCODE_CURSOR INTO @uploadFileCode
		END
	UPDATE CDGMASTER.RERUNLOGS SET ISPROCESSED='Y' WHERE  Jobcode='Reprocess' AND ISPROCESSED ='P' AND serno=@serno and pPlantID=@PlantCode	
	CLOSE PUR_FINAL_UPLOADCODE_CURSOR
	DEALLOCATE PUR_FINAL_UPLOADCODE_CURSOR		
	--END FILE UPLOADED CODE CURSOR	
	DROP TABLE #Error
	DROP TABLE #UnitError
	DROP TABLE #UnitError1
	DROP TABLE #DistError  
	DROP TABLE #PlantError
	--drop table #temp --added on 6Jul2017
	DROP TABLE #MRPError --added on 29Jun2017
	

	
END