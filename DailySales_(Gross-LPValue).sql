Declare @FromDate Date, @ToDate Date
select @FromDate=cast(min(salinvdate) as date), @ToDate=cast(max(salinvdate) as date) from LAKSHYA.cdgmaster.BusinessCalender(nolock) 
where monthKey=1 and year=2018 
print @FromDate
print @ToDate

--drop table #DAILYSALES_1
--SELECT	DistCode,C.CustomerName,PrdCode,S.SKUName,
--		sum(PrdQty)PrdQty,sum(LPValue*PrdQty) LPValue, sum(PrdGrossAmt)PrdGrossAmt, sum(PrdGrossAmt - (LPValue*PrdQty)) [PrdGrossAmt - LPVALUE] ,
--		sum(PrdSchDiscAmt)PrdSchDiscAmt,sum(PrdSplDiscAmt)PrdSplDiscAmt,sum(PrdDBDiscAmt)PrdDBDiscAmt,sum(PrdCashDiscAmt)PrdCashDiscAmt
--into	#DAILYSALES_1
--FROM	JANDJCONSOLELIVE..DAILYSALES D(NOLOCK)
--left	outer join LAKSHYA.cdgmaster.Customer C(nolock)	on D.DistCode=C.SAPID
--left	outer join LAKSHYA.cdgmaster.SKU S(nolock)	on D.PrdCode=S.SAPID
--where	cast(convert(varchar(10),salinvdate,111)as datetime) between @FromDate and @ToDate	
--group	by DistCode,C.CustomerName,PrdCode,S.SKUName
--order	by DistCode,PrdCode	
--select * #DAILYSALES_1

drop table #DAILYSALES
SELECT	DistCode,C.CustomerName,PrdCode,S.SKUName,
		sum(PrdQty)PrdQty,sum(LPValue*PrdQty) LPValue, sum(PrdGrossAmt)PrdGrossAmt, sum(PrdGrossAmt - (LPValue*PrdQty)) [PrdGrossAmt - LPVALUE] ,
		sum(PrdSchDiscAmt)PrdSchDiscAmt,sum(PrdSplDiscAmt)PrdSplDiscAmt,sum(PrdDBDiscAmt)PrdDBDiscAmt,sum(PrdCashDiscAmt)PrdCashDiscAmt
into	#DAILYSALES
FROM	JNJHISTORY..JNJSalesDetails D(NOLOCK)
left	outer join LAKSHYA.cdgmaster.Customer C(nolock)	on D.DistCode=C.SAPID
left	outer join LAKSHYA.cdgmaster.SKU S(nolock)	on D.PrdCode=S.SAPID
where	cast(convert(varchar(10),salinvdate,111)as datetime) between @FromDate and @ToDate	
group	by DistCode,C.CustomerName,PrdCode,S.SKUName
order	by DistCode,PrdCode	
select * from #DAILYSALES

--insert into #DAILYSALES
--select * from #DAILYSALES_1

--SELECT	DistCode,CustomerName,PrdCode,SKUName,
--		sum(PrdQty)PrdQty,sum(LPValue*PrdQty) LPValue, sum(PrdGrossAmt)PrdGrossAmt, sum(PrdGrossAmt - (LPValue*PrdQty)) [PrdGrossAmt - LPVALUE] ,
--		sum(PrdSchDiscAmt)PrdSchDiscAmt,sum(PrdSplDiscAmt)PrdSplDiscAmt,sum(PrdDBDiscAmt)PrdDBDiscAmt,sum(PrdCashDiscAmt)PrdCashDiscAmt
--FROM	#DAILYSALES D(NOLOCK)
--group	by DistCode,CustomerName,PrdCode,SKUName
--order	by DistCode,PrdCode	

