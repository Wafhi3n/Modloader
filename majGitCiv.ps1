#Get-NetConnectionProfile

$git = @(
         @("iElden","BetterBalancedGame"),
         @("57fan","Civ6-BBS-2"),
         @("iElden","MultiplayerHelper"),
         @("iElden","BetterSpectatorMod")
       )    
$apiurl="https://api.github.com/repos"
$repoUrl="https://github.com/"
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$dirMod=$documents+"\My Games\Sid Meier's Civilization VI\Mods"
$env:GIT_REDIRECT_STDERR = '2>&1'
$shortCutName="Civ6-BBG"
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
function CloneMod{
    param (
        $mod
    )
    $lasTag = LatestTag $mod
    $url=$repoUrl+$mod[0]+"/"+$mod[1]
    if ($lasTag -ne ""){
        git clone $url --branch $('tags/'+$lasTag) --single-branch

    }else{
        git clone $url --single-branch
    }
}
function VerifAndInstallWithGit {
    param (
        $Mod
    )
    $DirName=$Mod[1]
    $TotalPath=$dirMod+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $DirName" - non installé dans :"$TotalPath;
        Write-Host "installation avec git clone..."
        Set-Location $dirMod
        CloneMod $Mod
    }          
}
function LatestTag {
    param (
        $mod
    )
    $url=$apiurl+"/"+$mod[0]+"/"+$mod[1]+"/releases/latest"
    $tagName=""
    Try{
        $rez = Invoke-RestMethod $url
        $tagName=$rez.tag_name
    }Catch{
        $tagName=""
    }
    $tagName
}
function Update {
    param (
        $Mod,
        $GameLauched
    )
    $DirName=GetName $Mod
    $TotalPath=$dirMod+"\"+$DirName
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(LatestTag $mod)
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        if(!$GameLauched){
            Write-Host "Maj necessaire de "$DirName " " $latesttag " depuis la" $tagActuel
            if ($latesttag -ne ""){
                git -c advice.detachedHead=false checkout $('tags/'+$latesttag)
            }else{
                git -c advice.detachedHead=false checkout 

            }
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
function createIcon() {
    $targetPath = "powershell.exe"
    $Arguments = "-ExecutionPolicy Bypass -File $com"
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
        Update $PSItem $GameLauched
    }
}
function verifInstallAllMod(){
    $git | ForEach-Object {
        VerifAndInstallWithGit $PSItem 
    }
}
function main(){
    $date=Get-Date
    $nextCheck=$date.AddMinutes(30);
   
    VerifGit

    $git | ForEach-Object {
        VerifAndInstallWithGit $PSItem;
        Update  $PSItem 0 ;
    }

    
    if(!(Test-Path -Path $($desktop+"\"+$shortCutName+".lnk")  -PathType Leaf )){
        createIcon
        Write-Host "Icone crée sur le Bureau : Civ6-BBG!"
    }

    Write-Host "lancement de CIV6 avec steam..."
    Start-Process steam://rungameid/289070 %command%
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