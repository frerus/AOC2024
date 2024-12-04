DECLARE @BulkColumn VARCHAR(max)
SELECT @BulkColumn = REPLACE(BulkColumn, NCHAR(10),'|') FROM OPENROWSET (BULK 'C:\AOC2024\DAY04\input.txt', SINGLE_CLOB) I
;

with prep as (
SELECT
ROW_NUMBER() OVER (PARTITION BY a.value ORDER BY 1/0) x
,a.ordinal y
,SUBSTRING(a.value,b.value,1) val
,a.value complete
FROM STRING_SPLIT(@BulkColumn, '|',1) a
	CROSS APPLY GENERATE_SERIES(1,CAST(LEN(a.value) AS INT)) b
)

--pt1

,all_strings as (
SELECT x ,STRING_AGG(SUBSTRING(complete,1-x+y,1),'') WITHIN GROUP ( ORDER BY y )  string FROM prep GROUP BY x UNION ALL
SELECT x ,STRING_AGG(SUBSTRING(complete,x-y,1),'') WITHIN GROUP ( ORDER BY y )  string FROM prep GROUP BY x UNION ALL
SELECT x ,STRING_AGG(SUBSTRING(REVERSE(complete),1-x+y,1),'') WITHIN GROUP ( ORDER BY y )  string FROM prep GROUP BY x UNION ALL
SELECT x ,STRING_AGG(SUBSTRING(REVERSE(complete),x-y,1),'') WITHIN GROUP ( ORDER BY y )  string FROM prep GROUP BY x UNION ALL
SELECT x ,STRING_AGG(SUBSTRING(complete,x,1),'') WITHIN GROUP ( ORDER BY y )  string FROM prep GROUP BY x UNION ALL
SELECT DISTINCT '1' as x,  complete FROM prep
)

SELECT
SUM(a)+SUM(b)
FROM(
select 
string
,ABS(1-(SELECT COUNT(Value) FROM string_split(REPLACE(a.string,'XMAS','|'),'|')) ) a
,ABS(1-(SELECT COUNT(Value) FROM string_split(REPLACE(a.string,'SAMX','|'),'|')) ) b
from all_strings a
) x

--pt2

UNION ALL

SELECT COUNT(1) FROM (
select a.x,a.y,a.val
from prep a
	left join prep tl on a.x = tl.x-1 and a.y = tl.y-1
	left join prep tr on a.x = tr.x+1 and a.y = tr.y-1
	left join prep bl on a.x = bl.x-1 and a.y = bl.y+1
	left join prep br on a.x = br.x+1 and a.y = br.y+1
where 1=1
AND a.val = 'A'
AND (
	  (tl.val = 'M' and br.val = 'S' AND tr.val = 'M' and bl.val = 'S')
	  OR (tl.val = 'S' and br.val = 'M' AND tr.val = 'S' and bl.val = 'M')
	  OR (tl.val = 'M' and br.val = 'S' AND tr.val = 'S' and bl.val = 'M')
	  OR (tl.val = 'S' and br.val = 'M' AND tr.val = 'M' and bl.val = 'S')
	  ) 
) x

