Use UAT

Create Table Employees
(
     Id int primary key,
     Name nvarchar(50),
     Gender nvarchar(10),
     Salary int
)
Go

Insert Into Employees Values (1, 'Mark', 'Male', 6000)
Insert Into Employees Values (2, 'John', 'Male', 8000)
Insert Into Employees Values (3, 'Pam', 'Female', 4000)
Insert Into Employees Values (4, 'Sara', 'Female', 5000)
Insert Into Employees Values (5, 'Todd', 'Male', 3000)


Select Name,Salary,Gender,
ROW_NUMBER() over(order by salary desc) as rownumber,
rank() over(order by salary Desc) as rank_,
dense_rank() over (order by salary Desc) as _dense_rank
From Employees


-- So There is not diffrence becase of there in no available duplicate record so you must insert dublicate record

--Delete from Employees

Insert Into Employees Values (1, 'Mark', 'Male', 8000)
Insert Into Employees Values (2, 'John', 'Male', 8000)
Insert Into Employees Values (3, 'Pam', 'Female', 8000)
Insert Into Employees Values (4, 'Sara', 'Female', 4000)
Insert Into Employees Values (5, 'Todd', 'Male', 3500)



SELECT NAME,Salary,Gender,
ROW_NUMBER() OVER(ORDER BY SALARY) AS _ROW_NUMBER,
RANK() OVER(ORDER BY SALARY) AS _RANK,
DENSE_RANK() OVER (ORDER BY SALARY) AS _DENSE_RANK
FROM Employees



SELECT NAME,Salary,Gender,
ROW_NUMBER() OVER(ORDER BY SALARY DESC) AS _ROW_NUMBER,
RANK() OVER(ORDER BY SALARY DESC) AS _RANK,
DENSE_RANK() OVER (ORDER BY SALARY DESC) AS _DENSE_RANK
FROM Employees


---USING PARTITION BY 

SELECT NAME,Salary,Gender,
ROW_NUMBER() OVER(PARTITION BY GENDER ORDER BY SALARY) AS _ROW_NUMBER,
RANK() OVER(PARTITION BY GENDER ORDER BY SALARY) AS _RANK,
DENSE_RANK() OVER (PARTITION BY GENDER ORDER BY SALARY) AS _DENSE_RANK
FROM Employees


