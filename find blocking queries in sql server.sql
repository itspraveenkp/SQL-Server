Use UAT
Begin Tran
update TableA set Name ='mark transaction 1' where Id = 1

commit

-- Second Tab
select count(*) from TableA

delete from TableA where Id = 1
truncate table TableA
Drop table TableA

DBCC opentran