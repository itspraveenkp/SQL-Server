USE UAT

SELECT TRY_PARSE('99' AS INT) AS RESULT 
SELECT TRY_PARSE('abc' AS INT) AS RESULT -- WHEN UNABL TO CONVERT IN ALPHABET THEN RETURN 'NULL'

SELECT 
CASE WHEN TRY_PARSE('ABC' AS INT) IS NULL
	 THEN 'CONVERSION FAIL'
	 ELSE 'CONVERSION SUCCESSFULL'
END as Result



SELECT IIF(TRY_PARSE('ABC' AS INT) IS NULL, 'CONVERSION FAIL','CONVERSION SUCCESSFULL')as Result
SELECT IIF(TRY_PARSE('99' AS INT) IS NULL, 'CONVERSION FAIL','CONVERSION SUCCESSFULL')as Result

SELECT PARSE('ABC' AS INT) AS RESULT -- OCCURED ERROR Error converting string value 'ABC' into data type int using culture
SELECT TRY_PARSE('ABC' AS INT) AS RESULT -- IF UNABLE TO CONVERT THEN SEMPLY RETURN NULL 

