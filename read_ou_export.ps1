# https://stackoverflow.com/questions/46493181/powershell-user-must-change-password-at-next-logon

# Query users from ou's and export into csv

Write-Output "-----------------------------------------------------------------------------------------------"
Write-Output "----- This script queries an OU recursively and creates a csv file with the sAMAccountName ----"
Write-Output "-----------------------------------------------------------------------------------------------"

$exportPath = Read-Host -Prompt "Where do you want to save the file? (Only path, not filename e.q. C:\Users\$env:username\Desktop)"
$filename = Read-Host -Prompt "What do you want to call the file? (Only filename e.q. export.csv)"

do {
    $check = Test-Path -Path $exportPath\$filename
                if($check -eq $true)
                {  
                    $deletefile = Read-Host -Prompt "File already exists, do you want to overwrite it? y/n"
                    
                    if ($deletefile -eq 'y')
                    {
                        $OUpath = Read-Host -Prompt "Please enter the distinguishedName of the OU"
                        Get-ADUser -Filter * -SearchBase $OUpath | Select-Object sAMAccountName | 
                        export-csv -path $exportPath\$filename
                    }
                    else
                    {
                        $OUpath = Read-Host -Prompt "Please enter the distinguishedName of the OU"
                        Get-ADUser -Filter * -SearchBase $OUpath | Select-Object sAMAccountName | 
                        export-csv -Append -path $exportPath\$filename
                    }
                }
                else 
                {
                    $OUpath = Read-Host -Prompt "Please enter the distinguishedName of the OU"
                    Get-ADUser -Filter * -SearchBase $OUpath | Select-Object sAMAccountName | 
                    export-csv -path $exportPath\$filename
    
                    
                }
                Write-Output "-------------- Done! --------------"
                $userinput = Read-Host -Prompt "Do you want to read another OU? y/n"

} while ($userinput -eq "y")
Write-Output "---------------- End of reading OU's --------------" 