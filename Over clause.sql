Use UAT

Create Table Employee_s
(
     Id int primary key,
     Name nvarchar(50),
     Gender nvarchar(10),
     Salary int
)
Go

Insert Into Employee_s Values (1, 'Mark', 'Male', 5000)
Insert Into Employee_s Values (2, 'John', 'Male', 4500)
Insert Into Employee_s Values (3, 'Pam', 'Female', 5500)
Insert Into Employee_s Values (4, 'Sara', 'Female', 4000)
Insert Into Employee_s Values (5, 'Todd', 'Male', 3500)
Insert Into Employee_s Values (6, 'Mary', 'Female', 5000)
Insert Into Employee_s Values (7, 'Ben', 'Male', 6500)
Insert Into Employee_s Values (8, 'Jodi', 'Female', 7000)
Insert Into Employee_s Values (9, 'Tom', 'Male', 5500)
Insert Into Employee_s Values (10, 'Ron', 'Male', 5000)
Go

Select Gender, COUNT(*) as TotalGender, AVG(Salary) as AVGsal, MIN(Salary) as minsal, MAX(Salary) as maxsal
From Employee_s
Group by Gender


SELECT Name, Salary, Gender, COUNT(*) AS GenderTotal, AVG(Salary) AS AvgSal,
        MIN(Salary) AS MinSal, MAX(Salary) AS MaxSal
FROM Employee_s
GROUP BY Gender
--Column 'Employees.Name' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause

SELECT Name, Salary, Employees.Gender, Genders.GenderTotals,
        Genders.AvgSal, Genders.MinSal, Genders.MaxSal   
FROM Employees
INNER JOIN
(SELECT Gender, COUNT(*) AS GenderTotals,
          AVG(Salary) AS AvgSal,
         MIN(Salary) AS MinSal, MAX(Salary) AS MaxSal
FROM Employees
GROUP BY Gender) AS Genders
ON Genders.Gender = Employees.Gender

--Better way of doing this is by using the OVER clause combined with PARTITION BY
SELECT Name, Salary, Gender,
        COUNT(Gender) OVER(PARTITION BY Gender) AS GenderTotals,
        AVG(Salary) OVER(PARTITION BY Gender) AS AvgSal,
        MIN(Salary) OVER(PARTITION BY Gender) AS MinSal,
        MAX(Salary) OVER(PARTITION BY Gender) AS MaxSal
FROM Employees

---Example
Select Name,Salary,Gender,
		Count(Gender) over(Partition by Gender) As GenTotal,
		Avg(Salary) over(Partition by Gender) as AvgTotal,
		min(Salary) over(Partition by Gender) as minTotal,
		max(Salary) over(Partition by Gender) as maxTotal
From Employee_s