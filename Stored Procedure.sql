use DBtest
create proc spTest
As
Begin 
	Select * from customer(nolock)
End

Alter procedure Sp_testing 3  
@StoreParameter int
As 
Beg	in
	Select * from customer where customer_id = @StoreParameter
End

--sp_helptext Sp_testing

