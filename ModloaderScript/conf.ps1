
function GetConfFile(){
    param()
    if((Test-Path -Path $($PSScriptRoot+"\..\"+"\Settings\settings.psd1"))){
        return Import-PowerShellDataFile -Path $($PSScriptRoot+"\..\"+"\Settings\settings.psd1")
    }else{
        #TODO verif loc manquant -> mute -<
        Write-Host "erreur conf file"
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
function GetModsDir(){
    return $($documents+"\My Games\Sid Meier's Civilization VI\Mods")
}

function GetSqliteModFile(){
    return $($documents+"\My Games\Sid Meier's Civilization VI\Mods.sqlite")
}
function GetSQLQueryFolder(){
    return $($PSScriptRoot+"\..\"+"\sql\")
}

$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$configFile = GetConfFile;