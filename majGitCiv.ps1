param(
    [Parameter()]
    [String]$isInstaller
)


$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")

####localization
if((Test-Path -Path $($PSScriptRoot+"\"+$PsUICulture+"\locs.psd1"))){
    Import-LocalizedData -BindingVariable "Messages" -FileName "loc.psd1"
}else{
    Import-LocalizedData -BindingVariable "Messages" -UICulture "en-EN" -FileName "loc.psd1"
    #TODO verif loc manquant -> mute -<
}
#######Conf
if((Test-Path -Path $($PSScriptRoot+"\settings.psd1"))){
    try {
        $ConfigFile = Import-PowerShellDataFile -Path $($PSScriptRoot+"\settings.psd1")
    }catch{
        Write-Host $Messages.issueConfigFile
        exit 0;
    }
}else{
    $MyInvocation.MyCommand.Path
    Write-Host $Messages.missingConfigFile
    exit 0;
}
#Fonction#
function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Host $($Messages.gitInstallation+":")
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
        Write-Host $($DirName+" - "+$Messages.notInstalledIn+" : "+$TotalPath);
        Write-Host $Messages.gitClone
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
        $Path,
        $modloader
    )
    $DirName=GetName $Mod
    $TotalPath=$Path+"\"+$DirName
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(git describe --tags (git rev-list --tags --max-count=1))
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        if(!$GameLauched){
            Write-Host $($Messages.updateRequire+" "+$DirName+" "+$latesttag+" "+$Messages.updateFrom+" "+$tagActuel)
            git -c advice.detachedHead=false checkout $latesttag
        }else{
            $voice.speak($($Messages.updateRequire+$DirName+" "+$latesttag+" "+$Messages.updateFrom+" "+$tagActuel+", "+$Messages.rebootCiv))
            Write-Host $($Messages.updateRequire+" "+$DirName+" "+$latesttag+" "+$Messages.updateFrom+" "+$tagActuel+", "+$Messages.rebootCiv)
            
        }
    }else{
        if(!$GameLauched){
            Write-Host $($DirName +" "+ $Messages.upToDate)
        }
    }
}
function UpdateMod {   
    param (
        $Mod,
        $GameLauched
    )
    Update $Mod $GameLauched $dirMod 0
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

$git = $ConfigFile.git 
$shortCutName=$ConfigFile.shortCutName
$dirDocCivVI=$documents+$ConfigFile.mygameCivVI
$gitUpdategitCiv = $documents+$ConfigFile.gitUpdategitCiv
$dirMod=$dirDocCivVI+"\Mods"

$env:GIT_REDIRECT_STDERR = '2>&1'
$com=$MyInvocation.MyCommand.Path
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0

function main(){

    $date=Get-Date
    $nextCheck=$date.AddMinutes(30);
#Verification de Git   
    VerifGit
if ($isInstaller -eq "byInstaller"){
    Update  $gitUpdategitCiv 0 $($documents+"\My Games\Sid Meier's Civilization VI") 1
}
#Verification des Mods
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem;
        UpdateMod  $PSItem 0 ;
    }
    Write-Host $($Messages.lauchGame+"...")
    Start-Process "steam://rungameid/289070"
    Start-Sleep -s 30
    While ($true){
        $LaunchPadProcess = Get-Process "LaunchPad" -ErrorAction SilentlyContinue
        $Civ6Process = Get-Process "CivilizationVI*" -ErrorAction SilentlyContinue
        $date=Get-Date   
        if ( $Civ6Process -Or $LaunchPadProcess) {
            if ( $($date - $nextCheck) -gt 0){
                Write-Host $($Messages.lookUpdate)
                updateAllMod 1 
                $nextCheck=$date.AddMinutes(30);
            }
        }else {
            Write-Host $($Messages.goodBy) 
            exit 0;
        }      
        Start-Sleep -s 5
    }
}

main
