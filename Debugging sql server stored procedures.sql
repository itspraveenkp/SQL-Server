Alter Procedure spPrintEvenNumbers
@Target int
As
Begin
	Declare @StartNumber int
	Set @StartNumber = 1

	While(@StartNumber < @Target)
	Begin
		if(@StartNumber%2 = 0)
		Begin
			Print @StartNumber
		End
		Set @StartNumber = @StartNumber + 1
	End
	Print 'Finish Printting even Numers till ' + RTRIM(@Target)
End


Declare @TargetNumner int
Set @TargetNumner = 10 
Execute spPrintEvenNumbers @TargetNumner
print 'Done'


--------------------------------------------------------------

Declare @TargetNumner int
Set @TargetNumner = 10 
Execute spPrintEvenNumbers @TargetNumner
print 'Done'



