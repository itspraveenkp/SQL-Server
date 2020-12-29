use UAT
--delete from employees where month =  MONTH(GETDATE()) and year = YEAR(GETDATE()) ;

select * from Employees where  month(HireDate) = '4' and YEAR(HireDate) = '2014'

select * from Employees where MONTH(HireDate) = month(getdate()) and year(HireDate) = year(getdate()) and Gender = 'male'
Delete from Employees where MONTH(HireDate) = month(getdate()) and year(HireDate) = year(getdate()) and Gender = 'male'

create view vw_Employeecount
as
	select d.DepartmentName,d.DepartmentHead,count(*) as count from Employees as e
	join tblDepartment as d
	on e.ID = d.ID
	group by d.DepartmentHead,d.DepartmentName
 
select * from vw_Employeecount where count >=2

select DepartmentId,DeptName,count(*) as totalEmployees
into #temptable
from tblEmployee 
join tblDepartments
on tblEmployee.DepartmentId = tblDepartments.DeptId
group by DepartmentId,DeptName

select * from #temptable
where totalEmployees >= 2


--using table varible 
DECLARE @TBLEMPLOYEECOUNT TABLE 
(
	DEPTNAME NVARCHAR(20),
	DEPARTMENTID INT,
	TOTALEMPLOYEES INT 
)

INSERT @TBLEMPLOYEECOUNT
SELECT D.DepartmentName,E.DepartmentId, COUNT(*) AS TOTALEMPLOYEECOUNT FROM tblEmployee AS E
JOIN tblDepartment AS D
ON D.ID = E.DepartmentId
GROUP BY D.DepartmentName,E.DepartmentId

SELECT * FROM @TBLEMPLOYEECOUNT

SELECT DepartmentName,DepartmentId AS TOTALEMPLOYEE FROM 
(
	SELECT D.DepartmentName,E.DepartmentId, COUNT(*) AS TOTALEMPLOYEECOUNT FROM tblEmployee AS E
	JOIN tblDepartment AS D
	ON E.DepartmentId = D.ID
	GROUP BY E.DepartmentId,D.DepartmentName
) AS EMPLOYEE

