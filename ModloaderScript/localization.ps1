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