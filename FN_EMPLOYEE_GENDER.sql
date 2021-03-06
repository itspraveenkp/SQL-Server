USE [UAT]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_EMPLOYEE_GENDER]    Script Date: 7/22/2020 7:13:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[FN_EMPLOYEE_GENDER](@GENDER VARCHAR(50))
RETURNS TABLE
AS
RETURN (SELECT Name,Gender,Salary,DepartmentId
		FROM tblEmployee
		WHERE Gender = @GENDER)
