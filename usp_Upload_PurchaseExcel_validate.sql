USE [LAKSHYA]
GO
/****** Object:  StoredProcedure [cdgmaster].[usp_Upload_PurchaseExcel_validate]    Script Date: 9/19/2019 12:31:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- V20190503
-- select * from #Purchasetemp
-- exec [cdgmaster].[usp_Upload_PurchaseExcel_validate] 15649
ALTER PROCEDURE [cdgmaster].[usp_Upload_PurchaseExcel_validate] 
(
  @uploadFileCode int
, @ReprocessALL char(1) = 'N'
, @dbug INT=0
) 
AS
/*
   This SP will validate SAP documents 
   20121022  Shriyal Created
*/
  
Create table #Error   
(   
Invno float,    
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
prodcode varchar(50)
)  

Create table #DistError   
(   
Invno float,    
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
DistCode varchar(50)
)  

Create table #PlantError   
(   
Invno float,    
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
PlantID int
) 

Create table #UnitError   
(  
Invno float,    
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
productcode varchar(50)
--ErrorDesc varchar(1000)
)

Create table #UnitError1   
(   
Invno float,   
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
productcode varchar(50)
--ErrorDesc varchar(1000)
) 
  
Create table #TotalAmtError
(   
Invno float,
--DistSapid varchar(50),   
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200)
) 

Create table #BillTError
(   
Invno float,
FileUploadedCode varchar(200),
Row_Num varchar(100),
Row_Delimed varchar(2000),
Err_Cols varchar(200),
) 

--code change by sandeep desai on 23/10/2010 for product sequence as per sap invoice sequence 
-- code changed by kavita on 20/11/2012.

create table #BillType
(
serno int,
BillT varchar(20)
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

----  select * from cdgmaster.FileUpLoadedErrorCodes where uploadErrorcode in ('13UUOM','13CUOM','13SUOM','13BUOM')
--select * from cdgmaster.FileUpLoadedErrorDetail where Err_Cols in ('13UUOM'),'13CUOM','13SUOM','13BUOM')
-- 13- index ? 
-- 

--select *from cdgmaster.FileUpLoadedErrorCodes where uploadErrorcode in ('UUOM')
--MRPMIS
--MRPMISMTC

insert into #BillType(serno, BillT) values (1,'ZL2D')
insert into #BillType(serno, BillT) values (2,'ZF2D')
insert into #BillType(serno, BillT) values (3,'ZC2D')
insert into #BillType(serno, BillT) values (4,'ZG2D')
--Added by Prashant
Insert into #BillType(serno,BillT) values (5,'ZG22')
Insert into #BillType(serno,BillT) values (6,'ZC22')
Insert into #BillType(serno,BillT) values (7,'ZL22')
Insert into #BillType(serno,BillT) values (8,'S1')
Insert into #BillType(serno,BillT) values (9,'S2')
--End Prashant

--Delete from cdgmaster.FileUpLoadedErrorDetail where FileUploadedCode=@uploadFileCode and Err_Cols in ('13UUOM','13CUOM','13SUOM','13BUOM','13ConUOM','0TANSD','7IBT','5IID','9IID','1IID','13CNSKUUOM','13CNSKUBUOM','45BBUOM','44BSKUQty' )
Delete from cdgmaster.FileUpLoadedErrorDetail where FileUploadedCode=@uploadFileCode and Err_Cols in ('13UUOM','13CUOM','13SUOM','13BUOM','13ConUOM','0TANSD','7IBT','5IID','9IID','1IID','13CNSKUUOM','13CNSKUBUOM','45BBUOM','44BSKUQty', '53MRPMIS' ,'53MRPMISMTC')

-----Added by Poojan on 26th June 2017. This change was done as per logic shared by J&J team ------
Update P Set p.TaxType=(CASE WHEN convert(varchar(10),cast(p.InvoiceDate as date),120)>=(select convert(varchar(10),cast(ParamVal as date),120) from cdgmaster.tblSystemParam where ParamName='GSTDate') THEN 'GST' ELSE 'VAT' END)
From cdgmaster.PurchaseTemp P with (Nolock) 
left join cdgmaster.PurchaseTemp q with (Nolock) on p.InvoiceNumber=q.InvoiceNumber and P.uploadFileCode = q.uploadFileCode 
where P.uploadFileCode = @uploadFileCode
------ End------

----Start: Added to update MRP-----
update PurchaseTemp  set mrp = case when BSKUQty <> 0 then ROUND((SubTotal2 / BSKUQty),2) else 0   end where uploadFileCode = @uploadFileCode
---------------end----------------

select * into #Purchasetemp from cdgmaster.Purchasetemp where uploadFileCode = @uploadFileCode
PRINT ('Select #Purchasetemp')


