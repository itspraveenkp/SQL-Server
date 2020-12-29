--select SAPID into #Wave from lakshya.cdgmaster.Customer with(nolock) where IsActive='Y' and ISNULL(PSnonPS,'N')='Y' and ISNULL(Superstockist,'N')='N'

select	*							
into	#DailySales							
from	JandJConsoleLive.dbo.dailysales DS with(nolock)							
where	--DistCode in (select SAPID from #Wave) and							
		ISNULL(NRValue,0)=0						
								
select	*							
into	#SalesReturn							
from	JandJConsoleLive.dbo.SalesReturn SR with(nolock)							
where	--DistCode in (select SAPID from #Wave) and							
		ISNULL(NRValue,0)=0						
								
select	*							
into	#DailySales_Undelivered							
from	JandJConsoleLive.dbo.dailysales_undelivered DSU with(nolock)							
where	--DistCode in (select SAPID from #Wave) and							
		ISNULL(NRValue,0)=0						

select * from #DailySales
select * from #SalesReturn
select * from #DailySales_Undelivered