--salvage data
--run one by one
SELECT	pm.ProductCode,pm.SKUCode,pm.ModifiedDate
into	#SKU_Mapping
FROM	JandJConsoleLive.dbo.ProductMapping pm with (nolock) 
INNER	JOIN 
		(	SELECT	max(ModifiedDate) maxf1, ProductCode 
			FROM	JandJConsoleLive.dbo.ProductMapping with (nolock) 
			GROUP	BY ProductCode) f
on		f.maxf1 = pm.ModifiedDate and 
		f.ProductCode = pm.ProductCode
order	by pm.ModifiedDate desc


select	SKUCode, SAPID, SKUDesc, SKUName 
into	#SKU_Name
from	Lakshya.cdgmaster.SKu with (nolock)


select	* 
into	#SalvageDetails
from	JandJConsoleLive.dbo.SalvageDetails s with (nolock)  inner join
lakshya.cdgmaster.BusinessCalender b with(nolock)
on s.SalvageDate=b.salinvdate
where b.year=2019 and b.monthKey in (6) --month 
--change the date range and the month

select	s.DistCode,s.SalvageRefNo,s.SalvageDate,s.PrdCCode,
		sku.skucode as Console_Prodcode_Mapp,
		SN.SKUName as PrdName,
		s.PrdDCode,s.Prdbatcode,s.SalvageQty,s.UOM,s.MRP,s.ClaimRate,s.SalAmount,s.SyncId,s.CreatedUserId,s.CreatedDate,s.SKUCode
into	#Full_Salvage_Data
from	#SalvageDetails s
left	outer join #SKU_Mapping SKU on S.PrdCCode=sku.ProductCode
left	outer join #SKU_Name SN on S.PrdCCode=sn.SAPID	

---------------------------------------Data---------------------------------------------------------------

--	Salvage Full Data
select	* from #Full_Salvage_Data

--	West
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=2 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

--	East
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=3 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

--	North
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=4 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

--	South
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=5 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

-- north central
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=10 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

-- south central
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=11 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')

--east central
select	* from #Full_Salvage_Data where distcode in 
(select SAPID from Lakshya.cdgmaster.customer with (nolock) where regioncode=12 and isactive='Y'
and SAPID is not null and SAPID like '%1%' and SAPID <> '')



--SheetName 2 - SKU_Mapping
select * from #SKU_Mapping

--SheetName 3 - SKU_Name
select * from #SKU_Name