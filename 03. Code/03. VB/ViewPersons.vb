Option Explicit

' Public constants for sheet names
Public Const PERSON_SHEET As String = "Person"
Public Const MAIN_SHEET As String = "Main"

' Connection string needed to connect to SQL Database
Private Const connString As String = "Driver={ODBC Driver 18 for SQL Server};Server=localhost\SQLEXPRESS;Database=ceder;Trusted_Connection=Yes;Encrypt=No;"

Private Const connString_mac As String = _
  "Driver={ODBC Driver 18 for SQL Server};" & _
  "Server=localhost,1433;" & _
  "Database=ceder;" & _
  "Uid=sa;" & _
  "Pwd=YourStrongP@ssword123;" & _
  "Encrypt=No;"



Sub ViewPersons()

    Dim wsPerson As Worksheet
    Dim wsMain As Worksheet
    Dim personData As Variant
    Dim x As Long, y As Long
    Dim i As Long, j As Long
    Dim numberOfRows As Integer
    Dim lastRow As Integer
    Dim lastColumn As Integer
    
    ' Set the worksheets
    Set wsPerson = ThisWorkbook.Sheets(PERSON_SHEET)
    Set wsMain = ThisWorkbook.Sheets(MAIN_SHEET)

    ' Define the position where data will be pasted in "Main" (example: row 1, column 1)
    x = 3  ' Starting row
    y = 4  ' Starting column

    ' Load data from "Person" sheet into memory (2D array)
    personData = wsPerson.UsedRange.Value ' This assumes data is contiguous in the worksheet

    ' Find the last row with data in the first column (ID column)
    lastRow = wsPerson.Cells(wsPerson.Rows.Count, 1).End(xlUp).row
    lastColumn = wsPerson.Cells(1, wsPerson.Columns.Count).End(xlToLeft).Column
    
    ' Load data from "Person" sheet into memory (2D array) until the first empty ID
    personData = wsPerson.Range(wsPerson.Cells(1, 1), wsPerson.Cells(lastRow, lastColumn)).Value

    ' Edit/Mutate/Filter the data in memory (e.g., filter or mutate)
    ' By default filter only students with statusID = 1 (active)
    ' Example: Replace all values in the first column with "Edited"
    ' numberOfRows = UBound(personData, 1)
    ' For i = 1 To numberOfRows
'         personData(i, 1) = "Edited" ' Modify data as needed
    ' Next i

    ' Paste the edited data into the "Main" sheet starting from position (x, y)
    wsMain.Cells(x, y).Resize(UBound(personData, 1), UBound(personData, 2)).Value = personData


End Sub

' Update database with changes from Excel
Sub UpdateDatabase()
    Dim conn As Object
    Dim ws As Worksheet
    Dim lastRow As Long, i As Long
    
    Dim sqlQuery As String
    
    ' Set worksheet reference
    ' TODO make this dynamic
    Set ws = ThisWorkbook.Sheets("Person")
    
    CreateConnection conn
        
    ' Clear table before updating
    conn.Execute "DELETE FROM Person"
    
    ' Insert data from Excel into SQL table
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).row


    Dim dateOfBirth As Variant
    Dim email As String

    For i = 2 To lastRow ' Assuming row 1 contains headers
    
        ' Handle empty cells
        If IsEmpty(ws.Cells(i, 7).Value) Or IsNull(ws.Cells(i, 7).Value) Then
            dateOfBirth = "NULL"
        Else
            dateOfBirth = "'" & Format(ws.Cells(i, 7).Value, "yyyy-mm-dd") & "'"
        End If
        
        
        If IsEmpty(ws.Cells(i, 6).Value) Or IsNull(ws.Cells(i, 6).Value) Then
             email = "NULL"
        Else
            email = "'" & ws.Cells(i, 7).Value & "'"
        End If
                
        sqlQuery = "INSERT INTO Person (ID, Surname, SurnamePrefix, FirstNames, CallName, Email, " & _
                                        "DateOfBirth, AddressID, Status, ClassID, FirstLanguageID, " & _
                                        "SecondLanguageID, StateId, BaptizedId, DenominationId) " & _
                   "VALUES (" & _
                   ws.Cells(i, 1).Value & ", '" & _
                   ws.Cells(i, 2).Value & "', '" & _
                   ws.Cells(i, 3).Value & "', '" & _
                   ws.Cells(i, 4).Value & "', '" & _
                   ws.Cells(i, 5).Value & "', " & _
                   email & ", " & _
                   dateOfBirth & ", '" & _
                   ws.Cells(i, 8).Value & "', '" & _
                   ws.Cells(i, 9).Value & "', " & _
                   ws.Cells(i, 10).Value & ", " & _
                   ws.Cells(i, 11).Value & ", " & _
                   ws.Cells(i, 12).Value & ", " & _
                   ws.Cells(i, 13).Value & ", " & _
                   ws.Cells(i, 14).Value & ", " & _
                   ws.Cells(i, 15).Value & ")"
        
        ' Debug.Print sqlQuery
        
        conn.Execute sqlQuery
        
    Next i
    
    ' Cleanup
    CloseConnection (conn)
    
    MsgBox "Database updated successfully!", vbInformation
    
End Sub

Sub CloseConnection(conn As Object)
    
    ' Try to close the connection
    On Error GoTo ConnectionError
    conn.Close
    Set conn = Nothing
    'MsgBox "Connection successfully closed!", vbInformation
    Exit Sub

ConnectionError:
    MsgBox "Connection failed to close: " & Err.Description, vbCritical
    Set conn = Nothing

End Sub

Sub CreateConnection(ByRef conn As Object)
   
    ' Create a connection object
    Set conn = CreateObject("ADODB.Connection")
    
    On Error GoTo ConnectionError
    conn.Open connString
    ' MsgBox "Connection successful!", vbInformation
    Exit Sub

ConnectionError:
    MsgBox "Connection failed: " & Err.Description, vbCritical
    If Not conn Is Nothing Then conn.Close
    Set conn = Nothing
    
End Sub



' Get data from database and overwrite Excel
Sub GetDataFromDatabase()
    Dim conn As Object
    Dim rs As Object
    Dim ws As Worksheet
    Dim connString As String
    Dim sqlQuery As String
    Dim row As Long
    
    
    connString = "Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=True;"
    
    ' Set worksheet reference
    Set ws = ThisWorkbook.Sheets("Person")
    ws.Cells.Clear ' Clear current sheet
    
    ' Connection string (modify with your server and database details)
    connString = "Provider=SQLOLEDB;Data Source=YOUR_SERVER;Initial Catalog=YOUR_DATABASE;Integrated Security=SSPI;"
    
    ' SQL query to fetch all data
    sqlQuery = "SELECT * FROM Person"
    
    ' Create ADO connection
    Set conn = CreateObject("ADODB.Connection")
    conn.Open connString
    
    ' Execute query
    Set rs = conn.Execute(sqlQuery)
    
    ' Write headers
    ws.Cells(1, 1).Value = "ID"
    ws.Cells(1, 2).Value = "Name"
    ws.Cells(1, 3).Value = "Age"
    
    ' Write data to sheet
    row = 2
    Do While Not rs.EOF
        ws.Cells(row, 1).Value = rs.Fields("ID").Value
        ws.Cells(row, 2).Value = rs.Fields("Name").Value
        ws.Cells(row, 3).Value = rs.Fields("Age").Value
        row = row + 1
        rs.MoveNext
    Loop
    
    ' Cleanup
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    
    MsgBox "Data retrieved successfully!", vbInformation
End Sub


