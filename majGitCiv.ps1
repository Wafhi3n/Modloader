$git = @(
         "https://github.com/iElden/BetterBalancedGame.git",
         "https://github.com/d-jackthenarrator/Civ6-BBS.git",
         "https://github.com/d-jackthenarrator/Civ6-MPH.git",
         "https://github.com/d-jackthenarrator/Civ6-BSM.git"
       )
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$dirMod=$documents+"\My Games\Sid Meier's Civilization VI\Mods"
$env:GIT_REDIRECT_STDERR = '2>&1'

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
        "Veuillez installer git : https://git-scm.com/"
        exit 1;
    }
}

function VerifAndInstallWithGit {
    param (
        $Mod
    )
    $DirName=GetName $Mod
    $TotalPath=$dirMod+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $DirName" - non installé dans :"$TotalPath;
        Write-Host "installation avec git clone..."
        Set-Location $dirMod
        git clone $Mod
    }          
}

function Update {
    param (
        $Mod
    )
    $DirName=GetName $Mod
    $TotalPath=$dirMod+"\"+$DirName
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(git describe --tags (git rev-list --tags --max-count=1))
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        Write-Host "Maj necessaire de "$DirName " " $latesttag " vers la" $tagActuel
        git -c advice.detachedHead=false checkout $latesttag
    }
    
}

function createIcon() {
    $targetPath = "powershell.exe"
    $Arguments = " -command `"& '"+$com+"'`""
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($($desktop+"\Civ6-BBG.lnk"))
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments   = $Arguments
    $Shortcut.Save()
}

VerifGit

$git | ForEach-Object {
    VerifAndInstallWithGit $PSItem
    Update $PSItem
}

if(!(Test-Path -Path $($desktop+"\Civ6-BBG.lnk")  -PathType Leaf )){
    $com=$MyInvocation.MyCommand.Path
    createIcon
    Write-Host "Icone crée sur le Bureau : Civ6-BBG!"
}

Start-Process steam://rungameid/289070


 