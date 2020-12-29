USE UAT

--Example returns all the objects that depend on Employees table

SELECT * FROM SYS.dm_sql_referencing_entities('DBO.tblEmployee','OBJECT') -- FOR TABLES

SELECT * FROM SYS.dm_sql_referenced_entities('DBO.spGetEmployee','OBJECT') -- STORE PROCEDURE