insert into #BillTError
	select distinct invoicenumber as Invno,uploadFileCode as FileUploadedCode, '0' as Row_Num, ('~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~~~~~' + BillT + '~~' + DistributorCode + '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') as Row_Delimed, '7IBT' as Err_Cols 
		from #Purchasetemp 
	where BillT not in (select BillT from #BillType)
	order by InvoiceNumber

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #BillTError

--code change by sandeep desai on 23/10/2010 for product sequence as per sap invoice sequence 

---for testing i have taken intcode
Select intCode as cnt,	tmp.Plantcode,InvoiceNumber,OrderNumber,replace(convert(varchar,convert(datetime,Invoicedate),102),'.','') as invoicedate,
	Distributorcode , Totalgross, Unit1, TotalTax,Unit2,productcode, 
	Convert(decimal(35,3),Qty) as Quantity, UOM, Gross,Unit3,  Convert(decimal(35,3),Tax) as Tax, Unit4,Amt1,Unit5,Amt2,Unit6
	,Batchcode,replace(convert(varchar,convert(datetime,mfgdate),102),'.','') as Mfgdte
	,replace(convert(varchar,convert(datetime,ExpDate),102),'.','') as Expirydate,EANNumber,tr,
	StatusFlag, FlagD, TG, Invdate, BillT, OrdRs,xlRowNum,uploadFileCode
	,convert(decimal(35,3),0.000) as GrossAmount
	,convert(decimal(35,3),Totalgross+TotalTax)as TotalInvoiceamount 
	,convert(decimal(35,3),0.000) as maxTotalInvoiceamount
	,Convert(decimal(35,3),(Amt1-Amt2)) as Discount
	,convert(decimal(35,3),0.000) as TotalAmountforcheck 
	,isProcessed, isProcessedWk,isAcpt,CommGrp,ManuCode,ManuName,ManuLoc,
	(SELECT isnull(SupplierCode,'') from cdgmaster.plant p where p.PlantID=tmp.PlantCode) as SupplierCode, BSKUQty,BBUOM
	------Added GST RElated fields ---Start------
				,   Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------
	into #Purchasetemp1 from #Purchasetemp tmp
 where BillT in (select BillT from #BillType) order by Plantcode

--Select intCode as cnt,	Plantcode,InvoiceNumber,OrderNumber,replace(convert(varchar,convert(datetime,Invoicedate),102),'.','') as invoicedate,
--	Distributorcode ,convert(decimal(35,3),Totalgross+TotalTax)as TotalInvoiceamount,  
--	productcode, Convert(decimal(35,3),Qty) as Quantity, UOM, convert(decimal(35,3),0.000) as GrossAmount, Convert(decimal(35,3),Tax) as Tax, 
--	,convert(decimal(35,3),0.000) as TotalAmountforcheck,Batchcode
--	,replace(convert(varchar,convert(datetime,mfgdate),102),'.','') as Mfgdte
--	,replace(convert(varchar,convert(datetime,ExpDate),102),'.','') as Expirydate,EANNumber,tr,xlRowNum,uploadFileCode
--	into #Purchasetemp1 from #Purchasetemp order by Plantcode

update #Purchasetemp1 set GrossAmount=b.Gross+a.Discount 
  from #Purchasetemp1 as a 
inner join cdgmaster.#Purchasetemp as  b on a.cnt=b.intCode 

--*--------

-----insert into cdgmaster.FileUpLoadedErrorDetail (FileUpLoadedCode


Declare @FileUploaded varchar(10)
set @FileUploaded='N' 

update #Purchasetemp1 set TotalAmountforcheck=(
          select sum(a.Grossamount)+ sum(b.Tax)-sum(a.discount) from #Purchasetemp1 as a 
         inner join #Purchasetemp as  b on a.cnt=b.intCode where a.invoicenumber=d.invoicenumber)  
  from  #Purchasetemp1 as d 

update #Purchasetemp1 set maxTotalInvoiceamount=(
          select max(TotalInvoiceamount) from #Purchasetemp1 as a 
         inner join #Purchasetemp as  b on a.cnt=b.intCode where a.invoicenumber=d.invoicenumber)  
  from  #Purchasetemp1 as d 

-- total amount <> sum of details 

insert into #TotalAmtError
	select distinct invoicenumber as Invno,uploadFileCode as FileUploadedCode, '0' as Row_Num, ('~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~~~~~' + BillT + '~~' + DistributorCode 
		--+ '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') as Row_Delimed, '0TANSD' as Err_Cols
		-- Code changes done by Poojan on 26th June 2016 . Increased the number of tilde signs used in the string below 
		+'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') as Row_Delimed, '0TANSD' as Err_Cols
		-- end 

	from #Purchasetemp1 
	where maxTotalInvoiceamount<>TotalAmountforcheck 
	order by InvoiceNumber

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #TotalAmtError

---Productmaster checking''''
insert into #Error  
	select distinct invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar)  +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, '5IID' as Err_Cols, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null')) as Row_Delimed, '5IID' as Err_Cols,
		-----end --------------

		ltrim(rtrim(Productcode)) as prodcode
	from #Purchasetemp where BillT in (select BillT from #BillType) 
	and ltrim(rtrim(productcode)) not in( select sapid from cdgmaster.sku where isActive='Y' and isDeleted='N')
	and invoicenumber not in (select distinct Invno from #TotalAmtError)

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #Error

--	select distinct invoicenumber as invoiceno,ltrim(rtrim(Productcode)) as ErrorDescription  
--	from #Purchasetemp where BillT in (select BillT from #BillType) 
--	and ltrim(rtrim(productcode)) not in( select sapid from cdgmaster.sku where isActive='Y' and isDeleted='N')

insert into #DistError  
	select distinct invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + p.DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		---commentd on 21Jun2017
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		--Removed extra delimiter on 21Jun2017 
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, '9IID' as Err_Cols,
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed, '9IID' as Err_Cols,
		-----end --------------
		ltrim(rtrim(p.DistributorCode)) as DistCode
	from #Purchasetemp as p left join cdgmaster.customer as c  on p.DistributorCode=c.sapid and c.isActive='Y'
where c.sapid is null and BillT in (select BillT from #BillType) 
	and invoicenumber not in (select distinct Invno from #TotalAmtError)

--	and ltrim(rtrim(DistributorCode)) not in( select sapid from cdgmaster.Customer where  isActive='Y')

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #DistError

--InvalidPlantID

insert into #PlantError  
	select distinct invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(p.PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + p.DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		--commented on 21Jun2017
		-- + Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		--removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, '1IID' as Err_Cols,
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed, '1IID' as Err_Cols,
		-----end --------------

		p.PlantCode as PlantID
	from #Purchasetemp as p left join cdgmaster.plant as plnt  on p.PlantCode=plnt.PlantID and plnt.Active='Y'
where plnt.PlantID is null and BillT in (select BillT from #BillType) 
	and invoicenumber not in (select distinct Invno from #TotalAmtError)

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #PlantError

--	select distinct invoicenumber as invoiceno,ltrim(rtrim(DistributorCode)) as ErrorDescription  
--	from #Purchasetemp where BillT in (select BillT from #BillType) 
--	and ltrim(rtrim(DistributorCode)) not in( select sapid from cdgmaster.Customer where  isActive='Y')

--if not exists(select ErrorDescription from #Error)
--begin
---upload UOM maintained or not checking''''
--UOM is not found in  Product Master
insert into #unitError1
	select distinct invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----commented on 21Jun2017 
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----Removed extra delimiter
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, '13UUOM' as Err_Cols,
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed, '13UUOM' as Err_Cols,
		-----end --------------

		ltrim(rtrim(a.Productcode)) as productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	where BillT in (select BillT from #BillType) and uom not in (select distinct unitid from cdgmaster.unit) and b.prodcode is null
	and invoicenumber not in (select distinct Invno from #TotalAmtError)

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError1

--end

--if not exists(select ErrorDesc from #unitError1) and  not exists(select ErrorDescription from #Error)
---upload saleuom and case uom maintained or not checking''''
--begin
--CASE UOM is Blank in  Product Master
insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----commented on 21Jun2017
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		--Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		
		'13CUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode  
	where BillT in (select BillT from #BillType) and a.productcode  in(select distinct sapid from cdgmaster.sku where uom=0 or uom is null  ) 
	and b.prodcode is null and c.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)

--insert into cdgmaster.FileUpLoadedErrorDetail
--	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError

--SALE UOM is Blank in  Product Master
insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun2017 
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed,
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		 '13SUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
	left join #unitError as e on a.invoicenumber=e.invno and a.productcode=e.productcode 
	where BillT in (select BillT from #BillType) and a.productcode  in(select distinct sapid from cdgmaster.sku where saleuom=0 or saleuom is null  ) 
	and b.prodcode is null and c.productcode is null and e.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)

--insert into cdgmaster.FileUpLoadedErrorDetail
--	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError

--BASE UOM is Blank in  Product Master
insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun2017
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'13BUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
	left join #unitError as e on a.invoicenumber=e.invno and a.productcode=e.productcode 
	where BillT in (select BillT from #BillType) and a.productcode  in(select distinct sapid from cdgmaster.sku where Baseuom=0 or Baseuom is null )
	and b.prodcode is null and c.productcode is null and e.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)
	
	-- Add by Ramesh Murugan
	-- To Check if Conversion ratio between UOM and BBUOM is available in cdgmaster.skuunitConvrsndtl table
	
	--select * into Purchasetemp from #Purchasetemp
	--select * into error from #error
	--select * into unitError1 from #unitError1
	--select * into unitError from #unitError
	--select * into BillType from #BillType
	--select * into TotalAmtError from #TotalAmtError

	
	insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM + '~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----commented on 21Jun2017
		-- + ManuLoc) as Row_Delimed,
		 ----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'45BBUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
	left join #unitError as e on a.invoicenumber=e.invno and a.productcode=e.productcode 
	where BillT in (select BillT from #BillType) 
	and a.productcode not in(select distinct SKUID from cdgmaster.skuunitConvrsndtl where SKUID=a.productcode and UnitID1=a.UOM and UnitID2=a.BBUOM)
	and b.prodcode is null and c.productcode is null and e.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)
	and a.UOM <> a.BBUOM
	
	--select * from #UnitError order by 1 desc
	-- Billed qty * Converstion factor = BSKUQty if NOT matching
	
	insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun217
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed,
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'44BSKUQty' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 	
	left join cdgmaster.skuunitConvrsndtl f on f.SKUID=a.productcode and f.UnitID1=a.UOM and f.UnitID2=a.BBUOM 
	where BillT in (select BillT from #BillType) and a.UOM!='PC' and a.UOM <> a.BBUOM	 
	----commented as per requirement need to add round functionality on 20Jun2017 poojan
	--and a.BSKUQty!=(a.Qty*ConvrcnRatio) and a.productcode=f.SKUID
	--added round functionality on 20Jun2017 poojan
	and round( a.BSKUQty ,0)!=Round((a.Qty*ConvrcnRatio),0) and a.productcode=f.SKUID
	and b.prodcode is null and c.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)
		
	insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun2017 
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		---- removed extra delimiter on21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'44BSKUQty' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
		
	where BillT in (select BillT from #BillType) and a.UOM='PC' 	 
	/*Commented by durgesh on 03 May2018 RDR 2018 001
	and a.BSKUQty!=a.Qty 
	*/
	/*Added by durgesh on 03may2018*/
	and ROUND(a.BSKUQty,0)!=ROUND(a.Qty,0) 
	/*End*/
	and b.prodcode is null and c.productcode is null and invoicenumber not in (select distinct Invno from #TotalAmtError)

--insert into cdgmaster.FileUpLoadedErrorDetail
--	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError

--Conversion ratio is Blank in  Product Master
insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun2017
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		----Removed extra delimiter on21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------

		 '13ConUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a left join #Error as b on a.invoicenumber=b.Invno and a.productcode= b.prodcode 
	left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
	left join #unitError as e on a.invoicenumber=e.invno and a.productcode=e.productcode 
	where  BillT in (select BillT from #BillType) and
	a.uom not in (select UnitId1 from cdgmaster.SKUUnitConvrsnDtl where UnitId2= 'PC' and isnull(deletionMark,'') <> 'Y'
							and UnitId1=a.UOM and skuid=a.productcode) and a.uom <> 'PC'
	and b.prodcode is null and c.productcode is null and e.productcode is null  and invoicenumber not in (select distinct Invno from #TotalAmtError)

--insert into cdgmaster.FileUpLoadedErrorDetail
--	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError

--	select distinct invoicenumber as Invno ,a.productcode, '13IUOM' 
--	from #Purchasetemp as a  left join cdgmaster.SKUUnitConvrsnDtl as e on a.productcode=e.skuid   
--	where a.productcode not  in(select distinct sapid from cdgmaster.sku where (uom=0 or uom is null) 
--	and (saleuom=0 or saleuom is null) and (Baseuom=0 or Baseuom is null)) and a.productcode in (select distinct sapid from cdgmaster.sku)
--	and a.productcode not in (select skuid from cdgmaster.SKUUnitConvrsnDtl) and  convrcnratio=0

--end


/*********************RDR PF-2014-003***************************************

update #Purchasetemp1 set uom=tt.unitid from #Purchasetemp1  as tt1 
	inner join (select distinct a.skuid ,d.unitid from
					(select * from cdgmaster.SKUUnitConvrsnDtl where 
							skuid in (select skuid from cdgmaster.SKUUnitConvrsnDtl  group by skuid having count(*)>1 ) ) as a 
	inner join (select * from cdgmaster.SKUUnitConvrsnDtl where 
					skuid in (select skuid from cdgmaster.SKUUnitConvrsnDtl group by skuid having count(*)>1 )) as b 
	on a.skuid=b.skuid and a.convrcnratio=b.convrcnratio  
	inner join cdgmaster.SKU as c on a.skuid=c.sapid and b.skuid=c.sapid 
	inner join cdgmaster.unit as d on  c.saleuom=d.unitcode where a.unitid1<>b.unitid1) as tt on tt1.productcode=tt.skuid   
	where tt1.productcode not in(select productcode from #unitError1 
								union all 
								select productcode from #unitError) and tt1.uom <>'PC'
								
****old*******************************************************************/

/* Error - All the SKU's for which conversion is not found and uom doesnot match with any of the uom of SKU - raise conversion error*/

insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + a.Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		----Commented on 21Jun2017
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		---- Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'13CNSKUUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a 
    inner join 
	(select distinct pt.productCode,pt.UOM from #Purchasetemp pt
		inner join cdgmaster.unit u on pt.UOM= u.unitid 
		inner join cdgmaster.sku s on s.sapid = pt.productCode
		where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode 
		and pt.uom not in (select unitid1 from cdgmaster.SKUUnitConvrsnDtl sc where s.sapid=sc.skuid)) as tt
	on a.productcode = tt.productCode and a.UOM=tt.UOM


/* Error - All the SKU's for which conversion is found and uom doesnot match with any of the uom of SKU. Also conversion 
factor of uploaded UOM with respect to baseuom of the product is not found*/
insert into #unitError
	select distinct a.invoicenumber as Invno, uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + DistributorCode + '~~~~' + a.Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(a.Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		-----Commented on 21Jun2017 
		--+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'
		---Removed extra delimiter on 21Jun2017
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'+ cast(BSKUQty as varchar) +'~'+ BBUOM +'~~~~~~~~~~~~~~' + Invdate + '~' + CommGrp + '~' + Cast(ManuCode as varchar) + '~' + ManuName + '~'

		----commented on 21Jun2017
		--+ ManuLoc) as Row_Delimed, 
		----added on 21Jun2017 -- GST related fields --start--------
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
		+'~'+isnull(cast(IGST_TaxPercent as varchar),'null'))  as Row_Delimed,
		-----end --------------
		'13CNSKUBUOM' as Err_Cols, a.productcode
	from #Purchasetemp as a 
    inner join 
	(select distinct pt.productCode,pt.UOM
		from #Purchasetemp pt inner join cdgmaster.unit u on pt.UOM= u.unitid 
		inner join cdgmaster.sku s on s.sapid = pt.productCode
		left outer join cdgmaster.SKUUnitConvrsnDtl sc on s.sapid=sc.skuid 
		where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode and sc.unitid1=pt.uom 
		and sc.unitid2 !=(select unitid from cdgmaster.unit where unitcode=s.baseuom)) as tt
	on a.productcode = tt.productCode and a.UOM=tt.UOM


insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #unitError

select * into #Purchasetemp2 from #Purchasetemp1

/*All the SKU's for which conversion is found and uom doesnot match with any of the uom of SKU find the conversion 
factor of uploaded UOM with respect to baseuom of the product and multiply the uploaded quantity with it*/
update tt1 set tt1.quantity=tt1.quantity * tt.convrcnRatio, uom = tt.unitid2 from #Purchasetemp1 as tt1
inner join (
	select distinct pt.productCode,pt.UOM,sc.unitid1,sc.unitid2,sc.convrcnRatio
	from #Purchasetemp2 pt inner join cdgmaster.unit u on pt.UOM= u.unitid 
	inner join cdgmaster.sku s on s.sapid = pt.productCode
	left outer join cdgmaster.SKUUnitConvrsnDtl sc on s.sapid=sc.skuid 
	where s.uom<>u.unitcode and s.baseuom <> u.unitcode and s.saleuom <> u.unitcode and sc.unitid1=pt.uom 
	and sc.unitid2=(select unitid from cdgmaster.unit where unitcode=s.baseuom)) as tt 
on (tt1.productcode=tt.productCode and tt1.UOM=tt.UOM)
	where tt1.productcode not in(select productcode from #unitError1 
								union all 
								select productcode from #unitError) and tt1.uom <>'PC'

/****************All the SKU's for which upload uom = case uom and conversion factor of case uom= saleuom*/
update #Purchasetemp1 set uom=tt.unitid from #Purchasetemp1 as tt1 
inner join (
			select x.productcode,x.uom,y.unitid,y.convrcnRatio from  
			(select distinct a.productcode,a.uom,d.convrcnRatio from #Purchasetemp2 a, cdgmaster.sku b, cdgmaster.unit c, 
			 cdgmaster.SKUUnitConvrsnDtl d where a.productcode = b.sapid and c.unitid=a.uom and b.uom=c.unitcode
			 and a.productcode=d.skuid and d.unitid1=a.uom and c.unitcode<>b.saleuom and c.unitcode<>b.baseuom) x, 
			(select distinct a.productcode,c.unitid,d.convrcnRatio from #Purchasetemp2 a, cdgmaster.sku b,
			cdgmaster.unit c, cdgmaster.SKUUnitConvrsnDtl d where a.productcode = b.sapid and c.unitcode=b.saleuom
			and a.productcode=d.skuid and d.unitid1=c.unitid) y 
			where x.productcode = y.productcode and x.convrcnRatio = y.convrcnRatio) as tt
on tt1.productcode=tt.productcode and tt1.UOM=tt.UOM
   where tt1.productcode not in(select productcode from #unitError1 
								union all 
								select productcode from #unitError) and tt1.uom <>'PC'

/*********************RDR PF-2014-003*********************************/


------Added MRP Error: start pjn-------
 --insert into #MRPError

select * into #temp 
from 
(
 select InvoiceNumber as Invno ,FileUploadedCode, Row_Num, Row_Delimed, Err_Cols,
 sapid as StateCode , ProductCode , Batchcode  , DistributorCode as DistCode  from 
(
select distinct a.DistributorCode , st.SAPID , a.Batchcode ,  cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) as ASCIIVal, bm.BatchFrom ,
	bm.BatchTo  , a.ProductCode  , a.intcode , a.mrp as mrpfrompurchase  , bm.mrp mrpfrombatch , a.invoicenumber  ,
	uploadFileCode as FileUploadedCode, xlRowNum as Row_Num, (cast(PlantCode as varchar) + '~' + cast(cast(InvoiceNumber as bigint) as varchar)
		+ '~' + cast(OrderNumber as varchar) + '~~' + a.ProductCode + '~' + Batchcode 
		+ '~' + BillT + '~~' + a.DistributorCode + '~~~~' + Uom + '~~~~~~~~' + EANNumber + '~~~~' + TR + '~' + InvoiceDate + '~' 
		+ cast(TotalGross as varchar) + '~' + Unit1 + '~' + cast(TotalTax as varchar) + '~' + Unit2 
		+ '~' + cast(cast(Qty  as int) as varchar) + '~~' + cast(Gross as varchar)+ '~' + Unit3 + '~' +
		cast(Tax as varchar) + '~' + Unit4 + '~' + cast(Amt1 as varchar) + '~' + Unit5 + '~' + cast(Amt2 as varchar) + '~'
		+ Unit6 + '~' + Mfgdate + '~' + ExpDate + '~~'
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
from cdgmaster.#PurchaseTemp (nolock) a
inner join  cdgmaster.Customer cust (nolock) on a.DistributorCode = cust.SAPID
inner join cdgmaster.[State] (nolock) st on  st.StateCode  = cust.StateCode 
left join JandJConsoleLive.dbo.BatchMaster_StateWise bm (nolock)
on 
(
	bm.ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS =  a.ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS 
	and 
	((bm.[State] COLLATE SQL_Latin1_General_CP1_CI_AS = st.SAPID COLLATE SQL_Latin1_General_CP1_CI_AS) 
	or  --added OR condition RDR #CLICK-2019-001
	(bm.[State] COLLATE SQL_Latin1_General_CP1_CI_AS = st.Govt_StateId COLLATE SQL_Latin1_General_CP1_CI_AS)
	)
	and
	cdgmaster.GetASCIIValueForString(isnull(a.Batchcode,0)) between  bm.BatchFrom and bm.BatchTo  

) where upper(ltrim(rtrim(BillT))) ='ZF2D' and subTotal2 >0 --added subTotal2>0 condition on 17Jul2017
) as t where Err_Cols in ('53MRPMISMTC','53MRPMIS' ,'0')
)as t1


--- Amit 

insert into #MRPError
select * from #temp where Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode))) not  in 
(
--	select Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode))) 
--	from (
	select Convert(varchar(100),rtrim(ltrim(StateCode)))+Convert(varchar(100) , rtrim(ltrim(Invno)))+Convert(varchar(100),rtrim(ltrim(ProductCode)))  
	as col1 from #temp  where Err_Cols = '0' --) as t1
)
--or bid is null  
-- 
--select 'hi' as t,* from #mrperror

insert into cdgmaster.FileUpLoadedErrorDetail
	select FileUploadedCode, Row_Num, Row_Delimed, Err_Cols from #MRPError

------Added MRP Error: end-------

--End
--

--------- if no error -----------
--Delete from cdgmaster.Purchasefinal where invoicenumber in (select invoicenumber from #Purchasetemp1)

--Delete from cdgmaster.Purchasefinal where invoicenumber in (select invoicenumber from #Purchasetemp1)
--  and not (isAcpt = 'Y' or isProcessed ='Y' or isProcessedWk='Y')


-- added for debugging purpose --
--Select 'hi2' , invoicenumber  , ProductCode from #Purchasetemp1 where invoicenumber in (select invoicenumber from cdgmaster.Purchasefinal) 
--

Delete from #Purchasetemp1 where invoicenumber in (select invoicenumber from cdgmaster.Purchasefinal) --and productcode in (select productcode from cdgmaster.Purchasefinal))

insert into cdgmaster.Purchasefinal 
		( Intcnt, PlantCode, Invoicenumber, Ordernumber, Invoicedate, Distributorcode, TotalInvoiceamount, 
			Productcode, Qty, Uom, Grossamount, Tax, 
			Discount, Totalamountcheck, Batchcode, Mfgdate, ExpDate, EANNumber, 
			StatusFlag, FlagD, TG, Invdate, 
			subTotal4, FileUploadedCode, BillT, OrdRs, isProcessed, isProcessedWk, isAcpt, 
			yrAcpt, mmAcpt, AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc,SupplierCode,BSKUQty,BBUOM
			------Added GST RElated fields ---Start------
				,[Ship_To_Party],
				[PONum],
				[RefInvoiceNum],
				[TaxableAmt],
				[SGST_TaxAmt] ,
				[UTGST_TaxAmt],
				[CGST_TaxAmt] ,
				[IGST_TaxAmt],
				[SGST_TaxPercent] ,
				[UTGST_TaxPercent] ,
				[CGST_TaxPercent] ,
				[IGST_TaxPercent],
				[SubTotal2] ,
				[TaxType],
				[MRP]			
			-----end------
			)
	select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
		a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
		Discount,TotalAmountforcheck as TotalAmountcheck,
		
		-- Start.Changes made by Poojan. BatchCode was replaced by a.BatchCode bceuase this column was being shown as amboguous column due to the new join with #mrperror
		--Batchcode,
		a.Batchcode,
		--else--

		Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
		'S' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate
		, Amt1 as subTotal4, uploadFileCode as FileUploadedCode, BillT, OrdRs,isProcessed, isProcessedWk,isAcpt
		, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc,SupplierCode,BSKUQty,BBUOM
		------Added GST RElated fields ---Start------
				,Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------
		from #Purchasetemp1 as a 
		left join #Error as b on a.invoicenumber=b.invno and a.productcode= b.prodcode 
		left join #DistError as de on a.invoicenumber=de.invno and a.DistributorCode= de.DistCode 
		left join #PlantError as pe on a.invoicenumber=pe.invno and a.PlantCode= pe.PlantID 
		left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
		left join #unitError as d on a.invoicenumber=d.invno and a.productcode=d.productcode 
		------Start Added by Poojan on 16th June 2017 . GST related changes-------
		left join #MRPError as mrp on a.invoicenumber=mrp.invno and a.productcode = mrp.productcode 
		--end--

		where maxTotalInvoiceamount=TotalAmountforcheck and  b.prodcode is null and c.productcode is null and d.productcode is null and de.DistCode is null and pe.PlantId is null
		and (a.productcode not in (select distinct prodcode from #Error) or invoicenumber not in (select distinct invno from #Error ) )
		and (Distributorcode not in (select distinct DistCode from #DistError) or invoicenumber not in (select distinct invno from #DistError ) )
		and (Plantcode not in (select distinct PlantID from #PlantError) or invoicenumber not in (select distinct invno from #PlantError ) )
		and (a.productcode not in (select distinct productcode from #unitError) or invoicenumber not in (select distinct Invno from #unitError) )
		and (a.productcode not in (select distinct productcode from #unitError1) or invoicenumber not in (select distinct Invno from #unitError1))
		------Start Added by Poojan on 16th June 2017 . GST related changes-------
		and (a.productcode not in (select distinct productcode from #MRPError) or invoicenumber not in (select distinct Invno from #MRPError))
		--end--
		
		order by Intcnt 

--
--================================Added by PRashant
--		select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
--		a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
--		Discount,TotalAmountforcheck as TotalAmountcheck,
		
--		-- Start.Changes made by Poojan. BatchCode was replaced by a.BatchCode bceuase this column was being shown as amboguous column due to the new join with #mrperror
--		--Batchcode,
--		a.Batchcode,
--		--else--

--		Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
--		'S' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate
--		, Amt1 as subTotal4, uploadFileCode as FileUploadedCode, BillT, OrdRs,isProcessed, isProcessedWk,isAcpt
--		, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc,SupplierCode,BSKUQty,BBUOM
--		------Added GST RElated fields ---Start------
--				,Ship_To_Party,
--				PONum,
--				RefInvoiceNum,
--				TaxableAmt,
--				SGST_TaxAmt ,
--				UTGST_TaxAmt,
--				CGST_TaxAmt ,
--				IGST_TaxAmt,
--				SGST_TaxPercent ,
--				UTGST_TaxPercent ,
--				CGST_TaxPercent ,
--				IGST_TaxPercent,
--				SubTotal2,
--				TaxType,
--				MRP 		
--			-----end------
--		from #Purchasetemp1 as a 
--		left join #Error as b on a.invoicenumber=b.invno and a.productcode= b.prodcode 
--		left join #DistError as de on a.invoicenumber=de.invno and a.DistributorCode= de.DistCode 
--		left join #PlantError as pe on a.invoicenumber=pe.invno and a.PlantCode= pe.PlantID 
--		left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
--		left join #unitError as d on a.invoicenumber=d.invno and a.productcode=d.productcode 
--		------Start Added by Poojan on 16th June 2017 . GST related changes-------
--		left join #MRPError as mrp on a.invoicenumber=mrp.invno and a.productcode = mrp.productcode order by Intcnt
--		--end--
----=================================================

--	if  not exists(select invoicenumber,productcode, intCnt, distributorCode from purchasefinal where statusflag='E' and fileuploadedCode=@uploadFileCode group by invoicenumber,productcode,intcnt,distributorCode)
--	Begin

	insert into cdgmaster.purchasefinal 
		( Intcnt, PlantCode, Invoicenumber, Ordernumber, Invoicedate, Distributorcode, TotalInvoiceamount, 
			Productcode, Qty, Uom, Grossamount, Tax, 
			Discount, Totalamountcheck, Batchcode, Mfgdate, ExpDate, EANNumber, 
			StatusFlag, FlagD, TG, Invdate, 
			subTotal4, FileUploadedCode, BillT, OrdRs, isProcessed, isProcessedWk, isAcpt, 
			yrAcpt, mmAcpt, AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc, SupplierCode,BSKUQty,BBUOM
			------Added GST RElated fields ---Start------
				,Ship_To_Party,
				[PONum],
				[RefInvoiceNum],
				[TaxableAmt],
				[SGST_TaxAmt] ,
				[UTGST_TaxAmt],
				[CGST_TaxAmt] ,
				[IGST_TaxAmt],
				[SGST_TaxPercent] ,
				[UTGST_TaxPercent] ,
				[CGST_TaxPercent] ,
				[IGST_TaxPercent],
				[SubTotal2] ,
				[TaxType],
				[MRP]			
			-----end------
			)
	   select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
			a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
			Discount,TotalAmountforcheck as TotalAmountcheck,Batchcode,Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
			'E' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate  
			, Amt1 as subTotal4,uploadFileCode as FileUploadedCode, BillT, OrdRs , isProcessed, isProcessedWk,isAcpt
			, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc, SupplierCode,BSKUQty,BBUOM

			------Added GST RElated fields ---Start------
				,Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------


			from #Purchasetemp1 as a 
			left join #DistError as de on a.invoicenumber=de.invno and a.Distributorcode= de.DistCode 
			where maxTotalInvoiceamount=TotalAmountforcheck   and (de.DistCode is not null)
			and (Distributorcode in (select distinct Distcode from #DistError ) and invoicenumber in (select distinct invno from #DistError ))
		union
	----	insert into cdgmaster.purchasefinal
			select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
			a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
			Discount,TotalAmountforcheck as TotalAmountcheck,Batchcode,Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
			'E' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate
			, Amt1 as subTotal4,uploadFileCode as FileUploadedCode, BillT, OrdRs , isProcessed, isProcessedWk,isAcpt
			, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc, SupplierCode,BSKUQty,BBUOM
			------Added GST RElated fields ---Start------
				,   Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------
			from #Purchasetemp1 as a 
			left join #DistError as de on a.invoicenumber=de.invno and a.Distributorcode= de.DistCode 
			left join #Error as b on a.invoicenumber=b.invno and a.productcode= b.prodcode 
			left join #unitError as d on a.invoicenumber=d.invno and a.productcode=d.productcode  
			left join #unitError1 as c on a.invoicenumber=c.invno and a.productcode=c.productcode 
			where maxTotalInvoiceamount=TotalAmountforcheck  and (b.prodcode is not null ) and (de.DistCode is null) and c.productcode is null and d.productcode is null
			and (Distributorcode not in (select distinct Distcode from #DistError ) and invoicenumber not in (select distinct invno from #DistError ))
			and (a.productcode in (select distinct prodcode from #Error) and invoicenumber in (select distinct invno from #Error ) )
			or  (a.productcode in (select distinct productcode from #unitError) and invoicenumber in (select distinct Invno from #unitError) )
			or (a.productcode in (select distinct productcode from #unitError1) and invoicenumber in (select distinct Invno from #unitError1))
		union
			select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
			a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
			Discount,TotalAmountforcheck as TotalAmountcheck,Batchcode,Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
			'E' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate  
			, Amt1 as subTotal4,uploadFileCode as FileUploadedCode, BillT, OrdRs , isProcessed, isProcessedWk,isAcpt
			, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc, SupplierCode,BSKUQty,BBUOM
			------Added GST RElated fields ---Start------
				,   Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------
			from #Purchasetemp1 as a 
			left join #PlantError as pe on a.invoicenumber=pe.invno and a.Plantcode= pe.PlantID 
			where maxTotalInvoiceamount=TotalAmountforcheck   and (pe.PlantID is not null)
			and (Plantcode in (select distinct PlantID from #PlantError ) and invoicenumber in (select distinct invno from #PlantError ))
			
			-- Start.Added by Poojan on 16th June 2017.GSt changes --
			union
			select cnt as Intcnt ,Plantcode,InvoiceNumber,OrderNumber,InvoiceDate,Distributorcode, TotalInvoiceamount,  
			a.productcode, Quantity as Qty,UOM, GrossAmount, Tax, 
			Discount,TotalAmountforcheck as TotalAmountcheck,a.Batchcode,Mfgdte as Mfgdate,Expirydate as ExpDate,EANNumber,
			'E' as StatusFlag,case when BillT='ZF2D' then  'ND' else 'D' end as FlagD,tr as TG, Invdate  
			, Amt1 as subTotal4,uploadFileCode as FileUploadedCode, BillT, OrdRs , isProcessed, isProcessedWk,isAcpt
			, null as yrAcpt, null as mmAcpt, null as AcceptedBy, CommGrp, ManuCode, ManuName, ManuLoc, SupplierCode,BSKUQty,BBUOM
			------Added GST RElated fields ---Start------
				,   Ship_To_Party,
				PONum,
				RefInvoiceNum,
				TaxableAmt,
				SGST_TaxAmt ,
				UTGST_TaxAmt,
				CGST_TaxAmt ,
				IGST_TaxAmt,
				SGST_TaxPercent ,
				UTGST_TaxPercent ,
				CGST_TaxPercent ,
				IGST_TaxPercent,
				SubTotal2,
				TaxType,
				MRP 		
			-----end------
			from #Purchasetemp1 as a 
			left join #MRPError  as mr on a.invoicenumber=mr.invno and a.ProductCode= mr.ProductCode 
			where maxTotalInvoiceamount=TotalAmountforcheck   and (a.productcode in (select distinct productcode from #MRPError) and invoicenumber in (select distinct Invno from #MRPError))


			--end --
	--	
--	end

	update cdgmaster.Purchasefinal set StatusFlag='S' where FileUploadedCode=@uploadFileCode and StatusFlag='E'
	and (Distributorcode not in (select distinct DistCode from #DistError) or invoicenumber not in (select distinct invno from #DistError ) )
	and (Plantcode not in (select distinct PlantID from #PlantError) or invoicenumber not in (select distinct invno from #PlantError ) )
	and (productcode not in (select distinct prodcode from #Error) or invoicenumber not in (select distinct invno from #Error ) )
	and (productcode not in (select distinct productcode from #unitError) or invoicenumber not in (select distinct Invno from #unitError) )
	and (productcode not in (select distinct productcode from #unitError1) or invoicenumber not in (select distinct Invno from #unitError1))
	-- Start.Added by Poojan on 16th June 2017.GSt changes --
	and (productcode not in (select distinct productcode from #MRPError) or invoicenumber not in (select distinct Invno from #MRPError))
	--end--


	select @FileUploaded='Y' from cdgmaster.FileUploaded where FileUploadedCode=@uploadFileCode and IsError='Y'

	select @FileUploaded='Y' from #Purchasetemp1 where maxTotalInvoiceamount<>TotalAmountforcheck 
	select @FileUploaded='Y' from #Purchasetemp where BillT not in (select BillT from #BillType)
	select @FileUploaded='Y' from cdgmaster.purchasefinal where StatusFlag='E' and FileUploadedCode=@uploadFileCode

	if(@FileUploaded='Y')
	Begin
		update cdgmaster.FileUploaded set IsError='Y' where FileUploadedCode=@uploadFileCode
	End
	if(@FileUploaded='N')
	Begin
		update cdgmaster.FileUploaded set IsError='N' where FileUploadedCode=@uploadFileCode
	End

--------------- SUCCESS ----------

------select Plantcode,InvoiceNumber,OrderNumber,Invdate,Distributorcode, TotalInvoiceamount,  
------productcode as Prdcode, Quantity,UOM, GrossAmount, Tax, 
------Discount,TotalAmountforcheck ,Batchcode, Mfgdte, Expirydate,uploadFileCode, BillT, OrdRs
------from #Purchasetemp1 
------where Totalinvoiceamount=TotalAmountforcheck 
------and invoicenumber not in (select distinct invoicenumber from cdgmaster.purchasefinal where statusflag <> 's')
--------and (invoicenumber not in (select distinct ErrorValue from #Error ) or invoicenumber not in (select distinct invno from #unitError )or 
--------invoicenumber not in (select distinct invno from #unitError1 ))
------ order by InvoiceNumber,cnt
if (@ReprocessALL='N')
BEGIN
	select * from cdgmaster.fileuploaded where fileUploadedCode=@uploadFileCode and isError='Y'
	select * from cdgmaster.purchasefinal  where fileuploadedCode=@uploadFileCode order by intcnt asc
	---select * from cdgmaster.purchasefinal  where fileuploadedCode=@uploadFileCode and distributorcode='123109' order by intcnt asc

	--------------- ERROR REPORTING ----------
--IF( @dbug > 0)
--BEGIN
	select Invno as Invoicenumber,DistCode as DistributorCode, Err_Cols from #DistError
	select Invno as Invoicenumber,PlantID as PlantCode, Err_Cols from #PlantError

	select Invno as Invoicenumber,prodcode as Productcode, Err_Cols from #Error
	union all
	select INVNO as Invoicenumber,Productcode as Productcode,Err_Cols from #UnitError 
	union all 
	select INVNO as Invoicenumber,Productcode as Productcode,Err_Cols from #UnitError1 

	select INVNO as InvoiceNumber,Err_Cols from #TotalAmtError
	union all
	select invno as InvoiceNumber,Err_Cols from #BillTError

	select invno,Productcode as Productcode,Err_Cols from #MRPError

--END 

END
--select * from cdgmaster.FileUpLoadedErrorDetail where fileuploadedCode=@uploadFileCode

--END

--drop table tempdbo..##Error 
--delete from Purchasetemp   
drop table #PurchaseTemp
drop table #PurchaseTemp1
drop table #Error
drop table #UnitError
drop table #UnitError1
drop table #BillType
drop table #DistError   
drop table #PurchaseTemp2
drop table #PlantError
drop table #TotalAmtError
drop table #BillTError

drop table #MRPError
/*
select * from cdgmaster.fileuploaded where fileuploadedCode ='3571'
select * from cdgmaster.Purchasetemp order by intcode desc--where uploadFilecode='3571'
select * from cdgmaster.Purchasetemp where uploadFilecode='5219'
select * from cdgmaster.purchasefinal  where fileuploadedCode in (4287)
select * from cdgmaster.FileUpLoadedErrorDetail where fileuploadedCode='5219'
order by 1
select * from cdgmaster.fILEuploadedErrorCodes
exec [cdgmaster].[usp_Upload_PurchaseExcel_validate] 5588,'Y',0
--truncate table cdgmaster.purchasefinal
--truncate table cdgmaster.purchasetemp 
*/


