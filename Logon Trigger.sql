USE UAT
SELECT * FROM sys.dm_exec_sessions ORDER BY login_time DESC

SELECT is_user_process,original_login_name, * 
FROM sys.dm_exec_sessions ORDER BY login_time DESC

CREATE TRIGGER tr_AuditLogin
ON ALL Server
FOR LOGON
AS
	BEGIN
		DECLARE @LoginName nvarchar(100)
		Set @LoginName = ORIGINAL_LOGIN()

		IF(SELECT COUNT(*) FROM SYS.dm_exec_sessions
		WHERE is_user_process = 1 AND
		original_login_name = @LoginName) > 3

		BEGIN
			PRINT'Fourth connection attempt by ' + @LoginName + ' blocked'
			ROLLBACK;
		END
	END

--For check where the print error 
Execute sp_readerrorlog