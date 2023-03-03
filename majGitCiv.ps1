param(
    [Parameter()]
    [String]$isShortcut
)
#Conf
try {
    $ConfigFile = Import-PowerShellDataFile -Path "D:\Mathieu\Documents\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\settings.psd1"
}catch{
    "Probléme avec le fichier de conf."
    exit 0;
}
    
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$git = $ConfigFile.git 
$shortCutName=$ConfigFile.shortCutName
$gitUpdategitCiv=$ConfigFile.gitUpdategitCiv
$dirDocCivVI=$documents+$ConfigFile.mygameCivVI
$dirMod=$dirDocCivVI+"\Mods"

$env:GIT_REDIRECT_STDERR = '2>&1'
$com=$MyInvocation.MyCommand.Path
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0




function Elevation {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File $com";
        exit;
    }
}
function refreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}
function GetName {
    param(
        $GitName
    )
     $GitName.Split('/')[-1].Split('.')[0]
}
function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        "Installation de git:"
        winget install --id Git.Git -e --source winget
        refreshPath
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
    $Arguments = '-ExecutionPolicy Bypass -File "'+$com+'"shortcut"'
    $Arguments
    $Path=$($desktop+"\"+$shortCutName+".lnk")
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments  = $Arguments
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
function main(){
    $date=Get-Date
    $nextCheck=$date.AddMinutes(30);

#Verification du dossier de mod

#Verification de Git   
    if ($isShortcut -ne "shotcut"){
        VerifGit
    }

#Verification de Modloader
    if ($git){
        VerifAndInstallWithGit $gitUpdategitCiv $dirDocCivVI
        Update  $gitUpdategitCiv 0 $dirDocCivVI
    }

#Verification des Mods
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem;
        UpdateMod  $PSItem 0 ;
    }

#Verification de la presence de l'icone
    if(!(Test-Path -Path $($desktop+"\"+$shortCutName+".lnk")  -PathType Leaf )-and $isShortcut -ne "shotcut"){
        createIcon
        Write-Host "Icone crée sur le Bureau : Civ6-BBG!"
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
