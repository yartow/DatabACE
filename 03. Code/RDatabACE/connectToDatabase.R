library(DBI)
# install.packages("odbc")
library(odbc)

# Install MS ODBC 17 (up until 17.7) for Macs running on Intel, later version from 17.8 on are for ARM.
# See Microsoft source for (macOS)[https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/install-microsoft-odbc-driver-sql-server-macos?view=sql-server-ver16] or [Windows](https://learn.microsoft.com/en-us/sql/connect/odbc/microsoft-odbc-driver-for-sql-server?view=sql-server-ver16).
# Run the following lines to download this with Brew.
# ```
# # install brew if you don't have it yet
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# 
# brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
# brew update
# HOMEBREW_ACCEPT_EULA=Y brew install msodbcsql17 mssql-tools
# ```


Server=localhost\SQLEXPRESS;Database=Ceder;Trusted_Connection=True;

# Database credentials 
server <- "localhost,1433"
database <- "Ceder"
uid <- "sa"
pwd <- "nBtoaQ2Anfey"

# Create a connection string
conn_string <- paste0(
  "Driver={ODBC Driver 17 for SQL Server};",
  "Server=", server, ";",
  "Database=", database, ";",
  "Uid=", uid, ";",
  "Pwd=", pwd
)

# Establish a connection
con <- dbConnect(odbc::odbc(), Driver = DB_DRIVER, 
                 Server = DB_Host, 
                 Database = DB_Name, 
                 UID = DB_USERNAME, 
                 PWD = DB_PASSWORD,
                 Port = 1433
)
 
con <- dbConnect(DBI::dbConnect(), .connection_string = conn_string)

# Your data frame in R (replace this with your actual data)
yourDataFrame <- data.frame(
  ID = c(1, 2, 3),
  Name = c("John", "Jane", "Doe"),
  Age = c(25, 30, 22)
)

# Define the table name in SQL
tableName <- "YourTableName"

# Use dbWriteTable to create a new table in the database
dbWriteTable(con, tableName, yourDataFrame, overwrite = TRUE, row.names = FALSE)

# Close the database connection
dbDisconnect(con)

cat("Table", tableName, "created successfully.")
