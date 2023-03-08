using namespace System.Collections.Generic          
using namespace System.Web
using  namespace ModloaderClass  ;

$a = New-Object .Mod


#$a = [ModloaderClass.Model.Mod]@{} ;
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
####localization
if((Test-Path -Path $($PSScriptRoot+"\..\"+"\"+$PsUICulture+"\loc.psd1"))){
    Import-LocalizedData -BindingVariable "Messages" -BaseDirectory $($PSScriptRoot+"\..\") -FileName "loc.psd1"
}else{
    Import-LocalizedData -BindingVariable "Messages" -UICulture "en-EN" -BaseDirectory $($PSScriptRoot+"\..\") -FileName "loc.psd1"
    #TODO verif loc manquant -> mute -<
}
  

function getLocMessage(){
    param(
        [string]$message
    )
    if(!$Messages.Contains($message)){
        return $("Not localised string"+$message)
    }
    return $Messages[$message]
}
################Fonction################
function test(){
    Write-Host "test function module";
    #Write-Host( $MyInvocation.MyCommand.Module.PrivateData)
}


function GetConfFile(){
    param()
    if((Test-Path -Path $($PSScriptRoot+"\..\"+"\Settings\settings.psd1"))){
        return Import-PowerShellDataFile -Path $($PSScriptRoot+"\..\"+"\Settings\settings.psd1")
    }else{
        #TODO verif loc manquant -> mute -<
    }
   
     
}


function getConfParam(){
    param(
        $key
    )
    return $configFile[$key]
}

function UpdateConf(){
    $Params = @{
     Path = $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
     PrivateData = $ht2
  }
  Update-ModuleManifest  @Params
}


####Getting Conf###
function GetGitRepo(){
    return (ConvertFrom-Json $(getConfParam("git")))
}
function GetCiv6Games(){
    return [System.Web.HttpUtility]::UrlDecode($(getConfParam("mygameCivVI")))
}
function GetGitUpdategitCiv(){
    return $(getConfParam("gitUpdategitCiv"))
}
function GetAutostart(){
    return $(getConfParam("autostart"))
}
function GetautoUpdateModloader(){
    return $(getConfParam("autoUpdateModloader"))
}


function GetAutoUpdate(){
    return $(getConfParam("autoUpdate"))
}


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
    )
    git -c advice.detachedHead=false checkout $latesttag
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

##Command Line
function listeMod(){
    param()
    Get-ChildItem $($documents+"\My Games\Sid Meier's Civilization VI\Mods")
    break
    $mod=[ordered]@{}

    #[PSCustomObject]$bbgline = @{ nom = "bbg"    git = "gitbbg"   }
    $cpt=0
    $git | ForEach-Object {
        $cpt+=1 
        [PSCustomObject]$bbgline = @{ nom = $(GetName  $PSItem)  ;  git = $PSItem   }
        $mod.add( [string]$cpt ,$bbgline )
    }   
    

    $ourObject = New-Object -TypeName psobject -Property $mod
    Format-Table -AutoSize  -Expand Both -InputObject  $ourObject

}
function choiceMod(){
    param()
    $mod=[ordered]@{}
    Write-Host  $(getLocMessage("ModListGit")+" "+$dirMod)
    Write-Host ("Choix"+"     "+"Mod")
    $git | ForEach-Object {
       $cpt+=1 
       $mod.Add([string]$cpt,$(GetName  $PSItem))
       Write-Host $([string]$cpt+"         "+$(GetName  $PSItem))
    }


    return $mod
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

$configFile = GetConfFile;
$git=GetGitRepo;
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

#Verification de Git   
VerifGit

if (($isInstaller -eq "byInstaller") -and ([System.Convert]::ToBoolean($(GetautoUpdateModloader)))){
    Update  $gitUpdategitCiv 0 $($documents+"\My Games\Sid Meier's Civilization VI") 1
}


#Write-Host $git
    #Verification des Mods
    $git | ForEach-Object {
        VerifAndInstallModWithGit $PSItem;
        UpdateMod_Module  $PSItem 0 0;
    }
    if([System.Convert]::ToBoolean($(GetAutostart))){
        startCiv
        Write-Host start
    }
}
#main
