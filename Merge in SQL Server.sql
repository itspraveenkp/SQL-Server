
Use UAT
Create table StudentSource
(
     ID int primary key,
     Name nvarchar(20)
)
GO

Insert into StudentSource values (1, 'Mike')
Insert into StudentSource values (2, 'Sara')
GO

Create table StudentTarget
(
     ID int primary key,
     Name nvarchar(20)
)
GO

Insert into StudentTarget values (1, 'Mike M')
Insert into StudentTarget values (3, 'John')
GO

SELECT * FROM  StudentTarget
SELECT * FROM  StudentSource

MERGE STUDENTTARGET AS T
USING STUDENTSOURCE AS S
ON T.ID = S.ID
WHEN MATCHED THEN
	UPDATE SET T.NAME = S.NAME
WHEN NOT MATCHED BY TARGET THEN 
	INSERT (ID, NAME) VALUES(S.ID,S.NAME)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;