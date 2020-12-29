--Example queries for getting the last generated identity value

--use DBtest

create table test1
(
id int identity(1,1),
Name varchar(250)
)

create table test2
(
id int identity(1,1),
Name varchar(250)
)

insert into test1(Name) values('ABC')
insert into test2(Name) values('XYZ')

create trigger tgrtest1insert on test1 
after insert
As
Begin
		insert into test2(name) values('www')
End

Select SCOPE_IDENTITY()
Select @@IDENTITY
Select IDENT_CURRENT('test2')

select * from test1
select * from test2