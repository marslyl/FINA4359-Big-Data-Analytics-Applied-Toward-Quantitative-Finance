# Task 1: Question 5
# Graph cumulative market return since 1963

# Database login credentials:
usr = "leung_yat"
pw = "919b89"
hst = "apkwan.cqs7w8sr4z03.ap-east-1.rds.amazonaws.com"

# Install and/or load the packages:
install.packages("RMySQL")
require(RMySQL)
install.packages("ggplot2")
require(ggplot2)

# Connection to the database:
con = dbConnect(RMySQL::MySQL(),
                user = usr,
                password = pw,
                host = hst)

# The query:
query_string = "
SELECT 
	dt,
	mkt_rf + rf AS ret,
	(
		SELECT 
			EXP(SUM(LOG(1+mkt_rf+rf))) - 1 
		FROM ff.four_factor b 
		WHERE 
			a.dt >= b.dt AND 
			YEAR(dt) >= 1963
	) AS cum_ret
FROM ff.four_factor a
WHERE YEAR(dt) >= 1963
"
# Note 1: total return = market excess + risk-free rate
# Note 2: This query is quite slow (~ 2.5 min)
#         The R function cumprod() will actually be way faster and achieve a more accurate result
#         than performing a running summation inefficiently on the server.

# Run the query (go grab a coffee):
ret_series = dbGetQuery(con, query_string)

# Disconnect with the database (for good measure):
dbDisconnect(con)

# Check the data fetched:
print(head(ret_series))
print(tail(ret_series)) 

# Plottibg the cumulative return (this is surprisingly slower than expected, ~30s):
qplot(x = dt,
      y = cum_ret,
      data = ret_series,
      main = "Cumulative market return since 1963 in the US",
      xlab = "Date",
      ylab = "Cumulative return")

# Answer:
noquote(paste("A dollar in 1963 would have grown to $", 
              tail(ret_series$cum_ret, 1),  # Last observation
              " at the end of May 2019.",   # Last date in the sample
              sep = ""))

