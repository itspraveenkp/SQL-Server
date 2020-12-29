Select * from tblEmployee

create procedure spGetTotalCount1
@Totalcount int output
As
Begin
	Select @Totalcount = COUNT(id) from tblEmployee
End

Declare @total int 
Execute spGetTotalCount1 @total output
print @total

Create procedure spGetTotalCount2
As
Begin
	return (Select count(ID) from tblEmployee)
End

 -- =, !=, <, <= , >, >= 

Declare @total int 
Execute @total = spGetTotalCount2
print @total


Create procedure spGetNameById
@id int,
@name nvarchar(50) output
As
Begin
	Select  @name = name from tblEmployee where  ID = @id
End 

Declare @name varchar(20)
Execute spGetNameById 5, @name output
print 'Name = ' + @name


create procedure spGetNameById2
@id int
As
Begin
	 return (Select Name from tblEmployee where ID = @id)
End

Declare @Name nvarchar(20)
Execute  @Name = spGetNameById2 1
print 'Name = ' + @name
