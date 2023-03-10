function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Host $(getLocMessage("gitInstallation")+":")
        winget install --id Git.Git -e --source winget
        #refresh l'envirronement pour avoir git
        $Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    }
}
function VerifAndInstallWithGitFromName{
    param(
        $Repo
    )
    $git | ForEach-Object {

        if ($(GetName $PSItem) -eq $Repo){
            "installation"
            VerifAndInstallModWithGit $PSItem 1
            #Write-Host $("indtall"+$Repo)  
            break;
        }
    }
}
function UpdateFromName{
    param(
        $Repo,
        $FromPromp
         
    )
    $git | ForEach-Object {

        if ($(GetName $PSItem) -eq $Repo){
            "installation"
            UpdateMod_Module $PSItem $GameLauched $FromPromp
            #Write-Host $("indtall"+$Repo)  
            break;
        }
    }
}




function VerifAndInstallWithGitFromName{
    param(
        $Repo
    )
    $git | ForEach-Object {

        if ($(GetName $PSItem) -eq $Repo){
            "installation"
            VerifAndInstallModWithGit $PSItem 1
            #checkModFromName PSItem
            #Write-Host $("indtall"+$Repo)  
            break;
        }
    }


}

function VerifModFromName {
    param (
        $Repo
    )


    $git | ForEach-Object {
        if ($(GetName $PSItem) -eq $Repo){
            "verification"
            #VerifAndInstallModWithGit $PSItem 1
            checkModFromName PSItem
            #Write-Host $("indtall"+$Repo)  
            break;
        }
    }

    $DirName = GetName $Repo
        $TotalPath=$Path+"\"+$DirName
        if (!(Test-Path -Path $TotalPath -PathType Container )) {
            Write-Host $(getLocMessage("verification"))
            Set-Location $Path
        
                ##verification
            
        }     
    
}

function VerifAndInstallWithGit {
    param (
        $Repo,
        $Path,
        $force
    )
    if(([System.Convert]::ToBoolean($(GetAutoUpdate)) ) -or ( $force -eq 1 ) ){
        $DirName = GetName $Repo
        $TotalPath=$Path+"\"+$DirName
        if (!(Test-Path -Path $TotalPath -PathType Container )) {
            Write-Host $( $DirName + " - " + $(getLocMessage("notInstalledIn")) + " : " +$TotalPath );
            Write-Host $(getLocMessage("gitClone"))
            Set-Location $Path
        
            
                git clone $Repo
            
        }     
    }
}
function GetName {
    param(
        $GitName
    )
     return $GitName.Split('/')[-1].Split('.')[0]
}
function VerifAndInstallModWithGit {
    param (
        $Mod,
        $force
    )    
    VerifAndInstallWithGit $Mod $([environment]::getfolderpath("mydocuments")+$(GetCiv6Games)+"\Mods") $force 
}

function GitReset(){
    param(
        $TotalPath
    )
    if(!($TotalPath -eq $dirMod)){
    git clean -fxd
    git reset --hard
    }
}

function GitCheckoutFromTag(){
    param(
        $tag
    )
    git -c advice.detachedHead=false checkout $tag
}


function Update {   
    param (
        $Mod,
        $GameLauched,
        $Path,
        $modloader,
        $FromPromp
    )
    $DirName= $(GetName $Mod)  
    $TotalPath=$Path+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        return
    }
    Set-Location $TotalPath
    git fetch --tags
    $latesttag=$(git describe --tags (git rev-list --tags --max-count=1))
    $tagActuel=git describe --tags
    if($latesttag -ne $tagActuel){
        if(!$GameLauched){
            Write-Host $($(getLocMessage("updateRequire"))+" "+$DirName+" "+$latesttag+" "+$(getLocMessage("updateFrom"))+" "+$tagActuel)
            if(([System.Convert]::ToBoolean($(GetautoUpdateModloader))) -or ($FromPromp)){

                $ask = Read-Host -Prompt $(getLocMessage("askingUpdate"))
                if ($ask -eq $(getLocMessage("yes"))){
                    GitReset $TotalPath
                    GitCheckoutFromTag $latesttag
                }               
            }
            
        }else{
            $phrase = $($(getLocMessage("updateRequire"))+" "+$DirName+" "+$latesttag+" "+$(getLocMessage("updateFrom"))+" "+$tagActuel+", "+$(getLocMessage("rebootCiv")))
            $voice.speak($phrase)
            Write-Host $phrase
            
        }
    }else{
        if(!$GameLauched){
            Write-Host $($DirName +" "+  $(getLocMessage("upToDate")))
        }
    }
}
function UpdateMod_Module {   
    param (
        $Mod,
        $GameLauched,
        $FromPromp
    )
    Update $Mod $GameLauched $([environment]::getfolderpath("mydocuments")+$(GetCiv6Games)+"\Mods") 0 $FromPromp
}


function updateAllMod(){
    param(
        $GameLauched
    )
    $git | ForEach-Object {
        UpdateMod_Module $PSItem $GameLauched 0
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
function UpdateAndInstallAllRepo(){
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem;
        UpdateMod_Module  $PSItem 0 0;
    }
}
$git=GetGitRepo;