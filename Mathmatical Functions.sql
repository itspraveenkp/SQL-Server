SELECT ABS(20.387) -- ABS FUNCTION RETURN AS ABSULUTE FUNCTION
SELECT ABS(-20.387) -- BUT THIS IS ALSO RETURN ON ACTUAL NUMBER LIKE 20.387

SELECT CEILING(20.01) -- CEILING RETURN NUMERIC VALUE(IF THERE 12.03 THAN CEILING RETURN 13
SELECT CEILING(-20.45)

SELECT FLOOR(12.34) -- IN FLOOR FUNCTION IGNORE AFTER DECIMAL POINT VALUE. RETURN ON ACTUAL COUNT.
SELECT FLOOR(-12.34) -- BUT WHERE WE ARE TOLKING ABOUT MINUS VALUE THAN RETURN ADD +1 

SELECT POWER(2,3) --2*2*2 POWER FUNCTION RETURN POWER VALUE OF THE SPECIFIED EXPRESSION.

SELECT RAND() -- RAND FUNCTION RETURN RANDOM NUMBER IN DECIMAL POINT.
SELECT RAND(1) -- IF IN RAND WE PASS VALUE AS 1 THAN RAND IS STABLE ON SAME NUMBER.

SELECT (RAND() * 100) -- QUERY WILL RETURN 1 TO 100 IN DECIMAL


--THE FOLLOWING QUERY PRINTS 10 RANDOM NUMBER BETWEEN 1 TO 100.
DECLARE @COUNT INT
SET @COUNT = 1
WHILE(@COUNT <= 10)
	BEGIN
		PRINT(FLOOR(RAND() * 100))
		SET @COUNT = @COUNT +1
	END


SELECT ROUND(12.345,0)
SELECT ROUND(12.345,2,1)
