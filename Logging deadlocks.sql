DBCC Traceon(1222, -1)

--To check the status of the trace flag
DBCC TraceStatus(1222, -1)

--To turn off the trace flag
DBCC Traceoff(1222, -1)


--SQL script to create the tables and populate them with test data
Create table TableA
(
    Id int identity primary key,
    Name nvarchar(50)
)
Go

Insert into TableA values ('Mark')
Go

Create table TableB
(
    Id int identity primary key,
    Name nvarchar(50)
)
Go

Insert into TableB values ('Mary')
Go

--SQL Script to create stored procedures
Create procedure spTransaction1
as
Begin
    Begin Tran
    Update TableA Set Name = 'Mark Transaction 1' where Id = 1
    Waitfor delay '00:00:05'
    Update TableB Set Name = 'Mary Transaction 1' where Id = 1
    Commit Transaction
End

Create procedure spTransaction2
as
Begin
    Begin Tran
    Update TableB Set Name = 'Mark Transaction 2' where Id = 1
    Waitfor delay '00:00:05'
    Update TableA Set Name = 'Mary Transaction 2' where Id = 1
    Commit Transaction
End



--To read the error log
execute sp_readerrorlog