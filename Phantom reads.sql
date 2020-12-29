--select * from tbl_test

--insert into tbl_test values(1,'Prakeem'),(2,'saleem')


--Transaction 1
Begin transaction

select * from tbl_test
where id between 1 and 3

-- Do some work
waitfor delay '00:00:10'

select * from tbl_test where id between 1 and 3
commit transaction

-- Transaction 1
Set transaction isolation level serializable
Begin Transaction
Select * from tbl_test where Id between 1 and 3
-- Do Some work
waitfor delay '00:00:10'
Select * from tbl_test where Id between 1 and 3
Commit Transaction


--Transaction 2
insert into tbl_test values(3,'marcus'),(4,'mark')