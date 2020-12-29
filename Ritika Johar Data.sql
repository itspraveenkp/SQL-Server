select b.*,d.RegionName,d.ZoneName
from	UDCdetails b with(nolock)
inner	join 
		(select MasterValueCode,distcode,max(createddate) as createddate
		From	UDCdetails with(nolock) where columnName='Platinum Q2 2019New' and MasterName='Retailer Master'
		Group	by MasterValueCode,distcode) c
on		b.MasterValueCode=c.MasterValueCode  and b.distcode=c.distcode and b.createddate=c.createddate
inner	join (select c.SAPID,r.RegionName,z.ZoneName from LAKSHYA.cdgmaster.customer c inner join LAKSHYA.cdgmaster.region r on c.RegionCode=r.RegionCode
inner	join LAKSHYA.cdgmaster.Zone z on c.ZoneCode=z.ZoneCode) d on b.DistCode=d.SAPID
where   b.ColumnName='Platinum Q2 2019New' and b.MasterName='Retailer Master' and b.ColumnValue='YES'