
--//////////////////////////////////////////////////////////////////////////////////////

DECLARE @DOB DATE
DECLARE @AGE INT
SET @DOB = '12/10/1996'

SET @AGE = DATEDIFF(YEAR,@DOB,GETDATE()) - 
			CASE 
				WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR 
					 (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
					 THEN 1
					 ELSE 0
					 END
SELECT @AGE

--//////////////////////////////////////////////////////////////////////////////////////

SELECT DBO.FNSCALAR_USERAGE('12/10/1994')

--//////////////////////////////////////////////////////////////////////////////////////

--FNSCALAR_USERAGE

CREATE FUNCTION FNSCALAR_USERAGE(@DOB DATE)
RETURNS INT
AS
BEGIN
	DECLARE @AGE INT
	SET @AGE = DATEDIFF(YEAR,@DOB,GETDATE()) -
		CASE
			WHEN
			(MONTH(@DOB) > MONTH(GETDATE())) OR (MONTH(@DOB) = MONTH(GETDATE())
			AND DAY(@DOB) > DAY(GETDATE()))
			THEN 1 
			ELSE 0
		END
	RETURN @AGE
END

--//////////////////////////////////////////////////////////////////////////////////////

ALTER PROCEDURE spscalar
@DOB DATE
AS 
BEGIN
	DECLARE @AGE INT
	SET @AGE = DATEDIFF(YEAR,@DOB,GETDATE()) -
		CASE
		WHEN (MONTH(@DOB) > (MONTH(GETDATE())) OR (MONTH(@DOB)) = MONTH(GETDATE()) 
		AND  DAY(@DOB) > DAY(GETDATE()))
		THEN 1
		ELSE 0
		END
SELECT @AGE
END

execute spscalar '12/10/1996'

DECLARE @DATES DATE
SET @DATES = GETDATE()
PRINT(@DATES)















