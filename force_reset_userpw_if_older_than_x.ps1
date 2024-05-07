# https://stackoverflow.com/questions/46493181/powershell-user-must-change-password-at-next-logon
# https://blog.netwrix.com/2023/06/21/set-aduser-cmdlet-for-managing-active-directory-user-properties/
# https://gemini.google.com/
# !!!! When the "ChangePasswordAtLogon"-Flag gets set, it will NULL the pwdLastSet and passwordLastSet attributes.
# !!!! Once the "ChangePasswordAtLogon"-Flag gets removed, the pwdLastSet and passwordLastSet attributes will get the current Time/Date

Write-Host "-------------------------------------------------------------------------------------------------------------------"
Write-Host "----This script sets the ChangePasswordAtLogon Flag and forces users to reset their password on the next login ----"
Write-Host "-------------------------------------------------------------------------------------------------------------------"

$timeframe = Read-Host -Prompt "How old are the password allowed to be till it has to be reset?"
$time = New-TimeSpan -Days $timeframe


$userinput = Read-Host -Prompt "Do you want to force the reset password on the next login of a single user (1), a whole OU (2) or read from a csv file (3)?"
$run = $true
$runquestion = "xx"
Do{
    Switch ($userinput)
    {
        ######## Change of a single User
        1 { 
            $username = Read-Host -Prompt "Please enter the sAMAccountName found in the Attribut-Editor"
            $adUser = Get-ADUser -Identity $username -Properties samAccountName,PasswordLastSet -ErrorAction SilentlyContinue
            
            if ($adUser)
            {
                $passwordAge = (Get-Date) - ($adUser.PasswordLastSet)

                if ($passwordAge -gt $time)
                {
                    Set-Aduser -Identity $username -ChangePasswordAtLogon:$true 
                    Write-Warning "The password for user '$($adUser.SamAccountName)' has to be reset on next login!"
                }
                else
                {
                    Write-Host "The password doesn't have to be reset"
                }
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
        ######## Change of whole Organisational Unit
        2 {
            $ouname = Read-Host -prompt "Please enter the distinguishedName of the OU"
            $oucheck = Get-ADOrganizationalUnit -Identity $ouname

            if($oucheck)
            {
                Get-ADUser -Filter 'Name -like "*"' -SearchBase "$ouname"  -Properties "SamAccountName", "PasswordLastSet" | ForEach-Object{

                    $adUser = $_
                    $passwordAge = (Get-Date) - ($adUser.PasswordLastSet)

                    if ($passwordAge -gt $time)
                    {
                        Set-Aduser -Identity $adUser.SamAccountName -ChangePasswordAtLogon:$true 
                        Write-Warning "The password for user '$($adUser.SamAccountName)' has to be reset on next login!"
                    }
                    else
                    {
                        Write-Warning "The password for user '$($adUser.SamAccountName)' doesn't have to be reset"
                    }
                    Write-Host "Day of the last password set:" $adUser.PasswordLastSet 
                    Write-Host "The age of the password:" $passwordAge
                    Write-Host "Allowed password age:" $time
                    Write-Host "----------------------------"
                    Write-Host "" 
                } 
            }
            else 
            {
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

        ########## Change all users listed in a csv file
        3 {
            $exportPath = Read-Host -Prompt "Please enter the Path to the file? (Only path, not filename e.q. C:\Users\$env:username\Desktop)"
            $filename = Read-Host -Prompt "What is the file called? (Only filename e.q. export.csv)"


            $csvusers = Import-CSV -Path $exportPath\$filename
            foreach ($User in $csvusers)
            {
                $adUser = Get-ADUser -Identity $User.samAccountName -Properties "samAccountName", "PasswordLastSet" -ErrorAction SilentlyContinue
    

                    if ($adUser)
                    {
                        $passwordAge = (Get-Date) - ($adUser.PasswordLastSet)

                        if ($passwordAge -gt $time)
                        {
                            #Set-ADUser -Identity $adUser -ChangePasswordAtLogon:$true -ErrorAction SilentlyContinue
                            Write-Warning "The password for user '$($adUser.SamAccountName)' has to be reset on next login!"
                        }
                        else
                         {
                            Write-Warning "The password for user '$($adUser.SamAccountName)' doesn't have to be reset"
                         }

                         Write-Host "Day of the last password set:" $adUser.PasswordLastSet 
                         Write-Host "The age of the password:" $passwordAge
                         Write-Host "Allowed password age:" $time
                         Write-Host "----------------------------"
                         Write-Host "" 

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