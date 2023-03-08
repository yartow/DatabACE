# this function create the SQL File with inserts


# # if the file already exists, delete this first
# if (file.exists(sql_populate_file_location)){
#   file.remove(sql_populate_file_location)
# }

# m and n are rows and columns, respectively
# testing purposes
# m <- 2
# n <- 1

createSQL <- function(currentTableName, 
                      sql_populate_file_location, 
                      temp_table, 
                      CHAR = "character"){
  
  # create SQL file
  temp_row <- ""
  temp_query <- "" # paste0("-- Columns", names(temp_table))
  isFirstColumn <- TRUE
  
  print(paste0("Creating SQL code for table '", currentTableName, "'"))
  
  for(m in 1:nrow(temp_table)){
    
    # create the SQL Insert-preamble
    temp_row <- paste0("insert into ", currentTableName, " values (")
    
    # Concatenate all column values
    for (n in 1:ncol(temp_table)){
      
      # write the current value into the SQL-line
      temp_value <- temp_table[[n]][m]
      
      # handle empty values
      if(is.na(temp_value)){
        
        # the value is null
        def_value <- "NULL"
        
      } else {
        
        # the value is not null 
        if (typeof(temp_value) == CHAR){
          
          # the value is of the type string
          # replace apostrophes
          temp_value <- gsub("'", "''", temp_value)
          def_value <- paste0("'", temp_value, "'")  
          
        } else {
          
          # the type of this value is not a string
          
          # check if the type is a date
          def_value <- ifelse(class(temp_value) == DATE, 
                              
                              # the type is a date. Add SQL format to date
                              paste0("cast('", temp_value, "' as Date)"), 
                              temp_value
          )
          
        }
      }
      
      
      # concatenate column value
      temp_row <- paste0(
        temp_row, 
        if_else(isFirstColumn, "", ", "), # add a comma except in case of the first column
        def_value
      )
      
      # Check if we are in the first column
      if(isFirstColumn){
        
        # we are in the first column, but now we will go to the second one
        isFirstColumn <- FALSE
        
      }
      
    }
    
    # END THE ROW ####
    
    # Add parenthesis and line feed
    temp_row <- paste0(temp_row, ")\n")
    
    # append the temporary row to the temporary query
    temp_query <- paste0(
      temp_query, 
      temp_row
    )
    
    # # reset the temporary row
    # temp_row <- ""
    isFirstColumn <- TRUE
    
  }
  
  
  # write the file. Note that writing this will overwrite the previous file
  write(temp_query, sql_populate_file_location)
  
}
