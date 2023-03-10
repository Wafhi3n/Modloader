using namespace System.Collections.Generic          
using namespace System.Web
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")

################Fonction################
function test(){
    Write-Host "test function module";
    #Write-Host( $MyInvocation.MyCommand.Module.PrivateData)
}







function createIcon() {
    $targetPath = "powershell.exe"
    $Arguments = '-ExecutionPolicy Bypass -File "'+$com+'"'
    $Path=$($desktop+"\"+$shortCutName+".lnk")
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments  = $Arguments
    $Shortcut.IconLocation = $documents+"\My Games\Sid Meier's Civilization VI\Modloader\launcher.ico"
    $Shortcut.Save()
}

function startCiv {
    param (
        $OptionalParameters
    )
    Write-Host $( $(getLocMessage("lauchGame")+"..."))
    Start-Process "steam://rungameid/289070"
    Start-Sleep -s 30
    While ($true){
        $LaunchPadProcess = Get-Process "LaunchPad" -ErrorAction SilentlyContinue
        $Civ6Process = Get-Process "CivilizationVI*" -ErrorAction SilentlyContinue
        $date=Get-Date   
        if ( $Civ6Process -Or $LaunchPadProcess) {
            if ( $($date - $nextCheck) -gt 0){
                Write-Host $(getLocMessage("lookUpdate"))
                updateAllMod 1 
                $nextCheck=$date.AddMinutes(30);
            }
        }else {
            Write-Host $(getLocMessage("goodBy"))
            exit 0;
        }      
        Start-Sleep -s 5
    }
    
}


function deleteMod(){
    param(
        #$mod
    )
    $cpt=0;
    $mod = choiceMod

    
    $askRmModFolder = Read-Host -Prompt  $(getLocMessage("askToDeleteModNumber"))
    if (($mod.Contains([string]$askRmModFolder)) ){
        $p= $($documents+"\My Games\Sid Meier's Civilization VI\Mods\"+$mod[[string]$askRmModFolder])
        $rmModFolder = Read-Host -Prompt  $(getLocMessage("askToDeleteMod"))
        if ($rmModFolder -eq  $(getLocMessage("yes"))){
            
            if((Test-Path -Path $p)){
  
                Remove-Item -Force -Recurse -Path $p 
                Write-Host  $(getLocMessage("modDeleted"))
            }
        }
    }
}

function installMod(){
    param(

    )
    $cpt=0;
    $mod = choiceMod

    #
    #$ourObject = New-Object -TypeName psobject -Property $mod
   #Format-Table -InputObject [PSCustomObject]$mod 

   #$mod
   #$ourObject


    $askRmModFolder = Read-Host -Prompt  $(getLocMessage("askToInstallModNumber"))
    if ($mod.Contains([string]$askRmModFolder)){
        $p= $($documents+"\My Games\Sid Meier's Civilization VI\Mods\"+$mod[[string]$askRmModFolder])
        $rmModFolder = Read-Host -Prompt  $(getLocMessage("askToInstallMod"))
        if ($rmModFolder -eq  $(getLocMessage("yes"))){
            
            if(!(Test-Path -Path $p)){
                VerifAndInstallWithGitFromName $mod[[string]$askRmModFolder]
                "installé"
            }
        }
    }
}

function UpdateMod(){
    param(
        $mod,
        $tag
    )
    $cpt=0;
    #if()$mod = choiceMod
    $askRmModFolder = Read-Host -Prompt  $(getLocMessage("askToUpdateModNumber"))
    if ($mod.Contains([string]$askRmModFolder)){
        $p= $($documents+"\My Games\Sid Meier's Civilization VI\Mods\"+$mod[[string]$askRmModFolder])
        $rmModFolder = Read-Host -Prompt  $(getLocMessage("askToUpdateMod"))
        if ($rmModFolder -eq  $(getLocMessage("yes"))){
            if((Test-Path -Path $p)){
                UpdateFromName $mod[[string]$askRmModFolder] 1 $tag
                "installé"
            }
        }
    }
}



function ChangeTagMod(){
    param(

    )
    $cpt=0;
    $mod = choiceMod

    #
    #$ourObject = New-Object -TypeName psobject -Property $mod
   #Format-Table -InputObject [PSCustomObject]$mod 

   #$mod
   #$ourObject


    $askRmMod = Read-Host -Prompt  $(getLocMessage("askToChangeModNumber"))
    $askTagMod = Read-Host -Prompt  $(getLocMessage("askToChangeTagModNumber"))
    if ($mod.Contains([string]$askRmMod)){
        $p= $($documents+"\My Games\Sid Meier's Civilization VI\Mods\"+$mod[[string]$askRmMod])
        $rmMod= Read-Host -Prompt  $(getLocMessage("askToInstallMod"))

        if ($rmModFolder -eq  $(getLocMessage("yes"))){
            
            if(!(Test-Path -Path $p)){
                #VerifAndInstallWithGitFromName $mod[[string]$askRmModFolder]
                Write-Host $($mod[[string]$askRmMod]+" chnage tag vers "+$askTagMod)
            }
        }
    }
}

#fonction qui va check le mod par etape


$dirDocCivVI=$documents+$(GetCiv6Games)
$gitUpdategitCiv = $documents+$(GetGitUpdategitCiv)
$dirMod=$dirDocCivVI+"\Mods"
$env:GIT_REDIRECT_STDERR = '2>&1'
$com=$MyInvocation.MyCommand.Path
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0
$date=Get-Date
$nextCheck=$date.AddMinutes(30);



function main(){
    Set-Location $PSScriptRoot
    StartCheck ##Verification des prerequis

    ##Maj Modloader
    if (($isInstaller -eq "byInstaller") -and ([System.Convert]::ToBoolean($(GetautoUpdateModloader)))){
        Update  $gitUpdategitCiv 0 $($documents+"\My Games\Sid Meier's Civilization VI") 1
    }

    #Maj & intall des mods
    UpdateAndInstallAllRepo


    MainCheck  ## verif des mods ..
     
    if([System.Convert]::ToBoolean($(GetAutostart))){
        startCiv
        Write-Host start
    }
}
main
