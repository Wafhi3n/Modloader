#Using module ModloaderScript\function.psd1
#Import-PowerShellDataFile -Path $($PSScriptRoot+"\settings.psd1")
#$MyInvocation.MyCommand.Module.PrivateData



Import-Module $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")

#$a = getConfParam


#$a.git
#[string] a (){
  #     return  ($MyInvocation.MyCommand.Module.PrivateData | ConvertTo-Json -Depth 4 )
  #  }


$json = @(
    "https://github.com/CivilizationVIBetterBalancedGame/BetterBalancedGame.git"
    "https://github.com/57fan/Civ6-BBS-2.git"
    "https://github.com/CivilizationVIBetterBalancedGame/MultiplayerHelper.git"
    "https://github.com/CivilizationVIBetterBalancedGame/BetterSpectatorMod.git"
  ) | ConvertTo-Json

$ht1 = @{}

(ConvertFrom-Json $json).psobject.properties | Foreach { $ht1[$_.Name] = $_.Value }


# Create a PSCustomObject (ironically using a hashtable)
#$ht1 = getConfParam
$theObject = new-object psobject -Property $ht1

$ht1
exit 0;
#.git

#.add("qsdqs");
# Convert the PSCustomObject back to a hashtable
$ht2 = @{}
$theObject.psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
#$ht2
#Write-Host " "
#$ht1
#exit 0;

$Params = @{
     Path = $($PSScriptRoot+"\ModloaderScript\Modloader.psd1")
    PrivateData = $ht2
  }

  Update-ModuleManifest  @Params