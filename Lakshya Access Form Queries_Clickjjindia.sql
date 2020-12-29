use  LAKSHYA

select  top 2 * from cdgmaster.customer(nolock) where SAPID='152045769' like '%Singh%' ='127327'
select * from JandJConsoleLive.dbo.usermaster(nolock) where  UserCode='ashah13' Address like ('%1019461%')

select * from cdgmaster.MUser(nolock) where MEMailId='ABangawa@ITS.JNJ.COM'
select * from cdgmaster.MUser(nolock) where  WWSAPID ='1015613'

select * from cdgmaster.MUser(nolock) 

select * from cdgmaster.Territory nolock where TerritoryName like '%raj%'

select * from cdgmaster.Channel(nolock)
select * from cdgmaster.Zone(nolock) where ZoneCode in (79,123)-- and UserDeleted<>'Y'
select * from cdgmaster.MUser(nolock) where MLastName like '%Bangawala%'
select * from cdgmaster.Region(nolock) where RegionCode=10 like '%%'
select * from cdgmaster.Zone(nolock) where ZoneName like '%WEST%'
select * from cdgmaster.Territory(nolock) where  TerritoryName like '%RAJASTHAN%'
	select t.TerritoryCode,t.TerritoryName,z.ZoneCode,z.ZoneName,r.RegionCode,r.RegionName
	 from cdgmaster.Territory(nolock) t
	 inner join cdgmaster.Zone(nolock) z on t.ZoneCode=Z.ZoneCode
	 inner join cdgmaster.Region(nolock) r on z.RegionCode=r.RegionCode where t.TerritoryCode=152

--ABI -- to get territory,zone & region details
select * from cdgmaster.MUser where TerritoryCode=241 and UserDeleted='N' and MUserCode in
 (select usercode from cdgmaster.UserGroupDetail where GroupCode=1)

--FLM -- to get zone & region details
select * from cdgmaster.MUser where ZoneCode=84 and UserDeleted='N' and MUserCode in
 (select usercode from cdgmaster.UserGroupDetail where GroupCode=2)


---------------------------------------------------------------------
--------------------------------------------------------------------
select * from cdgmaster.MUser where UserDeleted<>'Y' and MUserCode in
 (
 select UserCode from cdgmaster.UserGroupDetail 
 where GroupCode in (select GroupCode from cdgmaster.SecurityGroup(nolock) where groupname in ('NWC_FLM'))
 )
 AND NWCTerritory IN ( SELECT ZoneCode FROM cdgmaster.Zone WHERE ZoneName='RAJASTHAN')
 
select * from cdgmaster.SecurityGroup(nolock)
select * from cdgmaster.MUser(nolock) 

-- For Check user roles for clickjjindia access-------

select * from cdgmaster.UserGroupDetail(nolock) where UserCode in (415)
select * from cdgmaster.SecurityGroup(nolock) where GroupCode in (1,39)

select * from cdgmaster.Plant(nolock)  where PlantCode=9

--------------FOR ABI-----------
select * from cdgmaster.Territory where TerritoryName like '%SURAT-BARODA%'

Select * from cdgmaster.MUser where WWSAPID=702065374 and   
 MUserCode in (select UserCode from cdgmaster.UserGroupDetail where GroupCode=33)

   
select C.ChannelCode,C.SAPID,t.TerritoryName,z.ZoneName,r.RegionName,c.*
from cdgmaster.customer(nolock) c 
inner join cdgmaster.Region(nolock) r on c.RegionCode=r.RegionCode
inner join cdgmaster.Zone(nolock) z on c.ZoneCode=z.ZoneCode
inner join cdgmaster.Territory(nolock) t on c.TerritoryCode=t.TerritoryCode
where c.SAPID in ('131445') 

/**********************************************************/

select * from cdgmaster.SecurityGroup where GroupCode in (
select GroupCode from cdgmaster.UserGroupDetail where UserCode=1859)

/****************************************************************/

-- to get territory,zone & region details
select t.TerritoryCode,t.TerritoryName,z.ZoneCode,z.ZoneName,r.RegionCode,r.RegionName
from cdgmaster.Territory(nolock) t
inner join cdgmaster.Zone(nolock) z on t.ZoneCode=Z.ZoneCode
inner join cdgmaster.Region(nolock) r on z.RegionCode=r.RegionCode where t.TerritoryCode in (264)

-- to know which user having access on territory
select TerritoryCode,NWCTerritory,UserDeleted,* from cdgmaster.MUser where  NWCTerritory in (264)  and UserDeleted in ('n','f') and MUserCode in
(select usercode from cdgmaster.UserGroupDetail where GroupCode in  (1)) 


/****************************************************************/
---Module--
select GroupCode,* from cdgmaster.tblclmMUser where MUserName in ('')
select * from cdgmaster.tblclmSecurityGroup(nolock) where GroupCode in (33)

select * from cdgmaster.tblclmsystemModule where ModuleCode in (
select ModuleCode from cdgmaster.tblclmSystemModule where ModuleName like '%Wave Reports%')

Select * from cdgmaster.Customer where  SAPID = '189406764'

select * from cdgmaster.MUser where MUserName='189406764'

select * from ProfileMaster(nolock) where ProfileId=13

--sp_helpdb 'JandJConsoleLive'

select * from cdgmaster.MUser(nolock) where TerritoryCode<>NWCTerritory and NWCTerritory=284
