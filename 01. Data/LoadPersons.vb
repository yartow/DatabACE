

Private Sub CommandButton1_Click()
    Dim wsPerson As Worksheet
    Dim wsMain As Worksheet
    Dim personData As Variant
    Dim x As Long, y As Long
    Dim i As Long, j As Long

    ' Set the worksheets
    Set wsPerson = ThisWorkbook.Sheets(PERSON_SHEET)
    Set wsMain = ThisWorkbook.Sheets(MAIN_SHEET)

    ' Define the position where data will be pasted in "Main" (example: row 1, column 1)
    x = 3  ' Starting row
    y = 4  ' Starting column

    ' Load data from "Person" sheet into memory (2D array)
    personData = wsPerson.UsedRange.Value ' This assumes data is contiguous in the worksheet

    
	' Edit/Mutate/Filter the data in memory (e.g., filter or mutate)
    ' Example: Replace all values in the first column with "Edited"
	numberOfRows = UBound(personData, 1)
    For i = 1 To numberOfRows
        personData(i, 1) = "Edited" ' Modify data as needed
    Next i

    ' Paste the edited data into the "Main" sheet starting from position (x, y)
    wsMain.Cells(x, y).Resize(UBound(personData, 1), UBound(personData, 2)).Value = personData

End Sub
