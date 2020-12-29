
USE UAT

CREATE TRIGGER tr_AuditTableChanges
ON All Server
for Create_Table,Alter_Table,Drop_Table
As
Begin
	Select EVENTDATA()
End

--For Delete Trigger
USE [master]
GO

DROP TRIGGER [tr_AuditTableChanges] ON ALL SERVER
GO


--create for example
create table mytable(id int, name nvarchar(250))

drop table mytable

<EVENT_INSTANCE>
  <EventType>CREATE_TABLE</EventType>
  <PostTime>2020-07-10T21:16:28.377</PostTime>
  <SPID>52</SPID>
  <ServerName>WLPC0L6M4E\SQLEXPRESS</ServerName>
  <LoginName>sa</LoginName>
  <UserName>dbo</UserName>
  <DatabaseName>UAT</DatabaseName>
  <SchemaName>dbo</SchemaName>
  <ObjectName>mytable</ObjectName>
  <ObjectType>TABLE</ObjectType>
  <TSQLCommand>
    <SetOptions ANSI_NULLS="ON" ANSI_NULL_DEFAULT="ON" ANSI_PADDING="ON" QUOTED_IDENTIFIER="ON" ENCRYPTED="FALSE" />
    <CommandText>create table mytable(id int, name nvarchar(250))
</CommandText>
  </TSQLCommand>
</EVENT_INSTANCE>


--this table will create automatically where you trying to create table
create table TableChanges
(
	DatabaseName nvarchar(250),
	TableName nvarchar(250),
	Event_Type nvarchar(250),
	LoginName nvarchar(250),
	SqlCommand nvarchar(250),
	AuditDatetime datetime
)



-- First Create trigger
CREATE TRIGGER tr_AudittableChanges
ON ALL SERVER
FOR CREATE_TABLE,ALTER_TABLE,DROP_TABLE
AS
	BEGIN
		DECLARE @EventData XML
		SELECT @EventData = EVENTDATA()

		INSERT INTO UAT.dbo.TableChanges
		(DatabaseName,TableName,Event_Type,LoginName,SqlCommand,AuditDatetime)
		VALUES
		(
			@EventData.value('(EVENT_INSTANCE/DatabaseName)[1]', 'varchar(250)'),
			@EventData.value('(EVENT_INSTANCE/ObjectName)[1]', 'varchar(250)'),
			@EventData.value('(EVENT_INSTANCE/EventType)[1]', 'nvarchar(250)'),
			@EventData.value('(EVENT_INSTANCE/LoginName)[1]', 'varchar(250)'),
			@EventData.value('(EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2500)'),
			GetDate()
		)

	END


--create for example
create table mytable(id int, name nvarchar(250))

drop table mytable

Select * from tablechanges