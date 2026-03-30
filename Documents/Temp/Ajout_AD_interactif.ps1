#--------------------------------------------------------
# CREATION D'UNE NOUVELLE UNITE ORGANISATIONNELLE AD :
#--------------------------------------------------------

#Récupération des valeurs :
$OU_name = Read-Host "Nom de l'OU "
$OU_path = Read-Host "Destination sous la forme -> DC=nom_de_domaine,DC=TLD (Exemple de TLD: com ou fr) "
$Input_protected = Read-Host "Protéger contre la suppression accidentelle ? ([O]ui / [N]on)"
$OU_protected = $true
if($Input_protected -eq "N"){$OU_protected = $false}

#Création de l'OU :
Write-Host "Création de l'OU..." -ForegroundColor Green
New-ADOrganizationalUnit -Name "$OU_name" `
    -Path "$OU_path" `
    -ProtectedFromAccidentalDeletion $OU_protected


#-------------------------------------
# CREATION D'UN NOUVEAU GROUPE AD :
#-------------------------------------

#Récupération des valeurs :
$Group_name = Read-Host "Nom du nouveau groupe "
$Group_path = Read-Host "Destination sous la forme -> OU=nom_OU,DC=nom_de_domaine,DC=TLD "

$Input_type = Read-Host "Groupe de [S]écurité ou [D]istribution (par défaut S)? "
$Group_type = "Security"
if ($Input_type -eq "D"){$Group_type = "Distribution"}
else {$Group_type = "Security"}

$Input_scope = Read-Host "Étendue [D]omainLocal, [G]lobal, [U]niversal (par défaut G) "
$Group_scope = "Global"
if($Input_scope -eq "D"){$Group_scope = "DomainLocal"}
elseif($Input_scope -eq "U"){$Group_scope = "Universal"}
else{$Group_scope = "Global"}

#Création du groupe :
Write-Host "Création du groupe..." -ForegroundColor Green
New-ADGroup -Name "$Group_name" `
    -Path "$Group_path" `
    -GroupCategory "$Group_type" `
    -GroupScope $Group_scope


#-----------------------------------------
# CREATION D'UN NOUVEL UTILISATEUR AD :
#-----------------------------------------

#Récupération des valeurs :
$User_givenname = Read-Host "Prénom "
$User_surname = Read-Host "Nom de famille "
$User_samaccountname = Read-Host "Identifiant de connexion (Ex : jdupont) "
$User_principal_name = Read-Host "Identifiant de connexion (Ex : jdupont@entreprise.local) "
$User_path = Read-Host "Destination sous la forme -> OU=nom_OU,DC=nom_de_domaine,DC=TLD "
$User_pass = Read-Host "Donner un mot de passe " -AsSecureString

$Input_enable = Read-Host "Activer le compte ? ([O]ui / [N]on) "
$User_enable  = $false
if ($Input_enable -eq "O"){$User_enable = $true}

$Input_change_pass = Read-Host "L'utilisateur devra changer de mot de passe à la 1ère connexion ? ([O]ui / [N]on) "
$User_change_pass  = $false
if ($Input_change_pass -eq "O"){$User_change_pass = $true}

$Input_pass_never_expire = Read-Host "Le mot de passe n'expire jamais ? ([O]ui / [N]on) "
$User_pass_never_expire  = $false
if ($Input_pass_never_expire -eq "O"){$User_pass_never_expire = $true}

#Création du user
Write-Host "Création de l'utilisateur..." -ForegroundColor Green
New-ADUser -Name "$User_givenname $User_surname" `
    -GivenName $User_givenname `
    -Surname $User_surname `
    -SamAccountName $User_samaccountname `
    -UserPrincipalName $User_principal_name `
    -Path $User_path `
    -AccountPassword $User_pass `
    -Enabled $User_enable `
    -ChangePasswordAtLogon $User_change_pass `
    -PasswordNeverExpires $User_pass_never_expire