DECLARE @BulkColumn VARCHAR(max)
SELECT @BulkColumn = REPLACE(BulkColumn, NCHAR(10),'|') FROM OPENROWSET (BULK 'C:\AOC2024\DAY02\input.txt', SINGLE_CLOB) I
;

WITH data as (

SELECT
a.value grp
,b.value value
,LAG(b.value) OVER ( PARTITION BY a.value ORDER BY a.value ) lagg
,ROW_NUMBER() OVER ( PARTITION BY a.value  ORDER BY a.value ) rn
,CAST(b.value as int)-LAG(CAST(b.value as INT)) OVER ( PARTITION BY a.value ORDER BY a.value ) diff
FROM STRING_SPLIT(@BulkColumn, '|') a
	CROSS APPLY STRING_SPLIT(a.value, ' ') b 
)

,exploded as (
SELECT 
d1.grp
,d2.rn sub_grp
,d1.diff pt1_diff
,CAST(d1.value as int)-LAG(CAST(d1.value as INT)) OVER ( PARTITION BY d1.grp, d2.rn ORDER BY d1.grp ) pt2_diff
FROM data d1
	LEFT JOIN data d2
		ON d1.grp = d2.grp
WHERE d1.rn <> d2.rn
)

SELECT
COUNT(DISTINCT (CASE WHEN pt1_pos = pt1_cnt OR pt1_neg = pt1_cnt THEN grp END)) pt1
,COUNT(DISTINCT (CASE WHEN pt2_pos = pt2_cnt OR pt2_neg = pt2_cnt THEN grp END)) pt2
FROM (
	SELECT 
	grp
	,sub_grp
	,MAX(COUNT(pt1_diff)) OVER (PARTITION BY grp) pt1_cnt
	,COUNT(pt2_diff) as pt2_cnt
	,COUNT(CASE WHEN pt1_diff >= 1  AND pt1_diff <= 3	THEN 1 END	) pt1_pos
	,COUNT(CASE WHEN pt1_diff <= -1 AND pt1_diff >= -3	THEN 1 END	) pt1_neg
	,COUNT(CASE WHEN pt2_diff >= 1  AND pt2_diff <= 3	THEN 1 END	) pt2_pos
	,COUNT(CASE WHEN pt2_diff <= -1 AND pt2_diff >= -3	THEN 1 END	) pt2_neg
	from exploded
	group by grp,sub_grp
	) x