USE [UAT]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetEmployeebyDepartmentid]    Script Date: 7/22/2020 7:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [dbo].[fn_GetEmployeebyDepartmentid](@Departmentid int)
returns table
As
return
	(
	Select * from tblEmployee 
	where DepartmentId = @Departmentid
	)