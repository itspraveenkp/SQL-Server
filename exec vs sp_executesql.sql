
Declare @FN nvarchar(50)
Set @FN = 'John'
Declare @sql nvarchar(max)
Set @sql = 'Select * from Employees where FirstName = ''' +  @FN + ''''
Exec(@sql)

--If we set @FN parameter to something like below, it drops SalesDB database

Declare @FN nvarchar(50)
Set @FN = ''' Drop Database SalesDB --'''
Declare @sql nvarchar(max)
Set @sql = 'Select * from Employees where FirstName = ''' + @FN + ''''
Exec(@sql)

--However, we can prevent SQL injection using the QUOTENAME() function as shown below.

Declare @FN nvarchar(50)
Set @FN = ''' Drop Database SalesDB --'''
Declare @sql nvarchar(max)
Set @sql = 'Select * from Employees where FirstName = ' + QUOTENAME(@FN,'''')
--Print @sql
Exec(@sql)


Declare @FN nvarchar(50)
Set @FN = 'John'
Declare @sql nvarchar(max)
Set @sql = 'Select * from Employees where FirstName = ' + QUOTENAME(@FN,'''')
Print @sql

--When the above query is executed the following is the query printed
Select * from Employees where FirstName = 'John'


--Execute the following query. Notice we have set @FN='Mary'
Declare @FN nvarchar(50)
Set @FN = 'Mary'
Declare @sql nvarchar(max)
Set @sql = 'Select * from Employees where FirstName = ' + QUOTENAME(@FN,'''')
Exec(@sql)

--Execute the following query to retrieve what we have in the query plan cache
SELECT cp.usecounts, cp.cacheobjtype, cp.objtype, st.text, qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY cp.usecounts DESC


DBCC FREEPROCCACHE