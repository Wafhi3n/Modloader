function GetName {
    param(
        $GitName
    )
     $GitName.Split('/')[-1].Split('.')[0]
}
function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        "Installation de git:"
        winget install --id Git.Git -e --source winget
        refreshPath
    }
}
function CloneMod{
    param (
        $mod
    )
    $lasTag = LatestTag $mod
    $url=$repoUrl+$mod[0]+"/"+$mod[1]
    if ($lasTag -ne ""){
        git clone $url --branch $lasTag --single-branch

    }else{
        git clone $url --single-branch
    }
}

function VerifAndInstallWithGit {
    param (
        $Mod
    )
    $DirName=$Mod[1]
    $TotalPath=$dirMod+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $DirName" - non installé dans :"$TotalPath;
        Write-Host "installation avec git clone..."
        Set-Location $dirMod
        CloneMod $Mod
    }          
}
function VerifModGit{
    param (
        $Mod
    )
 
    $DirName=$Mod[1]
    $TotalPath=$dirMod+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $DirName" - non installé dans :"$TotalPath;
        Write-Host "installation necessaire"
        return $false
    }     
}
function LatestTag {
    param (
        $mod
    )
    $url=$apiurl+"/"+$mod[0]+"/"+$mod[1]+"/releases/latest"
    $tagName=""
    Try{
        $rez = Invoke-RestMethod $url
        $tagName=$rez.tag_name
    }Catch{
        $tagName=""
    }
    $tagName
}