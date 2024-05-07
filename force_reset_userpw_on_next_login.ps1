# https://stackoverflow.com/questions/46493181/powershell-user-must-change-password-at-next-logon
# https://blog.netwrix.com/2023/06/21/set-aduser-cmdlet-for-managing-active-directory-user-properties/
# https://gemini.google.com/

# Query users from OU's and export into csv
Write-Host "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host "----This script sets the ChangePasswordAtLogon Flag and forces users to reset their password on the next login if the password is older than specified days ----"
Write-Host "----------------------------------------------------------------------------------------------------------------------------------------------------------------"
$userinput = Read-Host -Prompt "Do you want to force the reset password on the next login of a single user (1), a whole OU (2) or read from a csv file (3)?"
$run = $true
$runquestion = "xx"
Do{
    Switch ($userinput)
    {
        1 { 
            $username = Read-Host -Prompt "Please enter the sAMAccountName found in the Attribut-Editor"
            
            $adUser = Get-ADUser -Identity $username -ErrorAction SilentlyContinue
            if ($adUser)
            {
                Set-Aduser -Identity $username -ChangePasswordAtLogon:$true 
            }
            else {
                Write-Warning "No user with sAMAccountName '$($adUser.sAMAccountName)' found..."
            }

            $runquestion = Read-Host -Prompt "Do you want to input another user? y/n"
                if ($runquestion -eq "y")
                {
                }
                else {
                    $run = $false
                }
        }
        2 {
            $ouname = Read-Host -prompt "Please enter the distinguishedName of the OU"
            $oucheck = Get-ADOrganizationalUnit -Identity $ouname

            if($oucheck)
            {
                Get-ADUser -Filter 'Name -like "*"' -SearchBase "$ouname"  -Properties "SamAccountName"  | 
                Set-ADUser -ChangePasswordAtLogon:$true 
            }
            else {
                Write-Host "The OU doesn't exist"
            }
            
            
            $runquestion = Read-Host -Prompt "Do you want to input another OU? y/n"
                if ($runquestion -eq "y")
                {
                }
                else {
                    $run = $false
                }
        }

        3 {
            $exportPath = Read-Host -Prompt "Please enter the Path to the file? (Only path, not filename e.q. C:\Users\$env:username\Desktop)"
            $filename = Read-Host -Prompt "What is the file called? (Only filename e.q. export.csv)"

            $csvusers = Import-CSV -Path $exportPath\$filename
            foreach ($User in $csvusers)
            {
                $adUser = Get-ADUser -Identity $User.samAccountName -ErrorAction SilentlyContinue
                if ($adUser)
                {
                    Set-ADUser -Identity $adUser -ChangePasswordAtLogon:$true -ErrorAction SilentlyContinue
                }
                else {
                    Write-Warning "No user with sAMAccountName '$($user.sAMAccountName)' found..."
                }
            }
            $runquestion = Read-Host -Prompt "Do you want to input another csv File? y/n"
                if ($runquestion -eq "y")
                {
                }
                else {
                    $run = $false
                }
        }
        default {
            Write-Host "Wrong input!"
            $runquestion = Read-Host -Prompt "Do you want to cancel? y/n"
            if ($runquestion -eq "y")
            {
                $run = $false
            }
    }
    }
}
While($run)