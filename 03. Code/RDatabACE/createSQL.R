library(xlsx)
library(plyr)
library(dplyr)
library(tibble)
# library(DBI)


setwd("/Users/andrewyong/Documents/GitHub/DatabACE/")
dbFileName <- "db.xlsx"
dbFileLocation <- paste0(getwd(), "/", "01. Data/", dbFileName)

source(paste0(getwd(), "/db_info.R"))

for (i in 1:length(tableNames)){
  
}

i <- 1

# read file
temp_table <- read.xlsx(dbFileLocation,
          sheetName = tableNames[i]
          ) %>% as_tibble()

# m and n are rows and columns, respectively

# create SQL file
temp_row <- ""
file.remove("populatePersons.sql")
for(m in 1:nrow(temp_table)){
  
  temp_row <- paste0(temp_row, "insert into ", tableNames[i], " values (")
  
  # for all columns append 
  for (n in 1:ncol(temp_table)){
    
    temp_row <- paste0(
      temp_row, 
      if(typeof(temp_table[[n]]) == "character"){"'"},
      temp_table[m, n],
      if(typeof(temp_table[[n]]) == "character"){"'"},
      ", ")
  }
  
  temp_row <- paste0(
    temp_row, 
    ")", "\n"
    )
}

textFile <- file()
cat(temp_row, file = textFile)


write(temp_row, "textFile.sql")
writeLines(temp_row,  )
