Select * from sysobjects where type = 'u'
Select * from sysobjects where xtype = 'U'--table
Select * from sysobjects where xtype = 'fn'--function 
Select * from sysobjects where xtype = 'p'--store procedure
Select * from sysobjects where xtype = 'v' --views

select distinct xtype from sysobjects

select * from sys.tables
select * from sys.views
select * from sys.procedures

select * from INFORMATION_SCHEMA.TABLES
select * from INFORMATION_SCHEMA.views
select * from INFORMATION_SCHEMA.ROUTINES




