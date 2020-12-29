CREATE PROCEDURE sp_tempTableInDynamicSQL 
AS 
BEGIN
	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = 'CREATE TABLE #TEST(ID INT)
				INSERT INTO #TEST VALUES(101)
				SELECT * FROM #TEST'
	EXECUTE SP_EXECUTESQL @SQL
END

EXECUTE sp_tempTableInDynamicSQL

-- WE CAN NOT USE BELOW SP AS  TEMP TABLE BECAUSE WE WILL GET ERROR WHILE EXECUTE SP

ALTER PROCEDURE sp_tempTableInDynamicSQL
AS
BEGIN
	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = 'CREATE TABLE #TEST(ID INT)
				INSERT INTO #TEST VALUES(101)'
	EXECUTE SP_EXECUTESQL
	SELECT * FROM #TEST
END

EXECUTE sp_tempTableInDynamicSQL

--Msg 201, Level 16, State 10, Procedure sp_executesql, Line 1 [Batch Start Line 24]
--Procedure or function 'sp_executesql' expects parameter '@statement', which was not supplied.
--Msg 208, Level 16, State 0, Procedure sp_tempTableInDynamicSQL, Line 8 [Batch Start Line 24]
--Invalid object name '#TEST'.



Alter procedure sp_tempTableInDynamicSQL
as
Begin
       Create Table #Test(Id int)
       insert into #Test values (101)
       Declare @sql nvarchar(max)
       Set @sql = 'Select * from #Test'
       Execute sp_executesql @sql
End

Execute sp_tempTableInDynamicSQL

ALTER PROCEDURE spTempTableInDynamicSQL
AS
BEGIN
	CREATE TABLE #TEST(ID INT)
	INSERT INTO #TEST VALUES(101)
	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = 'SELECT * FROM #TEST'
	EXECUTE SP_EXECUTESQL
END