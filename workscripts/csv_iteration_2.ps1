

# imports the CSV with the necessary columns

$csv = Import-Csv -Path "C:\Users\brylle.purificacion\OneDrive - Great Gulf Group\Desktop\nopicture5.csv"

# creates an object for each row for better object manipulation

$csv = foreach ($row in $csv) {
    [PSCustomObject]@{
        Name         = $row.name
        Title        = $row.Title
        FirstName    = $row.FirstName
        LastName     = $row.LastName
        Department   = $row.Department
        validPicture = $row.PictureData
        CompanyID    = $row.CompanyID
    }
}

# this is a simple foreach loop with a nested do..until loop using a stopwatch for retrycounts

$results = foreach ($user in $csv) {

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew() # Start stopwatch

    do {
        $photoValid = Get-UserPhoto -Identity $user.name | Select-Object Identity, PictureData, IsValid
        $stopwatch.Stop() # Stop stopwatch
        $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds
        Write-Host "Processing the following user: $($user.Name)" -ForegroundColor Yellow
        if ($photoValid -or $elapsedSeconds -ge 7) {
            break # Exit loop if photo is valid or timeout occurred
        }
    } until ($photoValid ) # Retry for a maximum of 10 times

    [PSCustomObject]@{
        Name         = $user.name
        Title        = $user.Title
        FirstName    = $user.FirstName
        LastName     = $user.LastName
        Department   = $user.Department
        validPicture = $photoValid.isValid
        CompanyID    = $user.CompanyID
    }
}
