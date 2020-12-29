use [Lakshya]
------------------SET 1------------------
Declare @FromDate Date, @ToDate Date
select @FromDate=cast(min(salinvdate) as date), @ToDate=cast(max(salinvdate) as date) from LAKSHYA.cdgmaster.BusinessCalender(nolock) 
where monthKey=1 and year=2018 
print @FromDate
print @ToDate

--drop table #SchedularSchemeReportId

select  h.SchedularSchemeReportId 
into	#SchedularSchemeReportId
from	Lakshya.cdgmaster.SchedularSchemeReport_n h with(nolock) 
inner	join Lakshya.cdgmaster.SchedulerScheme_n s with(nolock) on s.schedulerId = h.schedularId
		and cast(convert(varchar(10),s.StartDate,111)as datetime) between @FromDate and @ToDate 
------------------SET 1------------------



------------------SET 2------------------
--drop	table #SchedularSchemeDetailReport_n
select	DistCode as Distributor_Code,
		CompanySchemeCode as Scheme_Identifier,
		InvoiceNo as Unique_Invoice_Identifier,
		BilledPrdCCode as Product_Identifier,
		SchemeType as Type_of_gratification,
		SchemeAmount as Value_of_gratification,
		convert(varchar(10),cast(SalInvDate as date),112) as TimeStamp,
		RtrCode,
		Claimable
into	#SchedularSchemeDetailReport_n
from	Lakshya.cdgmaster.SchedularSchemeDetailReport_n d  with(nolock)
where	d.SchedularSchemeReportId in 
		(select SchedularSchemeReportId from #SchedularSchemeReportId)

select * from #SchedularSchemeDetailReport_n
------------------SET 2------------------

