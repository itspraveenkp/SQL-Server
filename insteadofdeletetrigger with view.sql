CREATE TABLE tblEmployeess
(
  Id int Primary Key,
  Name nvarchar(30),
  Gender nvarchar(10),
  DepartmentId int
)

CREATE TABLE tblDepartments
(
 DeptId int Primary Key,
 DeptName nvarchar(20)
)

Insert into tblDepartments values (1,'IT')
Insert into tblDepartments values (2,'Payroll')
Insert into tblDepartments values (3,'HR')
Insert into tblDepartments values (4,'Admin')

Insert into tblEmployeess values (1,'John', 'Male', 3)
Insert into tblEmployeess values (2,'Mike', 'Male', 2)
Insert into tblEmployeess values (3,'Pam', 'Female', 1)
Insert into tblEmployeess values (4,'Todd', 'Male', 4)
Insert into tblEmployeess values (5,'Sara', 'Female', 1)
Insert into tblEmployeess values (6,'Ben', 'Male', 3)


create view vwEmployeessDetails
as
  select Id,Name,Gender,d.DeptName from tblEmployeess as e
  join tblDepartments as d
  on d.DeptId = e.DepartmentId

  select * from vwEmployeessDetails
  --error : View or function 'vwEmployeessDetails' is not updatable because the modification affects multiple base tables.
  delete from vwEmployeessDetails where id = '1'

  delete from tblEmployeess where id = '1'
  select * from tblEmployeess where id = '1'

  create trigger tr_vwEmployeessDetails
  on tblEmployeess
  instead of delete
  as
  begin 
	delete tblEmployeess
	from tblEmployeess
	join deleted
	on tblEmployeess.Id = deleted.Id
  end


