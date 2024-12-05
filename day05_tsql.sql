DECLARE @BulkColumn VARCHAR(max)
SELECT @BulkColumn = REPLACE(BulkColumn, NCHAR(10),':') FROM OPENROWSET (BULK 'C:\AOC2024\DAY05\input.txt', SINGLE_CLOB) I
;
DROP TABLE IF EXISTS #rules;
SELECT
LEFT(a.value,2) first, RIGHT(a.value,2) second, a.value total
INTO #rules
FROM STRING_SPLIT(@BulkColumn, ':',1) a
WHERE a.value like '%|%'

DROP TABLE IF EXISTS #update_page_numbers;
SELECT
a.ordinal update_no, a.value update_page_numbers
INTO #update_page_numbers
FROM STRING_SPLIT(@BulkColumn, ':',1) a
WHERE a.value like '%,%'

DROP TABLE IF EXISTS #pt1;
SELECT 
 n.update_no, n.update_page_numbers
,CAST(SUBSTRING(n.update_page_numbers,LEN(n.update_page_numbers)/2,2) AS INT) mid
,MAX(IIF(CHARINDEX(r.first,n.update_page_numbers)>CHARINDEX(r.second,n.update_page_numbers),1,0)) activate
INTO #pt1
FROM #update_page_numbers n	LEFT JOIN #rules r ON n.update_page_numbers like '%'+r.first+'%' AND n.update_page_numbers like '%'+r.second+'%'  
GROUP BY n.update_no, n.update_page_numbers

DROP TABLE IF EXISTS #pt2;
SELECT 
update_no, update_page_numbers, r.first, r.second
,COUNT(1) OVER ( PARTITION BY update_no, first ) cnt
INTO #pt2
FROM #pt1 n	left join #rules r on n.update_page_numbers like '%'+r.first+'%' and n.update_page_numbers like '%'+r.second+'%'  
WHERE activate = 1

SELECT 'pt1' as part, sum(mid) as answer
FROM #pt1
WHERE activate = 0

UNION ALL

SELECT 'pt2' as part, sum(mid) as answer
FROM
  (SELECT update_no, CAST(SUBSTRING(val, LEN(val)/2, 2) AS INT) mid FROM
     (SELECT update_no, string_agg(FIRST, ',') within GROUP (ORDER BY cnt DESC) val FROM
        (SELECT update_no, first, cnt
         FROM #pt2
         GROUP BY update_no, first, cnt
         UNION ALL SELECT update_no, SECOND, 0
         FROM #pt2
         WHERE cnt = 1) x
      GROUP BY update_no) x) x



