use UAT

Select * from tblEmployee

create proc spGetEmployee
As
Begin
	Select * from tblEmployee
End

------------------------------------------------

Alter proc spGetEmployee
As
Begin
	Select * from tblEmployee
	order by Name
End


-----------------------------------------InPut Type Store procedure----------------------

create procedure spGetEmployeeByGenderandDepartment
@Gender varchar(250),
@DepartmentID int
As
Begin
	Select * from tblEmployee 
	where @Gender = Gender and @DepartmentID = DepartmentId
End

spGetEmployeeByGenderandDepartment 'Male',1
