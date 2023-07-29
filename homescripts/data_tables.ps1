
# One of the most common request I receive is a request to write PowerShell to go fetch information based on a
# specific set of criteria and exporting that data to CSV or some other file format. Datatables are a great use case
# for this. Datatables is an object type that you can create columns/rows and update each accordingly.

# creates a DataTable object under the variable $DataTable
$DataTable = New-Object System.Data.DataTable

# using the import-csv cmdlet automatically sets the properties of the columns and is good for small datasets
$data = Import-Csv C:\Users\Administrator\Downloads\test.csv

# using the get-content cmdlet parses the csv data as lines of string with no properties
$data2 = Get-Content -Path C:\Users\Administrator\Downloads\test.csv

# splits the firts column index with the delimiter ','
$columns = $data2[0].split(',')

# this line skips the first index row, in this case the columns above^
$data2 = $data2 | Select-Object -Skip 1

# adds the columns from line 12 to the DataTable object created at line 3
$DataTable.Columns.AddRange($columns)

# this block does a foreach loop that goes through each row in $data2 and adds it to the DataTable
# with a Row.Split delimiter
foreach ($Row in $data2) {
    [void]$DataTable.Rows.Add($Row.Split(','))
}

# creates the DataView object for row filtering purposes
$AgeFilter = New-Object System.Data.DataView($data2)
$AgeFilter.RowFilter = "age >= 30"
$AgeFilter
$AgeFilter.RowFilter = "age <= 30"
$AgeFilter

# if you use the Measure-Command -Expression {} cmdlet, you will notice that creating a DataTable will definitely
# improve the processing of data as opposed to an Import-Csv

Measure-Command -Expression {
    $data = Import-Csv C:\Users\Administrator\Downloads\test.csv
    $data | Where-Object age -GE 30
    $data | Where-Object age -LE 30
    $data | Where-Object age -GE 65
}




