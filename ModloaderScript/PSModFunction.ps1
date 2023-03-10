##Command Line
function listeMod(){
    param()
    Get-ChildItem $(GetModsDir)
    break
    $mod=[ordered]@{}

    #[PSCustomObject]$bbgline = @{ nom = "bbg"    git = "gitbbg"   }
    $cpt=0
    GetGitRepo | ForEach-Object {
        $cpt+=1 
        [PSCustomObject]$bbgline = @{ nom = $(GetName  $PSItem)  ;  git = $PSItem   }
        $mod.add( [string]$cpt ,$bbgline )
    }   
    $mod
    #$ourObject = New-Object -TypeName psobject -Property $mod
    #Format-Table -AutoSize  -Expand Both -InputObject  $ourObject

}
function choiceMod(){
    param()
    $mod=[ordered]@{}
    Write-Host  $(getLocMessage("ModListGit")+" "+$dirMod)
    Write-Host ("Choix"+"     "+"Mod")
    $GetGitRepo | ForEach-Object {
       $cpt+=1 
       $mod.Add([string]$cpt,$(GetName  $PSItem))
       Write-Host $([string]$cpt+"         "+$(GetName  $PSItem))
    }


    return $mod
}

function checkMod(){
    param(
        $git
    )
    $cpt=0;
    $mod = choiceMod

    $askRmModFolder = Read-Host -Prompt  $(getLocMessage("askToInstallModNumber"))
    if ($mod.Contains([string]$askRmModFolder)){
        $p= $($documents+"\My Games\Sid Meier's Civilization VI\Mods\"+$mod[[string]$askRmModFolder])
        $rmModFolder = Read-Host -Prompt  $(getLocMessage("askToInstallMod"))
        if ($rmModFolder -eq  $(getLocMessage("yes"))){
            
            if(!(Test-Path -Path $p)){
                #VerifAndInstallWithGitFromName $mod[[string]$askRmModFolder]
                VerifModFromName $mod[[string]$askRmModFolder]
                "verifié"
            }
        }
    }
}