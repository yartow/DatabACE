library(odbc)
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "mysqlhost",
                 Database = "mydbname",
                 UID = "myuser",
                 PWD = rstudioapi::askForPassword("Database password"),
                 Port = 1433)