

library(xlsx)
library(plyr)
library(dplyr)
library(tibble)
# library(DBI) # for SQL connections 

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
IGNORE_CHAR = "_"

# this file gets info on the database, including table names
source(paste0(CODE_DIRECTORY_R, "db_info.R"))

# if lapply doesn't work, let's go for the old-fashioned for-loop way
my_data <- list()
my_data <- lapply(tableNames, 
                  FUN = read_tables, 
                  # extra variables
                  dbFileLocation, 
                  EXT_SQL, 
                  CODE_DIRECTORY_SQL
                  )

# rename the tables according to `tableNames`
names(my_data) <- tableNames

# next step: create queries to join tables




# # for each worksheet in the Excel file, convert the text to SQL queries
# for (i in 1:length(tableNames)){
#   i <- 2
#   my_data[[i]] <- read_tables( 
#     tableNames[i],
#     dbFileLocation, 
#     EXT_SQL, 
#     CODE_DIRECTORY_SQL
#   )
# 
# }
