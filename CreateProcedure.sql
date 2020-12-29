Create database Sample

use sample

Create table users
(
	id int identity(1,1),
	Firstname nvarchar(250),
	Lastname nvarchar(250),
	Email nvarchar(250)
)

create procedure spinsertuser
@Firstname nvarchar(250),
@Lastname nvarchar(250),
@Email nvarchar(250)
As
Begin
	insert into users values(@Firstname,@Lastname,@Email)
End

Select * from users