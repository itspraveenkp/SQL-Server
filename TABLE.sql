
CREATE TABLE GENDER
(
	GENDER_ID INT IDENTITY PRIMARY KEY,
	GENDER_NAME VARCHAR(250)
)

INSERT INTO DBO.GENDER(GENDER_NAME) VALUES('MALE'),('FEMALE'),('OTHER'),(NULL)

SELECT * FROM DBO.GENDER 

ALTER TABLE TBL_EMPLOYEE
DROP CONSTRAINT FK__TBL_EMPLO__GENDE__76619304

ALTER TABLE TBL_CUSTOMER
DROP CONSTRAINT FK__TBL_CUSTO__GENDE__7C1A6C5A



--SET IDENTITY_INSERT DBO.TABLENAME ON
--INSERT INTO DBO.TABLENAME(COLUMN_NAME) VALUES(NULL)
--SET IDENTITY_INSERT DBO.TABLENAME OFF


CREATE TABLE TBL_CUSTOMER
(
	TBL_CUSTOMER_ID INT PRIMARY KEY,
	NAME NVARCHAR(250),
	EMAIL NVARCHAR(250),
	MOBILE NVARCHAR(250),
	AGE NVARCHAR(250) CONSTRAINT CK_TBL_CUSTOMER_AGE CHECK( AGE > 18 AND AGE < 40 ),
	GENDER INT FOREIGN KEY REFERENCES GENDER(GENDER_ID)
)

SELECT * FROM TBL_CUSTOMER

INSERT INTO DBO.TBL_CUSTOMER(TBL_CUSTOMER_ID,NAME,EMAIL,MOBILE,AGE,GENDER) VALUES(2,'SUNITA','S.NITA@GMAIL.COM','8898889247','23',2 )
INSERT INTO DBO.TBL_CUSTOMER(TBL_CUSTOMER_ID,NAME,EMAIL,MOBILE,AGE) VALUES(2,'SUNITA','S.NITA@GMAIL.COM','8898889247','37' )--WRONG BECAUSE I ADDED AGE ABOVE 35.



CREATE TABLE TBL_EMPLOYEE
(
	TBL_EMPLOYEE_ID INT PRIMARY KEY,
	NAME NVARCHAR(250),
	EMAIL NVARCHAR(250),
	MOBILE NVARCHAR(250),
	AGE NVARCHAR(250) CONSTRAINT CK_TBL_EMPLOYEE_AGE CHECK( AGE > 18 AND AGE < 40 ),
	GENDER INT FOREIGN KEY REFERENCES GENDER(GENDER_ID),
)

SELECT * FROM TBL_CUSTOMER

INSERT INTO DBO.TBL_EMPLOYEE(TBL_EMPLOYEE_ID,NAME,EMAIL,MOBILE,AGE,GENDER) VALUES(1,'AJAY','A.JAY@GMAIL.COM','756439247','25',1 )
INSERT INTO DBO.TBL_EMPLOYEE(TBL_EMPLOYEE_ID,NAME,EMAIL,MOBILE,AGE) VALUES(2,'AJAY','A.JAY@GMAIL.COM','756439247','40' ) --WRONG BECAUSE I ADDED AGE ABOVE 35. 


SELECT * FROM TBL_EMPLOYEE
SELECT * FROM TBL_CUSTOMER
SELECT * FROM GENDER

ALTER TABLE TBL_CUSTOMER
ADD CONSTRAINT CK_TBL_CUSTOMER_AGE CHECK(AGE > 0 AND AGE <35 )

ALTER TABLE TBL_EMPLOYEE
ADD CONSTRAINT CK_TBL_EMPLOYEE_AGE CHECK(AGE > 0 AND AGE <35 )

-- WE CAN DROP CONSTRAINT WITH HELP OF BELOW TABLE
ALTER TABLE TBL_CUSTOMER
DROP CONSTRAINT CK_TBL_CUSTOMER_AGE

ALTER TABLE TBL_EMPLOYEE
DROP CONSTRAINT CK_TBL_EMPLOYEE_AGE
