create table tblEmployee
(
	id int identity(1,1),
	Name varchar(250),
	Gender varchar(250),
	Salary varchar(250),
	City varchar(250)
)

insert into tblEmployee(Name,Gender,Salary,City) values('Ankit','Male','20000','Landon')
insert into tblEmployee(Name,Gender,Salary,City) values('Amit','Male','50000','Landon')
insert into tblEmployee(Name,Gender,Salary,City) values('Rajan','Male','60000','Banglore')
insert into tblEmployee(Name,Gender,Salary,City) values('Shiva','Male','45000','Allahabad')
insert into tblEmployee(Name,Gender,Salary,City) values('Kajol','Female','67000','Pune')
insert into tblEmployee(Name,Gender,Salary,City) values('Sanjana','Female','23000','Chenai')
insert into tblEmployee(Name,Gender,Salary,City) values('Surya','Female','45000','Mumbai')
insert into tblEmployee(Name,Gender,Salary,City) values('Suman','Female','40000','Mumbai')

Select * from tblEmployee

Select min(salary), max(Salary) from tblEmployee

Select AVG(convert(int,Salary)) from tblEmployee

Select sum(convert(int,salary)) from tblEmployee

Select sum(convert(int, salary)) as sumsalary, AVG(convert(int, salary)) as avgsalary from tblEmployee

Select sum(convert(int,salary)) from tblEmployee
group by Salary


Select Gender from tblEmployee
where Gender ='female'


Select  Name,Gender from tblEmployee
where Name ='suman'
group by Gender,Name
having Gender='Female'

