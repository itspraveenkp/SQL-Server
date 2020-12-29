--Union Operator :- it returns all the unique rows from both the left and all the right query.
--union all includes the duplicates as well.

--INTERSECT Operator :- it retrives the common unique rows from both the left and the right query 

--Except Operator :- it returns unique rows from the left query that aren't in the right query's results

Use UAT

Select id,name,gender from TableA
union
Select id,name,gender from TableB


Select id,name,gender from TableA
Except
Select id,name,gender from TableB


Select id,name,gender from TableA
intersect 
Select id,name,gender from TableB