param(
    [Parameter()]
    [String]$isInstaller
)




#######Conf
if((Test-Path -Path $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")) -and (Test-Path -Path $($PSScriptRoot+"\ModloaderScript\Modloader.psm1"))){
    try {
        #$ConfigFile = Import-PowerShellDataFile -Path $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
        Import-Module $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
    }catch{
        Write-Host "Issue With Module Files"
        exit 0;
    }
}else{
    Write-Host "Missing Module Files"
    exit 0;
}




