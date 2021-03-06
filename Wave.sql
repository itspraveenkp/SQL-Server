USE [LAKSHYA]
GO
/****** Object:  StoredProcedure [cdgmaster].[usp_WaveDataCheckUI]    Script Date: 11/21/2019 5:46:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--V20171117
ALTER PROCEDURE [cdgmaster].[usp_WaveDataCheckUI]
/*
exec cdgmaster.[usp_WaveDataCheckUI] 
select * from cdgmaster.WaveDataCheckUI order by 7
QUERYC: QUERIES FROM CONSOLE
QUERYPF: QUERIES FROM PATHFINDER*/
AS
BEGIN

	--DECLARE @toDt varchar(20)
	DECLARE @mon int, @yr int   
	DECLARE @curMMYr varchar(50)  
	DECLARE @frDate dateTime    
	, @toDate dateTime    
	, @FrmCMEDt dateTime
	,@toDateBC datetime

	set @curMMYr=''  
	select @curMMYr= paramVal from cdgmaster.tblSystemParam where paramName = 'PFCurrYear'  
	if @curMMYr=''  
	begin --{    
	set xact_abort off  
	insert into cdgmaster.tblVMRjobLog (jobCode, logMsg) values ('PF_CME', 'FATAL error: PFCurrYear not in tblSystemParam')   
	print 'PFCurrYear not found in tblSystemParam. Terminating'    
	return ----------    
	end  --}  

	declare @dashIndx int  
	select @dashIndx = charIndex('-', @curMMYr)  
	select @mon= convert(int, substring(@curMMYr,1, @dashIndx-1)), @yr = convert(int, substring(@curMMYr,@dashIndx+1,4))  

	truncate table cdgmaster.WaveDataCheckUI	
	--select @toDt=convert( varchar(10), cast(ParamVal as datetime), 120) from cdgmaster.tblsystemparam where ParamName='PFSecFetch'
	select @toDate=convert( varchar(10), cast(ParamVal as datetime), 120) from cdgmaster.tblsystemparam where ParamName='PFSecFetch'
	SELECT @frDate= convert(varchar(10),Min(salINvDate),120) FROM cdgmaster.busINessCalENDer WHERE monthKey= @mon AND [Year]=@yr
	select @FrmCMEDt=convert(varchar(10),DATEADD(day,1,Cast(ParamVal as datetime)),120) from cdgmaster.tblsystemparam where ParamName='PFMonthEndDate'
	select @toDateBC=convert(varchar(10),Max(salINvDate),120) FROM cdgmaster.BusinessCalender WHERE monthKey= @mon AND [Year]=@yr

	delete from cdgmaster.tblPF_secSalesM where mon= @mon and yr= @yr and SRC<>'SNS' and distCode in (    
    select sapid from cdgmaster.customer with(nolock) where isnull(PsnonPs, 'N')= 'N' and isnull(SuperStockist,'N')='N') 
 
    exec [cdgmaster].[usp_PF_SecSalesLateDelete] @mon, @yr    
	/***************************************************QUERY 1*****************************************************************/
	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS ,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist'  ELSE'Wave' END AS PSNONPS,'Query1C' from 
		(
			select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.mon,b.mon) as Month,ISNULL(a.yr,b.yr) as Year,a.PrdgrossAmt,a.PrdQty 
			from 
			(select distcode ,@mon as mon,@yr as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty  
			from jandjconsolelive.dbo.dailysales with(nolock) where 1=1 and convert(varchar(10),salinvdate,120) between convert(varchar(10),@frDate,120) and convert(varchar(10),@toDateBC,120)
			and convert(varchar(10),CreatedDate,120) <=@toDate --addeds
			--and month(salinvdate)=@mon and year(salinvdate)=@yr 
			group by distcode)a  
			
			full outer join 

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock)  
			where 1=1  and mon=@mon and yr=@yr and src='DS' and runmm=@mon and runyr=@yr 
			group by distcode,yr,mon )b 
			 
			on a.DistCode collate database_Default=b.DistCode collate database_Default
			and a.mon=b.mon and a.yr=b.yr  
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID collate database_Default=c.distCode collate database_Default
	)
	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(	
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query1PF' from 
		(
			select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.mon) as Month,ISNULL(b.yr,a.yr) as Year,b.PrdgrossAmt,b.PrdQty 
			from 
			(select distcode ,@mon as mon,@yr as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty  
			from jandjconsolelive.dbo.dailysales with(nolock) where 1=1 and convert(varchar(10),salinvdate,120) between convert(varchar(10),@frDate,120) and convert(varchar(10),@toDateBC,120) 
			and convert(varchar(10),CreatedDate,120) <=@toDate --addeds
			--and month(salinvdate)=@mon and year(salinvdate)=@yr 
			group by distcode)a 
			
			full outer join 

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock)  
			where 1=1  and mon=@mon and yr=@yr and src='DS' and runmm=@mon and runyr=@yr 
			group by distcode,yr,mon )b 
			on a.DistCode collate database_Default=b.DistCode collate database_Default
			and a.mon=b.mon and a.yr=b.yr where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)

	/***************************************************QUERY 2*****************************************************************/

	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query2C' from 
		(
			select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.mon,b.mon) as Month,ISNULL(a.yr,b.yr) as Year,a.PrdgrossAmt,a.PrdQty 
			from 
			
			(select distcode ,@mon as mon,@yr as yr,sum(prdgrossamt) as PrdGrossAmt,
			----Commented by adnya on 17N02017
			--sum(prdsalqty) as PrdQty 
			--added on 17Nov2017 as per requirement -- PRdsalQty + PrdUnSalQty
			sum(isnull(prdsalqty,0)+isnull(prdUnsalqty,0)) as PrdQty 
			from jandjconsolelive.dbo.salesreturn with(nolock)
			where 1=1 and convert(varchar(10),srndate,120) between convert(varchar(10),@frDate,120) and convert(varchar(10),@toDateBC,120)
			and convert(varchar(10),CreatedDate,120) <=@toDate --addeds
			--and month(srndate)=@mon and year(srndate)=@yr --commented
			group by distcode)a 
			
			full outer join

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and mon=@mon and yr=@yr and src='SR' and runmm=@mon and runyr=@yr
			group by distcode,yr,mon )b 

			on a.DistCode=b.DistCode and a.mon=b.mon and a.yr=b.yr 
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(-b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(-b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)
	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(		
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query2PF' from 
		(
			select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.mon) as Month,ISNULL(b.yr,a.yr) as Year,b.PrdgrossAmt,b.PrdQty from 
			
			(select distcode ,@mon as mon,@yr as yr,sum(prdgrossamt) as PrdGrossAmt,
			--commented on 17Nov2017
			--sum(prdsalqty) as PrdQty 
			--added on 17Nov2017 as per requirement -- PRdsalQty + PrdUnSalQty
			sum(isnull(prdsalqty,0)+isnull(prdUnsalqty,0)) as PrdQty 
			from jandjconsolelive.dbo.salesreturn with(nolock) 
			where 1=1 and convert(varchar(10),srndate,120) between convert(varchar(10),@frDate,120) and convert(varchar(10),@toDateBC,120)
			and convert(varchar(10),CreatedDate,120) <=@toDate  --addeds
			-- and month(srndate)= @mon and year(srndate)=@yr 
			group by distcode)a
			
			full outer join

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty 
			from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and mon= @mon and yr=@yr and src='SR' and runmm= @mon and runyr=@yr
			group by distcode,yr,mon )b 
			
			on a.DistCode=b.DistCode and a.mon=b.mon and a.yr=b.yr
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(-b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(-b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)
	
	/***************************************************QUERY 3*****************************************************************/
	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query3C'from 
		(
			--select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.mon,b.mon) as Month,ISNULL(a.yr,b.yr) as Year,a.PrdgrossAmt,a.PrdQty 
			--from 
			--(select distcode ,month(salinvdate) as mon,year(salinvdate) as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty 
			--from jandjconsolelive.dbo.dailysales with(nolock) 
			--where 1=1  and convert(varchar(10),createddate,120) between convert(varchar(10),@FrmCMEDt,120) and convert(varchar(10),@toDate,120) and 
			--((month(salinvdate) < @mon and year(salinvdate)=@yr) or  (year(salinvdate) < @yr))
			--group by distcode,year(salinvdate),month(salinvdate))a

			select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.M_salinvdate,b.mon) as Month,ISNULL(a.yr_salinvdate,b.yr) as Year,a.PrdgrossAmt,a.PrdQty from 

			(select distcode as distcode, 
			 convert(int, substring(M_Yr_salinvdate,1, charIndex('-', M_Yr_salinvdate)-1))  M_salinvdate, 
			 convert(int, substring(M_Yr_salinvdate,charIndex('-', M_Yr_salinvdate)+1,4))   yr_salinvdate,
			 sum(prdgrossamt)prdgrossamt,
			 sum(prdqty)prdqty			 
			from 
			(
			select distcode,salinvdate, 
			(select	convert(varchar(10),monthKey)+'-'+convert(varchar(10),year) from LAKSHYA.cdgmaster.BusinessCalender where salinvdate = DS.salinvdate) as M_Yr_salinvdate,
			sum(prdgrossamt) prdgrossamt,
			sum(prdqty)prdqty 
			from JandJConsoleLive.dbo.dailysales DS with(nolock)
			where convert(varchar(10),createddate,120) between @FrmCMEDt and @toDate and convert(varchar(10),salinvdate,120) < @frDate
			group by distcode,salinvdate
			) s group by s.DistCode,year(s.salinvdate),MONTH(s.salinvdate),M_Yr_salinvdate
			) a	--group by distcode,M_salinvdate,yr_salinvdate)
			
			FULL OUTER JOIN 

			((select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and ((mon < @mon and yr=@yr) or (yr < @yr)) and src='DS' and runmm=@mon and runyr=@yr group by distcode,yr,mon))b 

			on a.distCode collate database_Default=b.DistCode collate database_Default and a.M_salinvdate=b.mon and a.yr_salinvdate=b.yr 
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID collate database_Default=c.distCode collate database_Default
	)
	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query3PF' from 
		(
			--select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.mon) as Month,ISNULL(b.yr,a.yr) as Year,b.PrdgrossAmt,b.PrdQty 
			--from (select distcode ,month(salinvdate) as mon,year(salinvdate) as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty 
			--from jandjconsolelive.dbo.dailysales with(nolock) 
			--where 1=1  and convert(varchar(10),createddate,120) between convert(varchar(10),@FrmCMEDt,120) and convert(varchar(10),@toDate,120) and 
			--((month(salinvdate) < @mon and year(salinvdate)=@yr) or  (year(salinvdate) < @yr))
			--group by distcode,year(salinvdate),month(salinvdate))a 
			
			select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.M_salinvdate) as Month,ISNULL(b.yr,a.yr_salinvdate) as Year,b.PrdgrossAmt,b.PrdQty from 

			(select distcode as distcode, 
			 convert(int, substring(M_Yr_salinvdate,1, charIndex('-', M_Yr_salinvdate)-1))  M_salinvdate, 
			 convert(int, substring(M_Yr_salinvdate,charIndex('-', M_Yr_salinvdate)+1,4))   yr_salinvdate,
			 sum(prdgrossamt)prdgrossamt,
			 sum(prdqty)prdqty			 
			from 
			(
			select distcode,salinvdate, 
			(select	convert(varchar(10),monthKey)+'-'+convert(varchar(10),year) from LAKSHYA.cdgmaster.BusinessCalender where salinvdate = DS.salinvdate) as M_Yr_salinvdate,
			sum(prdgrossamt) prdgrossamt,
			sum(prdqty)prdqty 
			from JandJConsoleLive.dbo.dailysales DS with(nolock)
			where convert(varchar(10),createddate,120) between @FrmCMEDt and @toDate and convert(varchar(10),salinvdate,120) < @frDate
			group by distcode,salinvdate
			) s group by s.DistCode,year(s.salinvdate),MONTH(s.salinvdate),M_Yr_salinvdate
			) a	--group by distcode,M_salinvdate,yr_salinvdate)
			
			FULL OUTER JOIN 

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and ((mon < @mon and yr=@yr) or (yr < @yr)) and src='DS' and runmm=@mon and runyr=@yr
			group by distcode,yr,mon )b 

			on a.distCode collate database_Default=b.DistCode collate database_Default and a.M_salinvdate=b.mon and a.yr_salinvdate=b.yr 
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.PrdQty, 0)<>ISNULL(b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)
	/***************************************************QUERY 4*****************************************************************/

	
	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.prdsalqty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query4C' from 
		(
			select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.M_srndate,b.mon) as Month,ISNULL(a.Yr_srndate,b.yr) as Year,a.PrdgrossAmt,a.prdsalqty
			from

			---
			-- ( select distcode,month(srndate) as mon,year(srndate) as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdsalqty) as PrdQty 
			--from jandjconsolelive.dbo.salesreturn with(nolock) 
			--where 1=1 and convert(varchar(10),createddate,120) between convert(varchar(10),@FrmCMEDt,120) and convert(varchar(10),@toDate,120) and 
			--((month(srndate) < @mon and year(srndate)=@yr) or  (year(srndate) < @yr))
			--group by distcode,year(srndate),month(srndate))a 

			---
			(
			select distcode, 
			convert(int, substring(M_Yr_srndate,1, charIndex('-', M_Yr_srndate)-1)) M_srndate, 
			convert(int, substring(M_Yr_srndate,charIndex('-', M_Yr_srndate)+1,4))  Yr_srndate, 
			sum(prdgrossamt)prdgrossamt, sum(prdsalqty)prdsalqty
			from (

			select distcode,srndate, 
			(select convert(varchar(10),monthKey)+'-'+convert(varchar(10),year) from LAKSHYA.cdgmaster.BusinessCalender where salinvdate = SR.SRNDate) M_Yr_srndate, 
			sum(prdgrossamt) prdgrossamt,
			----commented on 17Nov2017
			--sum(prdsalqty) prdsalqty
			--added on 17Nov2017 as per requirement -- PRdsalQty + PrdUnSalQty
			sum(isnull(prdsalqty,0)+isnull(prdUnsalqty,0)) as prdsalqty 
			from JandJConsoleLive.dbo.salesreturn SR with(nolock)
			where convert(varchar(10),createddate,120) between @FrmCMEDt and @toDate and convert(varchar(10),srndate,120) < @frDate
			group by distcode,SR.SRNDate
			)s
			group by distcode,M_Yr_srndate
			) a --group by DistCode, M_srndate,Yr_srndate)a

			FULL OUTER JOIN 

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and ((mon < @mon and yr=@yr) or (yr < @yr)) and src='SR' and runmm=@mon and runyr=@yr
			group by distcode,yr,mon)b 

			on a.distCode=b.DistCode and a.M_srndate=b.mon and a.Yr_srndate=b.yr 
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(-b.PrdGrossAmt, 0) or ISNULL(a.prdsalqty, 0)<>ISNULL(-b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
    )

	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
	   select c.distcode,c.Month,c.Year,c.PrdgrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N' and d.SuperStockist='Y' then  'SuperStockist' ELSE'Wave' END AS PSNONPS,'Query4PF' from 
		(
			select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.M_srndate) as Month,ISNULL(b.yr,a.Yr_srndate) as Year,b.PrdGrossAmt,b.PrdQty--.prdsalqty
			from
			--select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.mon) as Month,ISNULL(b.yr,a.yr) as Year,b.PrdgrossAmt,b.PrdQty 
			--from ( select distcode,month(srndate) as mon,year(srndate) as yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdsalqty) as PrdQty 
			--from jandjconsolelive.dbo.salesreturn with(nolock) where 1=1 and convert(varchar(10),createddate,120) between convert(varchar(10),@FrmCMEDt,120) and convert(varchar(10),@toDate,120) and 
			--((month(srndate) < @mon and year(srndate)=@yr) or  (year(srndate) < @yr))
			--group by distcode,year(srndate),month(srndate))a 

			(
			select distcode, 
			convert(int, substring(M_Yr_srndate,1, charIndex('-', M_Yr_srndate)-1)) M_srndate, 
			convert(int, substring(M_Yr_srndate,charIndex('-', M_Yr_srndate)+1,4))  Yr_srndate, 
			sum(prdgrossamt)prdgrossamt, sum(prdsalqty)prdsalqty
			from (

			select distcode,srndate, 
			(select convert(varchar(10),monthKey)+'-'+convert(varchar(10),year) from LAKSHYA.cdgmaster.BusinessCalender where salinvdate = SR.SRNDate) M_Yr_srndate, 
			sum(prdgrossamt) prdgrossamt,
			----commented on 17Nov2017
			--sum(prdsalqty) prdsalqty
			--added on 17Nov2017 as per requirement -- PRdsalQty + PrdUnSalQty
			sum(isnull(prdsalqty,0)+isnull(prdUnsalqty,0)) as prdsalqty 
			from JandJConsoleLive.dbo.salesreturn SR with(nolock)
			where convert(varchar(10),createddate,120) between @FrmCMEDt and @toDate and convert(varchar(10),srndate,120) < @frDate
			group by distcode,SR.SRNDate
			)s
			group by distcode,M_Yr_srndate
			) a --group by DistCode, M_srndate,Yr_srndate)a

			FULL OUTER JOIN 

			(select distcode,mon,yr,sum(prdgrossamt) as PrdGrossAmt,sum(prdqty) as PrdQty from cdgmaster.tblPF_secSalesM with(nolock) 
			where 1=1 and ((mon < @mon and yr=@yr) or (yr < @yr)) and src='SR' and runmm=@mon and runyr=@yr group by distcode,yr,mon)b 
			on a.distCode=b.DistCode and a.M_srndate=b.mon and a.Yr_srndate=b.yr 
			where (ISNULL(a.PrdGrossAmt, 0)<>ISNULL(-b.PrdGrossAmt, 0) or ISNULL(a.prdsalqty, 0)<>ISNULL(-b.PrdQty, 0))
		)
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)
	

	/***************************************************QUERY 5*****************************************************************/

	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.[NRValue*SecSales],c.SecSales,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N'
		 and d.SuperStockist='Y' then 'SuperStockist' ELSE 'Wave' END AS PSNONPS,'Query5C' from 

	      (select isnull(a.distCode,b.distCode) as distCode,ISNULL(a.JcMONTH,b.mon) as Month,ISNULL(a.JcYEAR,b.yr) as Year,a.[NRValue*SecSales],a.SecSales
			from 

			(select DistCode, JcMONTH, JcYEAR, SUM(SecSales)as SecSales, SUM(NRValue*SecSales)as [NRValue*SecSales]
			from JandJConsoleLive.dbo.SuperStockiestRetailing with(nolock) 
			where 1=1 and JcMONTH =@mon and JcYEAR=@yr and SecSales <> 0 and
			DistCode collate DATABASE_DEFAULT in (select SAPID from lakshya.cdgmaster.Customer with(nolock) where IsActive='Y' and Superstockist='Y' and PSnonPS='N')  
			group by DistCode,JcYEAR,JcMONTH) a

			full outer join
			(
			select distCode,mon,yr,sum(PrdQty) as PrdQty,sum(PrdGrossAmt) as PrdGrossAmt--,SRC,runMM,runYr 
			from lakshya.cdgmaster.tblPF_secSalesM with(nolock) 
			where mon= @mon and yr=@yr and SRC='SS' and runmm= @mon and runyr=@yr  
			group by distcode,yr,mon--,src,runmm,runyr 
			)b

	        on a.distCode=b.DistCode and a.JcMONTH=b.mon and a.JcYEAR=b.yr 
			where (ISNULL(a.[NRValue*SecSales], 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.SecSales, 0)<>ISNULL(b.PrdQty, 0))
	       )
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
    )

	INSERT INTO cdgmaster.WaveDataCheckUI(distCode,Month,Year,prdGrossAmt,prdQty,PSNONPS,checkType) 
	(
		select c.distcode,c.Month,c.Year,c.PrdGrossAmt,c.PrdQty,CASE WHEN d.PSNONPS='N' and d.SuperStockist='N' THEN 'Non Wave' when d.PSNONPS='N'
		 and d.SuperStockist='Y' then 'SuperStockist' ELSE 'Wave' END AS PSNONPS,'Query5PF' from 

	      (select isnull(b.distCode,a.distCode) as distCode,ISNULL(b.mon,a.JcMONTH) as Month,ISNULL(b.yr,a.JcYEAR) as Year,b.PrdGrossAmt,b.PrdQty--a.[NRValue*SecSales],a.SecSales
			from 
			(select DistCode, JcMONTH, JcYEAR, SUM(SecSales)as SecSales, SUM(NRValue*SecSales)as [NRValue*SecSales]
			from JandJConsoleLive.dbo.SuperStockiestRetailing with(nolock) 
			where 1=1 and JcMONTH =@mon and JcYEAR=@yr and SecSales <> 0 and
			DistCode collate DATABASE_DEFAULT in (select SAPID from lakshya.cdgmaster.Customer with(nolock) where IsActive='Y' and Superstockist='Y' and PSnonPS='N')  
			group by DistCode,JcYEAR,JcMONTH) a

			full outer join
			(
			select distCode,mon,yr,sum(PrdQty) as PrdQty,sum(PrdGrossAmt) as PrdGrossAmt--,SRC,runMM,runYr 
			from lakshya.cdgmaster.tblPF_secSalesM with(nolock) 
			where mon= @mon and yr=@yr and SRC='SS' and runmm= @mon and runyr=@yr  
			group by distcode,yr,mon--,src,runmm,runyr 
			)b
	        on a.distCode=b.DistCode and a.JcMONTH=b.mon and a.JcYEAR=b.yr 
			where (ISNULL(a.[NRValue*SecSales], 0)<>ISNULL(b.PrdGrossAmt, 0) or ISNULL(a.SecSales, 0)<>ISNULL(b.PrdQty, 0))
	       )
		c
		inner join cdgmaster.customer d on d.SAPID=c.distCode
	)
	
END
