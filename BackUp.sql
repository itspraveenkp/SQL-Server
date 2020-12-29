
insert into Test_LinkedConsoletoRDS.db_Test.dbo.Territory_BackUptable
(
	[TerritoryCode] ,
	[TerritoryName] ,
	[ZoneCode],
	[SAPID] ,
	[createdBy] ,
	[isdeleted]
) 
Select top 10 [TerritoryCode] ,
	[TerritoryName] ,
	[ZoneCode] ,
	[SAPID] ,
	[createdBy] ,
	[isdeleted] from LAKSHYA.cdgmaster.Territory(nolock)
