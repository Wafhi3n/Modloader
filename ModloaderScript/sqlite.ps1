
New-Alias -Name sqlite3 -Value $($env:LOCALAPPDATA+"\Microsoft\WinGet\Packages\SQLite.SQLite_Microsoft.Winget.Source_8wekyb3d8bbwe\sqlite-tools-win32-x86-3400000\sqlite3.exe")

function executeQuerySQLFromFile(){
    param(
        $dbFile,
        $sqlFile

    )
    $a = (cat $sqlFile |  sqlite3 $dbFile  )
    return $( $a | ConvertFrom-Csv -Delim ',')
} 



function executeQuerySQLToSqliteMod(){
    param(
        $sqlFile
    )
    executeQuerySQLFromFile $ModDbFile $sqlFile
}

function GetTableMods(){

    return executeQuerySQLToSqliteMod $($(GetSQLQueryFolder)+"tableMods.sql")
    
}
$ModDbFile = GetSqliteModFile

