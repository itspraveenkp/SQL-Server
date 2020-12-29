USE UAT

CREATE SEQUENCE DBO.SEQUENCE
AS INT
START WITH 1
INCREMENT BY 1

SELECT NEXT VALUE FOR [DBO].[SEQUENCE] AS NEXTVALUES

SELECT * FROM SYS.sequences WHERE name='DBO.SEQUENCE'

ALTER SEQUENCE [DBO].[SEQUENCE] RESTART WITH 1

SELECT NEXT VALUE FOR [DBO].[SEQUENCE] AS NEXTVALUES

CREATE TABLE  SEQUENCE_Employees
(
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    Gender NVARCHAR(10)
)

INSERT INTO SEQUENCE_Employees VALUES(NEXT VALUE FOR [DBO].[SEQUENCE],'PRAVEEN','MALE' ),(NEXT VALUE FOR [DBO].[SEQUENCE],'SHIRIN','FEMALE')


SELECT * FROM SEQUENCE_Employees

CREATE SEQUENCE [dbo].[SequenceObject2] 
AS INT
START WITH 100
INCREMENT BY -1


SELECT NEXT VALUE FOR [dbo].[SequenceObject2] AS DECREMENTVALUE

--Specifying MIN and MAX values for the sequence : Use the MINVALUE and MAXVALUE arguments to 
--specify the MIN and MAX values respectively.

--STEP 1 CREATE SEQUENCE OBJECT
CREATE SEQUENCE [dbo].[SequenceObject3]

START WITH 100
INCREMENT BY 10
MINVALUE 100
MAXVALUE 150

--STEP 2 sELECT CREATE SEQUENCE OBJECT
SELECT NEXT VALUE FOR [dbo].[SequenceObject3] AS NEXTVALUE
			--Msg 11728, Level 16, State 1, Line 48
			--The sequence object 'SequenceObject3' has reached its minimum or maximum value. Restart the sequence object to allow new values to be generated.
		
ALTER SEQUENCE [dbo].[SequenceObject3]
INCREMENT BY 10
MINVALUE 100
MAXVALUE 150
CYCLE

SELECT NEXT VALUE FOR [dbo].[SequenceObject3] AS NEXTVALUE


CREATE SEQUENCE [dbo].[SequenceObject4]
AS INT
START WITH 1
INCREMENT BY 1
CACHE 10

SELECT NEXT VALUE FOR [dbo].[SequenceObject4] AS NEXTVALUE

ALTER SEQUENCE [dbo].[SequenceObject4] RESTART WITH 1

