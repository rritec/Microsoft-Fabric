3. Configure the Copy Data Activity
Within ForEach1, add a Copy Data Activity named Copy data1:
Source Settings
- Type: ExcelSource
- File Location:- File: Load_multiple_sheets_of_excel.xlsx.
- Folder: rawdata.

- Sheet Name: Use the expression:@item()

- Enable the First Row as Header option.


