--SchedularSchemeDetailReport_N_2013_To_2016
--SchedularSchemeReport_N_2013_To_2016
--SchedulerScheme_N_2013_To_2016

use [Lakshya_20180525]

------------------SET 1------------------
Declare @FromDate Date, @ToDate Date
select @FromDate=cast(min(salinvdate) as date), @ToDate=cast(max(salinvdate) as date) from Lakshya_20180525.cdgmaster.BusinessCalender(nolock) 
where monthKey=6 and year=2016 
print @FromDate
print @ToDate
--drop table #SchedularSchemeReportId
select  h.SchedularSchemeReportId 
into	#SchedularSchemeReportId
from	Lakshya_20180525.cdgmaster.SchedularSchemeReport_N_2013_To_2016 h with(nolock) 
inner	join Lakshya_20180525.cdgmaster.SchedulerScheme_N_2013_To_2016 s with(nolock) on s.schedulerId = h.schedularId
		and cast(convert(varchar(10),s.StartDate,111)as datetime) between @FromDate and @ToDate 
------------------SET 1------------------



------------------SET 2------------------
--drop	table #SchedularSchemeDetailReport_N_2013_To_2016
select	DistCode as Distributor_Code,
		CompanySchemeCode as Scheme_Identifier,
		InvoiceNo as Unique_Invoice_Identifier,
		BilledPrdCCode as Product_Identifier,
		SchemeType as Type_of_gratification,
		SchemeAmount as Value_of_gratification,
		convert(varchar(10),cast(SalInvDate as date),112) as TimeStamp,
		RtrCode,
		Claimable
into	#SchedularSchemeDetailReport_N_2013_To_2016
from	Lakshya_20180525.cdgmaster.SchedularSchemeDetailReport_N_2013_To_2016 d  with(nolock)
where	d.SchedularSchemeReportId in 
		(select SchedularSchemeReportId from #SchedularSchemeReportId)

select * from #SchedularSchemeDetailReport_N_2013_To_2016
------------------SET 2------------------
