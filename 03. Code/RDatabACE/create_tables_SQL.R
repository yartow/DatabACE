

library(xlsx)
library(plyr)
library(dplyr)
library(tibble)
# library(DBI)

HOME_DIRECTORY <- "/Users/andrewyong/Documents/GitHub/DatabACE/"
setwd(HOME_DIRECTORY)
CODE_FOLDER <- "03. Code/"
DATA_FOLDER <- "01. Data/"
CODE_DIRECTORY_SQL <- paste0(HOME_DIRECTORY, CODE_FOLDER)
CODE_DIRECTORY_R <- paste0(HOME_DIRECTORY, CODE_FOLDER, "RDatabACE/")

dbFileName <- "db.xlsx"
dbFileLocation <- paste0(HOME_DIRECTORY, DATA_FOLDER, dbFileName)

# m and n are rows and columns, respectively

# Static variables
EXT_SQL <- ".sql"
CHAR <- "character"
DATE <- "Date"

# get table name
source(paste0(CODE_DIRECTORY_R, "db_info.R"))

# for each worksheet in the Excel file, convert the text to SQL queries
for (i in 1:length(tableNames)){
  
  print(paste0("Creating ", sql_populate_fileName))
  # testing purposes
  # i <- 5
  
  # get the current table name
  currentTableName <- tableNames[i]
  if(grepl("*", currentTableName, fixed = TRUE)){
    next
  }
  
  
  
  # read file
  temp_table <- read.xlsx(
    dbFileLocation,
    sheetName = currentTableName
  ) %>% as_tibble()
  
  # Create file names
  sql_populate_fileName <- paste0("populate", currentTableName, EXT_SQL)
  sql_populate_file_location <- paste0(CODE_DIRECTORY_SQL, sql_populate_fileName)
  
  source(paste0(CODE_DIRECTORY_R, "createSQL.R"))
  
}
