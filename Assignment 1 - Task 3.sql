-- Task #3
-- First, look at the tables: (nice datatable naming btw)
SELECT * FROM instown.file1 LIMIT 50;	-- institutional investors info list
SELECT * FROM instown.file2 LIMIT 50;	-- stocks info list
SELECT * FROM instown.file3 LIMIT 50;	-- stock balances
SELECT * FROM instown.file4 LIMIT 50;	-- monthly changes in stock balances 

-- Q1: The largest institutional owner of Chipotle Mexican Grill as of the end of 2017
SELECT 
	a.fdate,
	a.cusip,
	a.mgrno,
	b.mgrname,
	a.shares AS `Chipotle shares held`
FROM 
	instown.file3 AS a
		INNER JOIN instown.file1 AS b	-- joining the file1 to look for the name of the institutional name
	ON 
		a.fdate = b.fdate AND 
		a.mgrno = b.mgrno
WHERE 
	a.fdate = 20171231 AND 
	a.cusip IN 
	(	-- this is to find the cusip for Chipotle (16965610) from file2
		SELECT 
			DISTINCT(cusip) 
		FROM instown.file2
		WHERE 
			stkname LIKE '%Chipotle%' AND 
			fdate = 20171231
	)
GROUP BY a.mgrno	-- to drop duplicated and identical rows in the query
ORDER BY a.shares DESC
LIMIT 10;
-- Ans: Pershing Square Cap Mgmt, L.

-- Q2: The 13-F investor with the highest portfolio percentage in Chipotle as of the end of 2017
SELECT 
	t.mgrno,
	t.mgrname,
	t.`Chipotle shares held`,
	s.`Total portfolio value`,
	t.`Chipotle shares held`/s.`Total portfolio value` AS `Chipotle percentage`
FROM 
	(	-- the following sub-query finds the total portfolio value grouped by firm
		SELECT 
			mgrno,
			SUM(shares) AS `Total portfolio value`
		FROM
			instown.file3 
		WHERE 
			fdate = 20171231
		GROUP BY mgrno 
	) AS s 
	
	INNER JOIN 
	
	(	-- the following sub-query finds the Chiptole shares held grouped by firm (aka the 90% the same as Q1)
		SELECT 
			a.mgrno,
			b.mgrname,
			a.shares AS `Chipotle shares held`
		FROM 
			instown.file3 AS a
				INNER JOIN instown.file1 AS b	
			ON 
				a.fdate = b.fdate AND 
				a.mgrno = b.mgrno
		WHERE 
			a.fdate = 20171231 AND 
			a.cusip IN 
			(
				SELECT 
					DISTINCT(cusip) 
				FROM instown.file2
				WHERE 
					stkname LIKE '%Chipotle%' AND 
					fdate = 20171231
		)
		GROUP BY a.mgrno
	) AS t
ON s.mgrno = t.mgrno

ORDER BY `Chipotle percentage` DESC
LIMIT 10;
-- Ans: Pershing Square Cap Mgmt, L., again
-- 	  (P.S. looks legit: https://www.google.com/search?q=pershing+square+chipotle)

-- Q3: Will we ever get a Chiptole in Hong Kong?
-- Ans: One can only hope.
