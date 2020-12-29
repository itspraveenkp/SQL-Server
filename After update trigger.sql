USE UAT
CREATE TRIGGER TR_EMPLOYEE_FORUPDATE
ON TBLEMPLOYEE
FOR UPDATE
AS
 BEGIN
	SELECT * FROM inserted
	SELECT * FROM deleted
 END
 
 SELECT * FROM tblEmployee

 UPDATE tblEmployee SET Name='TODS', Salary = '25000',Gender = 'MALE' WHERE ID = 12

ALTER TRIGGER TR_EMPLOYEE_FORUPDATE
ON TBLEMPLOYEE
FOR UPDATE
AS
 BEGIN
	DECLARE @ID INT
	DECLARE @OLDNAME NVARCHAR(250), @NEWNAME NVARCHAR(250)
	DECLARE @OLDGENDER NVARCHAR(250), @NEWGENDER NVARCHAR(250)
	DECLARE @OLDSALARY NVARCHAR(250), @NEWSALARY NVARCHAR(250)
	DECLARE @OLDDEPAID NVARCHAR(250), @NEWDEPTID NVARCHAR(250)
	DECLARE @OLDMANID NVARCHAR(250), @NEWMANID NVARCHAR(250)

	DECLARE @AUDITSTRING NVARCHAR(250)

	SELECT * INTO #TEPTABLE FROM inserted

	WHILE(EXISTS(SELECT ID FROM #TEPTABLE))
		BEGIN
			SET @AUDITSTRING =''

			SELECT TOP 1 @ID = ID, @NEWNAME = NAME,@OLDGENDER = Gender,@NEWSALARY = Salary, @NEWDEPTID =DepartmentId,@NEWMANID = managerid 
			FROM #TEPTABLE

			SELECT @ID = ID, @OLDNAME = NAME,@OLDGENDER = Gender,@OLDSALARY = Salary, @OLDDEPAID =DepartmentId,@OLDMANID = managerid 
			FROM deleted WHERE ID = @ID

			SET @AUDITSTRING = 'EMPLOYEE WITH ID =' +CAST(@ID AS NVARCHAR(4)) + 'CHANGED'

			IF(@OLDNAME <> @NEWNAME)
				SET @AUDITSTRING = @AUDITSTRING + 'NAME FROM' + @OLDNAME + 'TO' + @NEWNAME
			IF(@OLDGENDER <> @NEWGENDER)
				SET @AUDITSTRING = @AUDITSTRING +'GENDER FROM' + @NEWGENDER + 'TO' + @NEWGENDER
			IF(@OLDSALARY <> @NEWSALARY)
				SET @AUDITSTRING = @AUDITSTRING + 'SALARY FROM' + @NEWSALARY + 'TO' + @NEWNAME
			IF(@OLDDEPAID <> @NEWDEPTID)
				SET @AUDITSTRING = @AUDITSTRING +'DEPARTMENT FROM'+ @NEWDEPTID + 'TO' + @NEWDEPTID
			IF(@OLDMANID <> @NEWMANID)
				SET @AUDITSTRING = @AUDITSTRING +'MAAGER ID FROM'+ @NEWMANID + 'TO' + @NEWMANID
			
			INSERT INTO TBLEMPLOYEEAUDIT VALUES(@AUDITSTRING)
			
			DELETE FROM #TEPTABLE WHERE ID= @ID
		END
	END