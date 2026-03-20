# getSQLConnection.R
# By default this function uses SQL Server

getSQLConnection <- function(
    Driver = "ODBC Driver 17 for SQL Server", 
    Server, Database, UID, PWD, Port = 1433
  ){
  
  # TODO Connection string parameters should be passed along instead of hard coded
  require(odbc)
  require(DBI)
  
  con <- DBI::dbConnect(odbc::odbc(),
                        Driver   = DB_DRIVER,
                        Server   = DB_HOST,
                        Database = DB_NAME,
                        UID      = DB_USERNAME,
                        PWD      = DB_PASSWORD, # for security reasons, change this later on to the lines below to an interactive mode
                        # UID      = rstudioapi::askForPassword("Database user"),
                        # PWD      = rstudioapi::askForPassword("Database password"),
                        Port     = Port,
                        if (Sys.info()["sysname"] == "Windows") Trusted_Connection = "True" else NULL)
  
  # see also https://db.rstudio.com/databases/microsoft-sql-server for known issues and more information
  # run queries with 
  # dbGetQuery(con, "SELECT * FROM airports LIMIT 5")
  # See also dbSendQuery() to run safer queries 
  
  getSQLConnection <- con
  
}
