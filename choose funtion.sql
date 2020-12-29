Use UAT

SELECT CHOOSE(1,'INDIA','UK','US') AS COUNTRYCOLUMN

Create table Employees_Choose
(
     Id int primary key identity,
     Name nvarchar(10),
     DateOfBirth date
)
Go

Insert into Employees_Choose values ('Mark', '01/11/1980')
Insert into Employees_Choose values ('John', '12/12/1981')
Insert into Employees_Choose values ('Amy', '11/21/1979')
Insert into Employees_Choose values ('Ben', '05/14/1978')
Insert into Employees_Choose values ('Sara', '03/17/1970')
Insert into Employees_Choose values ('David', '04/05/1978')
Go

SELECT NAME,DateOfBirth,
CASE DATEPART(MM, DateOfBirth)
	WHEN 1 THEN 'JAN'
	WHEN 2 THEN 'FAB'
	WHEN 3 THEN 'MAR'
	WHEN 4 THEN 'APR'
	WHEN 5 THEN 'MAY'
	WHEN 6 THEN 'JUN'
	WHEN 7 THEN 'JUL'
	WHEN 8 THEN 'AUG'
	WHEN 9 THEN 'SEP'
	WHEN 10 THEN 'OCT'
	WHEN 11 THEN 'NOV'
	WHEN 12 THEN 'DEC'
END AS MONTHS
FROM Employees_Choose


SELECT NAME,DATEOFBIRTH,
CHOOSE(DATEPART(MM,DateOfBirth),'JAN','FAB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC') AS MONTHS
FROM Employees_Choose