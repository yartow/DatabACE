# this function reads an Excel-file and inserts everything into tables

source(paste0(getwd(), "/loadLibraries.R"))

source(paste0(getwd(), "/credentials.R"))

# this file gets info on the database, including table names
source(paste0(CODE_DIRECTORY_R, "db_info.R"))

# create a new list and read and import the input data and store this into separate tables
# if lapply doesn't work, go for the old-fashioned for-loop way
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

# after loading all the data, separate this into tables
source(paste0(getwd(), "/03. Code/RDatabACE/separateTables.R"))

# Now the next step is to create these tables *in SQL SERVER*. 
# see uploadDataToSQL.R

# next step: create queries to join tables
# see create_vw_grades.R



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
