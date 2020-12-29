CREATE PROCEDURE spSearchEmployeesGOODDynamicSQL
@FIRSTNAME NVARCHAR(100),
@LASTNAME NVARCHAR(100),
@GENDER NVARCHAR(100),
@SALARY INT
AS
BEGIN
	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = 'SELECT * FROM EMPLOYEE_ WHERE 1 = 1'

	IF(@FIRSTNAME IS NOT NULL)
		SET @SQL = @SQL + 'AND FIRSTNAME = @FN'
	IF(@LASTNAME IS NOT NULL)
		SET @SQL = @SQL + ' AND LASTNAME = @LN'
	IF(@GENDER IS NOT NULL)
		SET @SQL = @SQL + 'AND GENDER = @GEN'
	IF(@SALARY IS NOT NULL)
		SET @SQL = @SQL + 'AND SALARY = @SAL'

		EXECUTE sp_execute @SQL
END
