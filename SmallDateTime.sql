Insert into Employees ([SmallDateTime]) values ('01/01/1899')
Insert into Employees ([SmallDateTime]) values ('07/06/2079')

--When executed, the above queries fail with the following error
--The conversion of a varchar data type to a smalldatetime data type resulted in an out-of-range value

--The range for DateTime is January 1, 1753, through December 31, 9999. A value outside of this range, is not allowed.

--The following query has a value outside of the range of DateTime data type.
Insert into Employees ([DateTime]) values ('01/01/1752')

--When executed, the above query fails with the following error
--The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.