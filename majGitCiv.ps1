param(
    [Parameter()]
    [String]$isShortcut
)
#Fonction#
function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        "Installation de git:"
        winget install --id Git.Git -e --source winget
        #refresh l'envirronement pour avoir git
        $Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    }
}

function VerifAndInstallWithGit {
    param (
        $Repo,
        $Path

    )
    $DirName=GetName $Repo
    $TotalPath=$Path+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $DirName" - non installé dans :"$TotalPath;
        Write-Host "installation avec git clone..."
        Set-Location $Path
        git clone $Repo
    }          
}
function GetName {
    param(
        $GitName
    )
     $GitName.Split('/')[-1].Split('.')[0]
}

function VerifAndInstallModWithGit {
    param (
        $Mod
    )    
    VerifAndInstallWithGit $Mod $dirMod    
}

function Update {   
    param (
        $Mod,
        $GameLauched,
        $Path
    )
    $DirName=GetName $Mod
    $TotalPath=$Path+"\"+$DirName
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(git describe --tags (git rev-list --tags --max-count=1))
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        if(!$GameLauched){
            Write-Host "Maj necessaire de "$DirName " " $latesttag " depuis la" $tagActuel
            git -c advice.detachedHead=false checkout $latesttag
        }else{
            $voice.speak($("Maj necessaire de "+$DirName+" "+$latesttag+" depuis la "+$tagActuel+", veuillez redemarrer Civilisation son script."))
            Write-Host "Maj necessaire de "$DirName " " $latesttag " depuis la " $tagActuel ", veuillez redemarrer le jeu et ce script."
        }
    }else{
        if(!$GameLauched){
            Write-Host $DirName" est à jour."
        }
    }
}
function UpdateMod {   
    param (
        $Mod,
        $GameLauched
    )
    Update $Mod $GameLauched $dirMod
}
function createIcon() {
    $targetPath = "powershell.exe"
    $Arguments = '-ExecutionPolicy Bypass -File "'+$com+'"'
    $Path=$($desktop+"\"+$shortCutName+".lnk")
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments  = $Arguments
    $Shortcut.IconLocation = $documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\launcher.ico"
    $Shortcut.Save()
}
function updateAllMod(){
    param(
        $GameLauched
    )
    $git | ForEach-Object {
        UpdateMod $PSItem $GameLauched
    }
}
function verifInstallAllMod(){
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem 
    }
}

#Conf
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv"


if((Test-Path -Path $($documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\settings.psd1"))){
    try {
        $ConfigFile = Import-PowerShellDataFile -Path $documents"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\settings.psd1"
    }catch{
        "Probléme avec le fichier de conf."
        exit 0;
    }
}else{
    "fichier de conf introuvable."
    exit 0;
}




$git = $ConfigFile.git 
$shortCutName=$ConfigFile.shortCutName
$dirDocCivVI=$documents+$ConfigFile.mygameCivVI
$dirMod=$dirDocCivVI+"\Mods"

$env:GIT_REDIRECT_STDERR = '2>&1'
$com=$MyInvocation.MyCommand.Path
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0








function main(){

    $date=Get-Date
    $nextCheck=$date.AddMinutes(30);

#Verification du dossier de mod

#Verification de Git   
    VerifGit

#Verification des Mods
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem;
        UpdateMod  $PSItem 0 ;
    }

    Write-Host "lancement de CIV6 avec steam..."
    Start-Process "steam://rungameid/289070"
    Start-Sleep -s 30
    While ($true){
        $LaunchPadProcess = Get-Process "LaunchPad" -ErrorAction SilentlyContinue
        $Civ6Process = Get-Process "CivilizationVI*" -ErrorAction SilentlyContinue
        $date=Get-Date   
        if ( $Civ6Process -Or $LaunchPadProcess) {
            if ( $($date - $nextCheck) -gt 0){
                Write-Host "Recherche de mise à jour"
                updateAllMod 1 
                $nextCheck=$date.AddMinutes(30);
            }
        }else {
            Write-Host "jeu eteint, au revoir" 
            exit 0;
        }      
        Start-Sleep -s 5
    }
}

main
