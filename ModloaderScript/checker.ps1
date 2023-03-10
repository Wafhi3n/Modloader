function MainCheck(){

    $modTable = GetTableMods;

    #Write-Host $(GetTableMods)
    checkAllModFile  $modTable
}

function checkAllModFile(){
    param (
        $BSMGame
    )
    $modTable | foreach {
        Write-Host $PSItem;
            isSteamMod
            checkModId #banned
            
    } 

            #is the 3 enabled + BSM if enabled
}


function StartCheck {
    param (
        #OptionalParameters
    )
    #Verification Install de Git   
        VerifGit
    #Verification Install de sqlite3
        #TODO
    #dossier civ6 + mod

}