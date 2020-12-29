
Declare @sql nvarchar(max)
Declare @gender nvarchar(10)
Set @gender = 'male'
set @sql = 'Select * from Employee_ where gender = @Gender'
Execute  sp_executesql @sql, N'@gender nvarchar(10)',@gender


Declare @sql nvarchar(max)
Declare @gender nvarchar(10)
Declare @count int
set @gender = 'Male'
set @sql = 'select @count= count(*) from Employee_ where gender = @gender'
execute sp_executesql @sql, N'@gender nvarchar(10),@count int output',
@gender, @count output
select @count output


Declare @sql nvarchar(max)
Declare @gender nvarchar(10)
Declare @count int
set @gender = 'Female'
set @sql = 'select @count= count(*) from Employee_ where gender = @gender'
execute sp_executesql @sql, N'@gender nvarchar(10),@count int output',
@gender, @count output
select @count output



Declare @sql nvarchar(max)
Declare @gender nvarchar(10)
Declare @count int
set @gender = 'Male'
Set @sql = 'Select @count = count(*) from Employee_ where Gender = @gender'
execute sp_executesql @sql, N'@gender nvarchar(10), @count int Output',
@gender,@count
select @count as columnname