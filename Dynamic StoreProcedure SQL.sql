USE UAT

DROP TABLE EMPLOYEE_

CREATE TABLE EMPLOYEE_
(
	ID INT IDENTITY(1,1),
	FIRSTNAME VARCHAR(50),
	LASTNAME VARCHAR(50),
	GENDER VARCHAR(50),
	SALARY INT
)


Insert into Employee_ values ('Mark', 'Hastings', 'Male', 60000)
Insert into Employee_ values ('Steve', 'Pound', 'Male', 45000)
Insert into Employee_ values ('Ben', 'Hoskins', 'Male', 70000)
Insert into Employee_ values ('Philip', 'Hastings', 'Male', 45000)
Insert into Employee_ values ('Mary', 'Lambeth', 'Female', 30000)
Insert into Employee_ values ('Valarie', 'Vikings', 'Female', 35000)
Insert into Employee_ values ('John', 'Stanmore', 'Male', 80000)
Go


CREATE PROC SP_SEARCHEMPLOYEE
	@FIRSTNAME VARCHAR(50),
	@LASTNAME VARCHAR(50),
	@GENDER VARCHAR(50),
	@SALARY INT
AS
BEGIN
	SELECT * FROM EMPLOYEE_ WHERE 
	(FIRSTNAME = @FIRSTNAME OR @FIRSTNAME IS NULL) AND
	(LASTNAME = @LASTNAME OR @LASTNAME IS NULL) AND
	(GENDER = @GENDER OR @GENDER IS NULL) AND
	(SALARY = @SALARY OR @GENDER IS NULL)
END


--EXECUTE SP_SEARCHEMPLOYEE 'Mark' ,NULL,NULL,NULL

DECLARE @SQL NVARCHAR(1000)
DECLARE @PARAMS NVARCHAR(1000)

SET @SQL = 'SELECT * FROM EMPLOYEE_ WHERE FIRSTNAME= @FIRSTNAME AND LASTNAME = @LASTNAME'
SET @PARAMS = '@FIRSTNAME varchar(100), @LASTNAME varchar(100)'

EXECUTE sp_executesql @SQL,@PARAMS,@FIRSTNAME ='Ben', @LASTNAME ='Hoskins'

