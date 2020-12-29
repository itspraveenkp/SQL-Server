Use UAT

ALTER TABLE TABLEB
ADD GENDER VARCHAR(50)

INSERT INTO TableA VALUES('MARY','FEMALE')
INSERT INTO TableA VALUES('STEVE','MALE')
INSERT INTO TableA VALUES('MARY','FEMALE')
INSERT INTO TableA VALUES('PAM','FEMALE')


INSERT INTO TableB VALUES('MARY','FEMALE')
INSERT INTO TableB VALUES('STEVE','MALE')

SELECT * FROM TableA
SELECT * FROM TableB


select id,name,gender from TableA
intersect
select id,name,gender from TableB

select TableA.id,TableA.name,TableA.gender from TableA
inner join TableB
on TableA.Id = TableB.Id



