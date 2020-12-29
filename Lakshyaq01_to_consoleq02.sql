
EXEC master.dbo.sp_addlinkedserver @server = N’RDSPrivate‘, @srvproduct=N”, @provider=N’SQLNCLI’, @datasrc=N’10.0.4.236′;


EXEC master.dbo.sp_addlinkedserver @server = N'Test_LinkedtoRDS', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'jjincdconsoleq02.cou9r6xulyai.ap-southeast-1.rds.amazonaws.com';

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'Test_LinkedtoRDS',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqlsa',@rmtpassword='7#bJe-7cS!u5';

Select * from Test_LinkedConsoletoRDS.db_Test.dbo.tbl_test 
insert into Test_LinkedConsoletoRDS.db_Test.dbo.tbl_test(TestName) values('D'),('X'),('Z') 

USE [LAKSHYA]
GO
DECLARE	@return_value int
EXEC	@return_value = [cdgmaster].[test_linkedsrv_sp]
SELECT	'Return Value' = @return_value
GO 