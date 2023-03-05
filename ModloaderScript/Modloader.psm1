function test(){
    Write-Host "test function module";
    #Write-Host( $MyInvocation.MyCommand.Module.PrivateData)
}


function getConfParam(){
    param(
        $key
    )
    return $MyInvocation.MyCommand.Module.PrivateData
}





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
            $voice.speak($($Messages.updateRequire+" "+$DirName+" "+$latesttag+" "+$Messages.updateFrom+" "+$tagActuel+", "+$Messages.rebootCiv))
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
function checkForUpdate {
    param (
        $OptionalParameters
    )
    
}
function startCiv {
    param (
        $OptionalParameters
    )
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