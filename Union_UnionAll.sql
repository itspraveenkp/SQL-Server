use UAT

Select * from tblindiaCustomers
union all
Select * from tblUKCustomers

Select * from tblindiaCustomers
union
Select * from tblUKCustomers

Select * from tblindiaCustomers i
join tblUKCustomers u
on i.Email = u .Email

