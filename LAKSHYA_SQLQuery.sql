
-----------------------------RDS----------------------------------------------------------
USE LAKSHYA

SELECT TOP 2 * FROM cdgmaster.Customer (NOLOCK)
SELECT * FROM cdgmaster.Customer (NOLOCK) WHERE SAPID = '115034'

-------------------------------------------------------------------------------------------
USE JandJConsoleLive

SELECT TOP 2 * FROM JandJConsoleLive.dbo.UserMaster(NOLOCK)
SELECT * FROM JandJConsoleLive.dbo.UserMaster(NOLOCK) WHERE UserCode = '152858762' AND Address LIKE ('%MITCHEL JUNCTION%')

--------------------------------------------------------------------------------------------

USE LAKSHYA

SELECT TOP 2 * FROM cdgmaster.MUser (NOLOCK)
SELECT * FROM cdgmaster.MUser (NOLOCK) WHERE MEMailId ='sales@hasmukhagency.com'
SELECT * FROM cdgmaster.MUser(NOLOCK) WHERE WWSAPID ='152808996'

SELECT * FROM cdgmaster.Territory(NOLOCK)
SELECT * FROM cdgmaster.Territory(NOLOCK) WHERE TerritoryName LIKE '%ankul%'
SELECT * FROM cdgmaster.Territory(NOLOCK) WHERE TerritoryCode = '42'

SELECT * FROM cdgmaster.ZONE(NOLOCK)
SELECT * FROM cdgmaster.ZONE(NOLOCK) WHERE ZoneName LIKE '%Kerala%'
SELECT * FROM cdgmaster.ZONE(NOLOCK) WHERE ZoneCode = '4'
SELECT * FROM cdgmaster.ZONE(NOLOCK) WHERE ZoneCode IN (79,123)

SELECT * FROM cdgmaster.Region(NOLOCK)
SELECT * FROM cdgmaster.Region(NOLOCK) WHERE RegionName LIKE '%West%'
SELECT * FROM cdgmaster.Region(NOLOCK) WHERE RegionCode ='5120'

--**************************************************************************
--GET TERRITORY,ZONE,REGION (PUT TERRITORY CODE)

SELECT R.RegionCode,R.RegionName,Z.ZoneCode,Z.ZoneName,T.TerritoryCode,T.TerritoryName  
FROM cdgmaster.Territory T (NOLOCK)
INNER JOIN cdgmaster.Zone Z(NOLOCK) ON T.ZoneCode = Z.ZoneCode
INNER JOIN cdgmaster.Region R(NOLOCK) ON Z.RegionCode = R.RegionCode
WHERE T.TerritoryCode =42 


------------------------------------------------------------------------------------------
--GET ABI DETAILS WITH TERRITORY, ZONE, REGION 

SELECT * FROM cdgmaster.MUser(NOLOCK) WHERE TerritoryCode = 241 
AND UserDeleted ='N' AND MUserCode IN 
(SELECT UserCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE GroupCode = 1)

-------------------------------------------------------------------------------------------
--GET FLM DETAILS WITH REGION, ZONE

SELECT * FROM cdgmaster.MUser(NOLOCK) WHERE ZoneCode = 84
AND UserDeleted ='N' AND MUserCode IN
(SELECT UserCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE GroupCode = 2)

-------------------------------------------------------------------------------------------
--

SELECT * FROM cdgmaster.MUser(NOLOCK) WHERE UserDeleted<> 'y' AND MUserCode IN 
(SELECT UserCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE GroupCode IN 
(SELECT GroupCode FROM cdgmaster.SecurityGroup(NOLOCK) WHERE GroupName IN ('NWC_FLM')))
AND
NWCTerritory IN 
(SELECT ZoneCode FROM cdgmaster.Zone(NOLOCK) WHERE ZoneName = 'RAJASTHAN')

--------------------------------------------------------------------------------------------

SELECT * FROM cdgmaster.SecurityGroup(NOLOCK)


---------------------------------------------------------------------------------------------

--CHECK USER ROLES FOR CLICKJJINDIA

SELECT * FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE UserCode IN (3069)
SELECT * FROM cdgmaster.SecurityGroup(NOLOCK) WHERE GroupCode IN (1,39)
SELECT * FROM cdgmaster.Plant(NOLOCK) WHERE PlantCode=9


-----------------------------------------------------------------------------------------------
--FOR ABI

SELECT * FROM cdgmaster.Territory(NOLOCK) WHERE TerritoryName LIKE '%%'

SELECT * FROM cdgmaster.MUser (NOLOCK) WHERE WWSAPID = 702065374
AND MUserCode IN (SELECT UserCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE GroupCode=33)

---------------------------------------------------------------------------------------------
SELECT C.ChannelCode,C.SAPID,C.*,T.TerritoryName FROM cdgmaster.Customer C(NOLOCK)
INNER JOIN cdgmaster.Territory T(NOLOCK) ON C.TerritoryCode = T.TerritoryCode
INNER JOIN cdgmaster.Region R (NOLOCK) ON C.RegionCode = R.RegionCode
INNER JOIN cdgmaster.Zone Z(NOLOCK) ON C.ZoneCode = Z.ZoneCode
WHERE C.SAPID IN ('131445')

--------------------------------------------------------------------------------------------

SELECT * FROM cdgmaster.SecurityGroup (NOLOCK) WHERE GroupCode IN
(SELECT GroupCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE UserCode = 1859)

---------------------------------------------------------------------------------------------

--KNOW USER WHICH TERRITORY HAVING ACCESS.

SELECT TerritoryCode,NWCTerritory,UserDeleted FROM cdgmaster.MUser(NOLOCK) WHERE NWCTerritory IN (264)
AND
UserDeleted IN ('N','F') AND MUserCode IN
(SELECT UserCode FROM cdgmaster.UserGroupDetail(NOLOCK) WHERE GroupCode = 1)


-----------------------------------------------------------------------------------------------

--MODULE

SELECT * FROM cdgmaster.tblclmMUser(NOLOCK) WHERE MUserName IN ('')
SELECT * FROM cdgmaster.tblclmSecurityGroup(NOLOCK) WHERE GroupCode IN (33)

SELECT * FROM cdgmaster.tblclmSystemModule WHERE ModuleCode IN
(SELECT ModuleCode FROM cdgmaster.tblclmSystemModule(NOLOCK) WHERE ModuleName LIKE '%%')




















