Select d.DepartmentName,E.Name,E.Salary,E.Gender  
from tblDepartment as D
inner join tblEmployee as E
on D.ID = E.DepartmentId

Select d.DepartmentName,E.Name,E.Salary,E.Gender  
from tblDepartment as D
Left join tblEmployee as E
on D.ID = E.DepartmentId

create function fn_GetEmployeebyDepartmentid
(@Departmentid int)
returns table
As
return
	(
	Select * from tblEmployee 
	where DepartmentId = @Departmentid
	)

Select * from fn_GetEmployeebyDepartmentid(1)

Select d.DepartmentName,E.Name,E.Salary,E.Gender  
from tblDepartment as D
Cross Apply fn_GetEmployeebyDepartmentid(d.ID) as E
--on D.ID = E.DepartmentId


Select d.DepartmentName,E.Name,E.Salary,E.Gender  
from tblDepartment as D
Outer Apply fn_GetEmployeebyDepartmentid(d.ID) as E
--on D.ID = E.DepartmentId
