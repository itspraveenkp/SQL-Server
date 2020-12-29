Use UAT

SELECT Continent,Country,City,SUM(SaleAmount) AS TOTALSALES,
	   GROUPING(Continent) AS GP_CONTINENT,
	   GROUPING(Country) AS GP_COUNTRY,
	   GROUPING(City) AS GP_CITY
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


--CASE QUERY

SELECT 
CASE 
	WHEN GROUPING(Continent) = 1 THEN 'ALL' ELSE ISNULL(Continent,'UNKNOWN') END AS Continent,
CASE
	WHEN GROUPING(Country) = 1 THEN 'ALL' ELSE ISNULL(Country, 'UNKNOWN') END AS Country,
CASE
	WHEN GROUPING(City) = 1 THEN 'ALL' ELSE ISNULL(City,'UNKNOWN') END AS City,
SUM(SaleAmount) AS TOTALAMOUNT
FROM Sales
GROUP BY ROLLUP (Continent, Country, CITY)



SELECT ISNULL(Continent,'ALL') AS Continent,
	   ISNULL(Country,'ALL') AS Country,
	   ISNULL(City,'ALL') AS City,
	   SUM(SaleAmount) AS TOTALAMOUNT
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


SELECT ISNULL(Continent,'ALL') AS Continent,
	   ISNULL(Country,'ALL') AS Country,
	   ISNULL(City,'ALL') AS City,
	   SUM(SaleAmount) AS TOTALAMOUNT
FROM Sales
GROUP BY CUBE(Continent,Country,City)


SELECT ISNULL(Continent,'ALL') AS Continent,
	   ISNULL(Country,'ALL') AS Country,
	   ISNULL(City,'ALL') AS City,
	   SUM(SaleAmount) AS TOTALAMOUNT
FROM Sales
GROUP BY 
GROUPING SETS
	(
	(Continent,Country,City),
	(Continent,Country),
	(Continent),
	()
	)