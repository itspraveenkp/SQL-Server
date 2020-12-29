Use UAT

SELECT Continent,Country,City,SUM(SaleAmount) AS TOTALSALES,
	   CAST(GROUPING (Continent) AS NVARCHAR(1)) +
	   CAST(GROUPING(Country)  AS NVARCHAR(1))+
	   CAST(GROUPING(City) AS NVARCHAR(1))  as Groupings
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)



SELECT Continent,Country,City,SUM(SaleAmount) AS TOTALSALES,
	   CAST(GROUPING (Continent) AS NVARCHAR(1)) +
	   CAST(GROUPING(Country)  AS NVARCHAR(1))+
	   CAST(GROUPING(City) AS NVARCHAR(1))  as Groupings,
	   GROUPING_ID(Continent,Country,City) AS GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


SELECT Continent,Country,City,SUM(SaleAmount) AS TOTALSALES,
	   GROUPING_ID(Continent,Country,City) AS GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)



SELECT Continent,Country,City,SUM(SaleAmount) AS TOTALSALES,
	   GROUPING_ID(Continent,Country,City) AS GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)
HAVING GROUPING_ID(Continent,Country,City) =3