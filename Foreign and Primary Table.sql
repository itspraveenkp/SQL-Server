CREATE TABLE [dbo].[Employee](
	[empid] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](250) NULL,
	[LastName] [nvarchar](250) NULL,
	[Email] [nvarchar](250) NULL,
	[HireDate] [datetime] NULL,
	[LocationsID] [int] foreign key references Location(LocationID) NULL,
	[Managersid] [int] foreign key references Manager(ManagerID) NULL,
	[StatussID] [int] foreign key references StatusRrt(StatusID) NULL,
	[HiredofSet] [datetime] NULL,
)
CREATE TABLE [dbo].[Location](
	[LocationID] [int] identity primary key NOT NULL,
	[LocationName] [nvarchar](250) NULL,
)

ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([LocationsID])
REFERENCES [dbo].[Location] ([LocationID])
GO

CREATE TABLE [dbo].[Manager](
	[ManagerID] [int] identity primary key NOT NULL,
	[ManagerName] [nvarchar](250) NULL,
)

ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([Managersid])
REFERENCES [dbo].[Manager] ([ManagerID])
GO

CREATE TABLE [dbo].[StatusRrt](
	[StatusID] [int] identity primary key NOT NULL,
	[Active] [nvarchar](250) NULL,
	[Deactive] [nvarchar](250) NULL,
)

ALTER TABLE [dbo].[Employee]  WITH CHECK ADD FOREIGN KEY([StatussID])
REFERENCES [dbo].[StatusRrt] ([StatusID])
GO


ALTER TABLE [dbo].[StatusRrt]
DROP CONSTRAINT PK__StatusRr__C8EE204351F6650F


CREATE TABLE [dbo].[EmployeeHistory](
	[empid] [int] NULL,
	[FirstName] [nvarchar](250) NULL,
	[LastName] [nvarchar](250) NULL,
	[Email] [nvarchar](250) NULL,
	[HireDate] [datetime] NULL,
	[LocationsID] [int] NULL,
	[Managersid] [int] NULL,
	[StatussID] [int] NULL,
	[HiredofSet] [datetime] NULL
)

