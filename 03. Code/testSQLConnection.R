# testSQLConnection.R
# Using a DSN
con <- dbConnect(odbc::odbc(), "mydbalias")

# https://support.posit.co/hc/en-us/articles/214510788-Setting-up-R-to-connect-to-SQL-Server-

# See also: 
#   https://www.r-bloggers.com/2020/09/how-to-connect-r-with-sql/