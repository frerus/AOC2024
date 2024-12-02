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

,p2_data as(
SELECT 
d1.grp
,d2.rn sub_grp
,CAST(d1.value as int)-LAG(CAST(d1.value as INT)) OVER ( PARTITION BY d1.grp, d2.rn ORDER BY d1.grp ) diff
FROM data d1
	LEFT JOIN data d2
		ON d1.grp = d2.grp
WHERE d1.rn <> d2.rn
)

SELECT 
'pt1' as part, COUNT(DISTINCT grp) as answer FROM
(
	select 
	grp
	,COUNT( CASE WHEN diff >= 1 AND diff <= 3 THEN 1 END) cnt1
	,COUNT( CASE WHEN diff <= -1 AND diff >= -3 THEN 1 END) cnt2
	,COUNT( diff ) as cnt
	from data
	where grp <> ''
	group by grp
) x
WHERE cnt1 = cnt OR cnt2 = cnt

UNION ALL

SELECT 
'pt2' as part, COUNT(DISTINCT grp) as answer
FROM (
	SELECT 
	grp
	,sub_grp
	,COUNT(CASE WHEN diff >= 1 AND diff <= 3 THEN 1 END) cnt1
	,COUNT(CASE WHEN diff <= -1 AND diff >= -3 THEN 1 END) cnt2
	,COUNT(diff ) as cnt
	FROM p2_data
	GROUP BY grp, sub_grp
	) d
WHERE 
cnt1 = cnt OR cnt2 = cnt
