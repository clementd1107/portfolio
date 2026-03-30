# Ajouter une option de création en masse d'utilisateur à partir d'un fichier .csv

#--------------------------------------------------------
# CREATION D'UNE NOUVELLE UNITE ORGANISATIONNELLE AD :
#--------------------------------------------------------

#Récupération des valeurs :
# Name
$OU_name = Read-Host "Nom de l'OU "
$OU_name_exist = Get-ADObject -Filter "Name -eq '$OU_name'" -ErrorAction SilentlyContinue
if($OU_name_exist){
    Write-Host "Attention ! L'OU '$OU_name' existe déjà dans : " -ForegroundColor Yellow -NoNewline
    Write-Host $OU_name_exist.DistinguishedName -ForegroundColor Cyan
}
# Path (bloc à vérifier)
$OU_valid_path = $false
while (-not $OU_valid_path) {
    $OU_path = Read-Host "Destination sous la forme d'un DN -> DC=nom_de_domaine,DC=TLD (Exemples de TLD: com/fr/local) "
    if(Get-ADObject -Identity $OU_path -ErrorAction SilentlyContinue){Write-Host "L'emplacement '$OU_path' est déjà utilisé..." -ForegroundColor Yellow}
    else {$OU_valid_path = $true}
}
# Suppression accidentelle
$Input_protected = Read-Host "Protéger contre la suppression accidentelle ? ([O]ui / [N]on)"
$OU_protected = $true
if($Input_protected -eq "N"){$OU_protected = $false}

#Création du Tableau des paramètres :
$OU_params = @{
    Name = $OU_name
    Path = $OU_path
    ProtectedFromAccidentalDeletion = $OU_protected
}

#Création de l'OU :
Write-Host "Création de l'OU..." -ForegroundColor DarkYellow
New-ADOrganizationalUnit @OU_params
Write-Host "Création de l'OU terminée !" -ForegroundColor Green


#-------------------------------------
# CREATION D'UN NOUVEAU GROUPE AD :
#-------------------------------------

#Récupération des valeurs :
# Name
$Group_name = Read-Host "Nom de l'OU "
$Group_name_exist = Get-ADObject -Filter "Name -eq '$Group_name'" -ErrorAction SilentlyContinue
if($Group_name_exist){
    Write-Host "Attention ! Le groupe '$Group_name' existe déjà dans : " -ForegroundColor Yellow -NoNewline
    Write-Host $Group_name_exist.DistinguishedName -ForegroundColor Cyan
}
# Path (bloc à vérifier)
$Group_valid_path = $false
while (-not $Group_valid_path) {
    $Group_path = Read-Host "Destination sous la forme d'un DN -> OU=nom_OU,DC=nom_de_domaine,DC=TLD (Exemples de TLD: com/fr/local) "
    if(Get-ADObject -Identity $Group_path -ErrorAction SilentlyContinue){Write-Host "L'emplacement '$Group_path' est déjà utilisé..." -ForegroundColor Yellow}
    else {$OU_valid_path = $true}
}
# Type de Groupe
$Input_type = Read-Host "Groupe de [S]écurité ou [D]istribution (par défaut S)? "
$Group_type = "Security"
if ($Input_type -eq "D"){$Group_type = "Distribution"}
else {$Group_type = "Security"}
# Étendue
$Input_scope = Read-Host "Étendue [D]omainLocal, [G]lobal, [U]niversal (par défaut G) "
$Group_scope = "Global"
if($Input_scope -eq "D"){$Group_scope = "DomainLocal"}
elseif($Input_scope -eq "U"){$Group_scope = "Universal"}
else{$Group_scope = "Global"}

#Création du Tableau des paramètres :
$Group_params = @{
    Name = $Group_name
    Path = $Group_path
    GroupCategory = $Group_type
    GroupScope = $Group_scope
}

#Création du groupe :
Write-Host "Création du groupe..." -ForegroundColor DarkYellow
New-ADGroup @Group_params
Write-Host "Création du groupe terminée !" -ForegroundColor Green


#-----------------------------------------
# CREATION D'UN NOUVEL UTILISATEUR AD :
#-----------------------------------------

#Récupération des valeurs :
$User_givenname = Read-Host "Prénom "
$User_surname = Read-Host "Nom de famille "
$User_samaccountname = Read-Host "Identifiant de connexion (Ex : jdupont) "
$User_principal_name = Read-Host "Identifiant de connexion (Ex : jdupont@entreprise.local) "
$User_path = Read-Host "Destination sous la forme d'un DN -> OU=nom_OU,DC=nom_de_domaine,DC=TLD (Exemples de TLD: com/fr/local) "
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

#Création du Tableau des paramètres :
$User_params = @{
    Name = "$User_givenname $User_surname"
    GivenName = $User_givenname
    Surname = $User_surname
    SamAccountName = $User_samaccountname
    UserPrincipalName = $User_principal_name
    Path = $User_path
    AccountPassword = $User_pass
    Enabled = $User_enable
    ChangePasswordAtLogon = $User_change_pass
    PasswordNeverExpires = $User_pass_never_expire
}

#Création du user
Write-Host "Création de l'utilisateur..." -ForegroundColor DarkYellow
New-ADUser @User_params
Write-Host "Création de l'utilisateur terminée !" -ForegroundColor Green