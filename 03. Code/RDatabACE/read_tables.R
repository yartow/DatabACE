

read_tables <- function(currentTableName, 
                        dbFileLocation, 
                        EXT_SQL, 
                        CODE_DIRECTORY_SQL, 
                        IGNORE_CHAR = "__"
                        ){
  
  # testing purposes
  # i <- 5
  
  # get the current table name
  # currentTableName <- tableNames[i]
  
  # skip this (work)sheet if it contains an asterisk
  if(grepl(IGNORE_CHAR, currentTableName, fixed = TRUE)){
    
    # send a message 
    print(paste0("Table ", currentTableName, " skipped"))
    return(paste0("Table ", currentTableName, " skipped"))
  }
  
  require(xlsx)
  require(plyr)
  require(dplyr)
  require(tibble)
  
  # read file
  temp_table <- read.xlsx(
    dbFileLocation,
    sheetName = currentTableName
  ) %>% as_tibble()
  
  # Create file names
  sql_populate_fileName <- paste0("populate", currentTableName, EXT_SQL)
  sql_populate_file_location <- paste0(CODE_DIRECTORY_SQL, sql_populate_fileName)
  print(paste0("Creating ", sql_populate_fileName))
  
  
  # create an SQL file to insert data into a database
  source(paste0(CODE_DIRECTORY_R, "createSQL.R"))
  createSQL(currentTableName, 
            sql_populate_file_location, 
            temp_table, 
            thisIgnoreCharacter = IGNORE_CHAR)
  
  # return the table as a result
  return(temp_table)
  
}


