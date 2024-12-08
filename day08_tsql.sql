DECLARE @BulkColumn VARCHAR(max)
SELECT @BulkColumn = REPLACE(BulkColumn, NCHAR(10),'|') FROM OPENROWSET (BULK 'C:\AOC2024\DAY08\input.txt', SINGLE_CLOB) I
;
DROP TABLE IF EXISTS #data;
SELECT
a.ordinal y
,b.value x 
,SUBSTRING(a.value, b.value,1) COLLATE Latin1_General_100_CS_AS_SC_UTF8 as value
INTO #data
FROM STRING_SPLIT(@BulkColumn,'|',1) a
	CROSS APPLY GENERATE_SERIES(1, CAST(LEN(a.value) AS INT) ) b
WHERE a.value <> '';

DECLARE @y_max INT 
DECLARE @x_max INT 
SELECT @y_max = MAX(y), @x_max = MAX(x) FROM #data;

WITH recursion AS (
SELECT 
ab.x, ab.y, ab.x-a.x as x_diff, ab.y-a.y as y_diff, 0 as lvl
FROM (SELECT value,y,x FROM #data WHERE value <> '.') a
	INNER JOIN (SELECT value,y,x FROM #data WHERE value <> '.') ab
		ON a.value = ab.value
WHERE a.x <> ab.x AND a.y <> ab.y
UNION ALL
SELECT 
x+x_diff, y+y_diff, x_diff, y_diff, lvl+1
FROM recursion
WHERE
	x+x_diff >=1 AND x+x_diff <= @x_max
	AND y+y_diff >= 1 AND y+y_diff <= @y_max)

SELECT 'pt1' as part, COUNT(DISTINCT CAST(x AS VARCHAR(10))+'.'+CAST(y AS VARCHAR(10))) as answer
FROM recursion
WHERE lvl = 1
UNION ALL
SELECT 'pt2' as part, COUNT(DISTINCT CAST(x AS VARCHAR(10))+'.'+CAST(y AS VARCHAR(10))) as answer  
FROM recursion

