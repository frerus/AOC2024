DECLARE @BulkColumn VARCHAR(max)
SELECT @BulkColumn = REPLACE(BulkColumn, NCHAR(10),'|') FROM OPENROWSET (BULK 'C:\AOC2024\DAY01\input.txt', SINGLE_CLOB) I
;

WITH data AS (
SELECT
 CAST(PARSENAME(REPLACE(a.value, '   ', '.'), 2) AS INT) first_value
,ROW_NUMBER() OVER ( ORDER BY CAST(PARSENAME(REPLACE(a.value, '   ', '.'), 2) AS INT) ) first_rn
,CAST(PARSENAME(REPLACE(a.value, '   ', '.'), 1) AS INT) second_value
,ROW_NUMBER() OVER ( ORDER BY CAST(PARSENAME(REPLACE(a.value, '   ', '.'), 1) AS INT) ) second_rn
FROM STRING_SPLIT(@BulkColumn, '|') a
)

SELECT 
'pt1' as part, SUM(ABS(d1.first_value-d2.second_value)) answer
FROM data d1
	LEFT JOIN data d2 on d1.first_rn = d2.second_rn

UNION ALL

SELECT 'pt2' as part, SUM(CNT) answer
FROM (
	SELECT d1.second_value*COUNT(d2.first_value) cnt
	FROM data d1
		LEFT JOIN data d2 ON d1.second_value = d2.first_value
	GROUP BY d1.second_rn, d1.second_value
	) cnt
