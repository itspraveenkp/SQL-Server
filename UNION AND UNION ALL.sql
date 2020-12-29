Use UAT

CREATE TABLE tblindiaCustomers
(
	ID int identity(1,1),
	Name varchar(250),
	Email varchar(250)
)

CREATE TABLE tblUKCustomers
(
	ID int identity(1,1),
	Name varchar(250),
	Email varchar(250)
)

INSERT INTO tblindiaCustomers(NAME,Email) VALUES('raj','r@r.com'),('sam','s@s.com')
INSERT INTO tblUKCustomers(NAME,Email) VALUES('Ben','b@b.com'),('sam','s@s.com')

SELECT * FROM tblindiaCustomers
SELECT * FROM tblUKCustomers

SELECT ID,Name,Email FROM tblindiaCustomers 
UNION ALL
SELECT ID,Name,Email FROM tblUKCustomers


SELECT ID,Name,Email FROM tblindiaCustomers
UNION 
SELECT ID,Name,Email FROM tblUKCustomers

SELECT * FROM tblindiaCustomers
UNION 
SELECT * FROM tblUKCustomers
ORDER BY Name
