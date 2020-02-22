-- Task #1
SELECT * FROM ff.four_factor LIMIT 50;	-- look at the table

-- Q1. What is the unit of observation?
-- Ans: Trading days

-- Q2: 
SELECT 
	MIN(dt) 'Start date',
	MAX(dt) 'End date',
	COUNT(dt) '# of obs',
	POW(EXP(SUM(LOG(1 + mkt_rf))), 252/COUNT(DISTINCT(dt)) - 1) 'Avg market return',
	POW(EXP(SUM(LOG(1 + mkt_rf))), 252/COUNT(DISTINCT(dt)) - 1)/(STDDEV(mkt_rf)*SQRT(252)) 'Market Sharpe ratio',
	COUNT(dt)/SUM(ABS(mkt_rf) > 0.05)  'Avg freq of 5% changes (trading days)',
	COUNT(dt)/SUM(ABS(mkt_rf) > 0.1)  'Avg freq of 10% changes (trading days)'
FROM ff.four_factor;

-- Q3. The same query to each market in ff.global
SELECT * FROM ff.global_factors LIMIT 50;	-- look at the table

SELECT 
	mkt 'Market', 
	MIN(DATE) 'Start date', 
	MAX(DATE) 'End date', 
	COUNT(DATE) '# of obs',
	POW(EXP(SUM(LOG(1 + mktrf))), 252/ COUNT(DISTINCT(DATE)) - 1) 'Avg market return', 
	POW(EXP(SUM(LOG(1 + mktrf))), 252/ COUNT(DISTINCT(DATE)) - 1) / (STDDEV(mktrf)* SQRT(252)) `Market Sharpe ratio`, 
	COUNT(DATE)/ SUM(ABS(mktrf) > 0.05) 'Avg freq of 5% changes (trading day)', 
	COUNT(DATE)/ SUM(ABS(mktrf) > 0.1) 'Avg freq of 10% changes (trading day)'
FROM ff.global_factors
GROUP BY mkt

-- Q3a. The market with the highest Sharpe ratio in the last 10 years
SELECT 
	mkt 'Market', 
	POW(EXP(SUM(LOG(1 + mktrf))), 252/ COUNT(DISTINCT(DATE)) - 1) / (STDDEV(mktrf)* SQRT(252)) `Market Sharpe ratio`
FROM ff.global_factors
WHERE DATE > 20090430	-- after 20090430, 10 years before the last obsveration 20190430
GROUP BY mkt
ORDER BY `Market Sharpe ratio` DESC 
-- Ans: GlobalexUS

-- Q4. Worst performing 10 months
SELECT
	YEAR(dt) 'Year',
	MONTH(dt) 'Month',
	POW(EXP(SUM(LOG(1 + mkt_rf))), 252/COUNT(DISTINCT(dt)) - 1) / (STDDEV(mkt_rf)*SQRT(252)) `Market Sharpe ratio`
FROM ff.four_factor
WHERE dt IS NOT NULL 
GROUP BY 
	YEAR(dt),
	MONTH(dt)
ORDER BY `Market Sharpe ratio`
LIMIT 10
-- Oct 1987 (#1): The Black Monday
-- Oct 1929 (#3): The "Great Crash"/ the Wall Street Crash of 1929, symbolizing the start of the Great Depression
