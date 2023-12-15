
# uploadDataToSQL.R

# Previous step: create_tables_SQL.R

# Before uploading the data from Excel to SQL, first make sure the tables have been created on the database. 

# Check if the tables exist already and if not, create them. This only needs to be done once. Run the next line

# get the SQL Connection
source(paste0(getwd(), "/getSQLConnection.R"))
# SQL_connection <- getSQLConnection() 
con <- getSQLConnection() 

# get a list of all tables
tables <- dbListTables(con, schema = "dbo")

# TODO make a comparison here between the list of tables on the server and those that we need to upload
tableNames == tables
# assume they do not exist yet
tablesExistOnServer <- FALSE

if(!tablesExistOnServer){
  
  # tables do not exist yet, let's create them
  # Instead of creating SQL Insert-scripts we can directly upload a data frame or in this case, a tibble, to the server
  
  dbWriteTable(con, 
               name = "Person", 
               value = Person, 
               overwrite = TRUE, 
               row.names = FALSE)
  
}

# Assuming 'Person' is your tibble
field_types <- sapply(Person, function(x) class(x)[1])

# Print the field types
print(field_types)


# Now that the data has been inserted into SQL-files, run these SQL-files to populate the tables. 


