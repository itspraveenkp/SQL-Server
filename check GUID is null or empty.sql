DECLARE @MYGUID  UNIQUEIDENTIFIER

IF(@MYGUID IS NULL)
BEGIN
	PRINT 'GUID IS NULL'
END
ELSE
BEGIN
	PRINT 'GUID IS NOT NULL'
END


IF(@MYGUID IS NULL)
BEGIN
	SET @MYGUID = NEWID()
END

SELECT @MYGUID AS MYGUID

SELECT ISNULL(@MYGUID,NEWID()) AS MYGUID

SELECT CAST(0 AS BINARY)

SELECT CAST(CAST(0 AS BINARY) AS uniqueidentifier)

SELECT CAST(0X0 AS uniqueidentifier)

SET @MYGUID = '00000000-0000-0000-0000-000000000000'

IF(@MYGUID = '00000000-0000-0000-0000-000000000000')
BEGIN
	PRINT 'GUID IS NULL'
END
ELSE
BEGIN
	PRINT 'GUID IS NOT NULL'
END

SELECT @MYGUID AS MYGUID

IF(@MYGUID = CAST(0X0 AS uniqueidentifier))
BEGIN
	PRINT 'GUID IS EMPTY'
END
ELSE
BEGIN
	PRINT 'GUID IS NOT EMPTY'
END