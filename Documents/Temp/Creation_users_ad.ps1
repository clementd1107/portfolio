New-ADOrganizationalUnit -Name "Fournisseurs" -Path "DC=stadiumcompany, DC=local"
New-ADGroup -Name "Fournisseurs" -Path "OU=Fournisseurs, DC=stadiumcompany, DC=local"`
    -GroupScope Global
New-ADUser -Name "Toto Toto"`
    -DisplayName "TOTO Toto"`
    -GivenName "Toto"`
    -Surname "Toto"`
    -SamAccountName "toto.toto"`
    -UserPrincipalName "toto@stadiumcompany.local"`
    -Path "OU=Fournisseurs,DC=stadiumcompany,DC=local"`
    -AccountPassword(Read-Host -AsSecureString "Mot de passe ?")`
    -Enabled $true
    #-ChangePasswordAtLogon $false
    #-PasswordNeverExpires $true