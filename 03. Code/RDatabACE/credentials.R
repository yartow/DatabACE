
# Variables that need to be set before running the program
HOME_DIRECTORY <- "/Users/andrewyong/Documents/GitHub/DatabACE/"
setwd(HOME_DIRECTORY)
CODE_FOLDER <- "03. Code/"
DATA_FOLDER <- "01. Data/"
CODE_DIRECTORY_SQL <- paste0(HOME_DIRECTORY, CODE_FOLDER)
CODE_DIRECTORY_R <- paste0(HOME_DIRECTORY, CODE_FOLDER, "RDatabACE/")

dbFileName <- "db.xlsx"
dbFileLocation <- paste0(HOME_DIRECTORY, DATA_FOLDER, dbFileName)

# Static variables
EXT_SQL <- ".sql"
CHAR <- "character"
DATE <- "Date"
IGNORE_CHAR = "__"

# This is a list of credentials that needs to be stored in memory so that connections will work
DB_HOST = "localhost"
DB_DRIVER = "ODBC Driver 17 for SQL Server"
DB_NAME = "Ceder"
DB_USERNAME = "sa"
DB_PASSWORD = "nBtoaQ2Anfey"