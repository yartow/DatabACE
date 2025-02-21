docker run -e 'ACCEPT_EULA=Y' \
           -e 'MSSQL_SA_PASSWORD=JKgo9VoPLUjuWJ43gvar' \
           -p 1433:1433 \
           --name sql1 \
           --hostname sql1 \
           -d mcr.microsoft.com/mssql/server:2022-latest

docker run --platform=linux/amd64 \
   -e ACCEPT_EULA=Y \
   -e MSSQL_SA_PASSWORD="JKgo9VoPLUjuWJ43gvar" \
   -p 1433:1433 \
   --name sql1 \
   -d mcr.microsoft.com/mssql/server:2022-latest