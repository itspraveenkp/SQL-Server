use UAT

CREATE TABLE [tblEmployee_]
(
 [Id] int Primary Key,
 [Name] nvarchar(50),
 [Salary] int,
 [Gender] nvarchar(10),
 [City] nvarchar(50)
)

execute sp_helpindex tblEmployee

nsert into tblEmployee Values(3,'John',4500,'Male','New York')
Insert into tblEmployee Values(1,'Sam',2500,'Male','London')
Insert into tblEmployee Values(4,'Sara',5500,'Female','Tokyo')
Insert into tblEmployee Values(5,'Todd',3100,'Male','Toronto')
Insert into tblEmployee Values(2,'Pam',6500,'Female','Sydney')

Select * from tblEmployee

Create Clustered Index IX_tblEmployee_Name
ON tblEmployee(Name)

Drop index tblEmployee.PK__tblEmplo__3214EC070A9D95DB

Create Clustered Index IX_tblEmployee_Gender_Salary
ON tblEmployee(Gender DESC, Salary ASC)

Create NonClustered Index IX_tblEmployee_Name
ON tblEmployee(Name)
