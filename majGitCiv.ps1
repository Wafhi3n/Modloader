param(
    [Parameter()]
    [String]$isInstaller
)


$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")

####localization
if((Test-Path -Path $($PSScriptRoot+"\"+$PsUICulture+"\loc.psd1"))){
    Import-LocalizedData -BindingVariable "Messages" -FileName "loc.psd1"
}else{
    Import-LocalizedData -BindingVariable "Messages" -UICulture "en-EN" -FileName "loc.psd1"
    #TODO verif loc manquant -> mute -<
}
#######Conf
if((Test-Path -Path $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")) -and (Test-Path -Path $($PSScriptRoot+"\ModloaderScript\Function.psm1"))){
    try {
        $ConfigFile = Import-PowerShellDataFile -Path $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
        Import-Module $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
    }catch{
        Write-Host $Messages.issueConfigFile
        exit 0;
    }
}else{
    Write-Host $Messages.missingConfigFile
    exit 0;
}
#Fonction#



$git = $ConfigFile.PrivateData.git 
$shortCutName=$ConfigFile.PrivateData.shortCutName
$dirDocCivVI=$documents+$ConfigFile.PrivateData.mygameCivVI
$gitUpdategitCiv = $documents+$ConfigFile.PrivateData.gitUpdategitCiv
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

    if([System.Convert]::ToBoolean($ConfigFile.PrivateData.autostart)){
        startCiv
        Write-Host start
    }

    While ($true){
        Start-Sleep -s 5
        Write-Host "test jeu en cours"
    }
}

$ConfigFile.PrivateData.git = $ConfigFile.PrivateData.git + "dqsd"

$Params = @{
     Path = $($PSScriptRoot+"\settings.psd1")
    PrivateData = $ConfigFile.PrivateData
  }

  #Update-ModuleManifest  @Params

#$ConfigFile.PrivateData.git.Add("dqsdsq");






#$myhashtable = $confDatat | ConvertTo-Json | ConvertFrom-Json -AsHashTable
#$myhashtable
 # ;
 #$($PSScriptRoot+"\settings.psd1")
  
  
  #New-ModuleManifest -Path $($PSScriptRoot+"\settings2.psd1")
#main





#[regex]::Unescape(([regex]::Escape("\My Games\Sid Meier's Civilization VI")));


test