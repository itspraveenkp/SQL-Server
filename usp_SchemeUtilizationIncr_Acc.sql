USE [LAKSHYA]
GO
/****** Object:  StoredProcedure [cdgmaster].[usp_SchemeUtilizationIncr_Acc]    Script Date: 11/19/2019 5:28:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [cdgmaster].[usp_SchemeUtilizationIncr_Acc]            
(            
@SchID int,
@p1 varchar(20),
@p2 varchar(20)
--@isCount bit
)            
as            
BEGIN    --{
         
          
         
/*Added by durgesh on 21 nov 2018
select schemeUtilizationIncrId,SchedulerIncrId,schemeDescription,schemeCode,CompanySchemeCode,distCode,InvoiceNo,rtrCode,SchDate,SchemeType,SchemeMode
		,schemeAmt,CreatedDate,errCd,useInSummary,AccrualSchID
		INTO #SchemeUtilizationincr_Accrual 
		from cdgmaster.SchemeUtilizationincr_Accrual with(nolock)
		where isnull(DistCode,'')<>'' and useInSummary='N'     
		and AccrualSchID = @SchID      

End*/

Select  distinct a.*,b.salGrossAmt as InvoiceAmt into #tempAccural From    
 (    
 select sui.schemeUtilizationIncrId,c.ZoneCode ,sui.SchedulerIncrId,sui.schemeCode,Isnull(isNull(sui.schemeDescription,su.schemeDescription),sh.[scheme Description]) as schemeDescription ,          
     sui.CompanySchemeCode,sui.distCode,c.customerName,sui.InvoiceNo,sui.rtrCode,rm.rtrName,          
     sui.SchDate,convert(varchar(12), sui.SchDate, 106) as SchemeDate,sui.SchemeType ,IsNUll(Sh.Claimable,case sui.SchemeMode when 'Y' then 'Yes' when 'N' then 'No' else '' end) as claimable,         
     sui.schemeAmt,case when sui.SchemeMode='Y' then 'Yes' when sui.SchemeMode='N' then 'No' end as SchemeMode,          
     sui.CreatedDate,sui.errCd,case when sui.useInSummary='N' then 'No' when sui.useInSummary='Y' then 'Yes' else '' end as useInSummary,
     sui.AccrualSchID          
    from cdgmaster.SchemeUtilizationincr_Accrual as sui  with(nolock)  --COMMENTED AND ADDED BY DURGESH ON 21 NOV 2018       
	--from #SchemeUtilizationincr_Accrual as sui  with(nolock) 
     Left Outer Join jandjconsoleLive.DBO.schemeUtilization Su with(nolock) on sui.Distcode =SU.distcode and sui.Schemecode = SU.SchemeCode and sui.InvoiceNo = SU.InvoiceNo        
     left outer join jnjHistory.DBO.JNJScheme_HeaderSlabs as sh with(nolock) on sui.CompanySchemeCode=sh.CompanySchemeCode          
     left outer join jandjconsoleLive.DBO.RetailerMaster as rm with(nolock) on  sui.distcode=rm.distcode and sui.RtrCode=rm.RtrCode           
     left outer join cdgmaster.Customer as c with(nolock) on sui.DistCode=c.sapid and isActive='Y'    
 ) as a    
 Left Outer JOIN     
 (    
  Select distinct ds.salinvno,ds.distcode,ds.salGrossAmt from jandjconsoleLive.dbo.dailySales ds with(nolock)    
   ) as b ON b.salinvno = a.InvoiceNo and b.distcode = a.distcode     
    where 1=1 and isnull(a.DistCode,'')<>'' and a.useInSummary='No'          
    and a.AccrualSchID = @SchID 
    ORDER BY a.SchemeCode asc , a.CompanySchemeCode asc              
 
	SELECT *
	FROM   (SELECT ROW_NUMBER() OVER(ORDER BY SchemeCode asc,CompanySchemeCode asc) AS 
	rownum, *  FROM #tempAccural AT) AS tempAccural
	WHERE  rownum > @p1  AND rownum <= @p2
--End  
Drop table  #tempAccural 
END    --}            
          
/*          
exec [cdgmaster].[usp_SchemeUtilizationIncr_Acc] @SchID = 1,@p1 = 10000,@p2 = 15000
exec [cdgmaster].[usp_SchemeUtilizationIncr_Acc] @SchID = 1,@p1 = 5,@p2 = 10
*/

