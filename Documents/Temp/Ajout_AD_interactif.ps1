# Ajouter une option de création en masse d'utilisateur à partir d'un fichier .csv

#--------------------------------------------------------
# CREATION D'UNE NOUVELLE UNITE ORGANISATIONNELLE AD :
#--------------------------------------------------------

#Récupération des valeurs :
# Name
$OU_name = Read-Host "Nom de l'OU "
$OU_name_exist = Get-ADObject -Filter "Name -eq '$OU_name'" -ErrorAction SilentlyContinue
if($OU_name_exist){
    Write-Host "Attention ! Ce nom d'OU a déjà été utilsé aileurs : " -ForegroundColor Yellow -NoNewline
    foreach ($obj in $OU_name_exist) {
        Write-Host " -> $($obj.DistinguishedName)" -ForegroundColor Cyan
    }
    Pause
}
# Path
$domain_name = @(Get-ADDomain | Select-Object @{Name="Name"; Expression={$_.Name}}, @{Name="DistinguishedName"; Expression={$_.DistinguishedName}})
$All_OU = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
$selection_list = $domain_name + $All_OU
$selected_path = $selection_list | Out-GridView -Title "Choisissez l'emplacement de destination" -OutputMode Single
if ($null -eq $selected_path) {
    Write-Host "Annulé par l'utilisateur." -ForegroundColor Yellow
    exit
}
$OU_path = $selected_path.DistinguishedName
Write-Host "Destination retenue : $OU_path" -ForegroundColor Green
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

Pause
#-------------------------------------
# CREATION D'UN NOUVEAU GROUPE AD :
#-------------------------------------

#Récupération des valeurs :
# Name
$Group_valid_name = $false
while ($Group_valid_name -eq $false) {
    $Group_name = Read-Host "Nom du Groupe "
    $Group_name_exist = Get-ADObject -Filter "Name -eq '$Group_name'" -ErrorAction SilentlyContinue
    if($Group_name_exist){
        Write-Host "Attention ! Le groupe '$Group_name' existe déjà : " -ForegroundColor Red -NoNewline
        Write-Host $Group_name_exist.DistinguishedName -ForegroundColor Cyan
        Write-Host "Veuillez choisir un autre nom de Groupe " -ForegroundColor Yellow
    }
    else {
        $Group_valid_name = $true
    }
}

Write-Host "Récupération des emplacements disponibles..." -ForegroundColor Gray
$domain_name = @(Get-ADDomain | Select-Object @{Name="Name"; Expression={$_.Name}}, @{Name="DistinguishedName"; Expression={$_.DistinguishedName}})
$All_OU = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
$selection_list = $domain_name + $All_OU
$selected_path = $selection_list | Out-GridView -Title "Sélectionnez l'OU de destination pour le groupe" -OutputMode Single
if ($null -eq $selected_path) {
    Write-Host "Annulé. Sortie du script." -ForegroundColor Red
    exit
}
$Group_path = $selected_path.DistinguishedName
Write-Host "Destination retenue : $Group_path" -ForegroundColor Cyan
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

Pause
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