function Elevation {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File $com";
        exit;
    }
}
function refreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}
function checkInstallFont {
    #$shell = New-Object -ComObject Shell.Application
    #$shell.Namespace("$PSScriptRoot/$fontNameCiv.otf").InvokeVerbEx("Install")
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
        Copy-Item "$PSScriptRoot/$fontNameCiv.otf" "C:\Windows\Fonts"   
        New-ItemProperty -Name "Custom Font Name (TrueType)" -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value "$fontNameCiv.otf"
    }else{
        Elevation
    }
    



    #start-process "$PSScriptRoot/$fontNameCiv.otf"  -Verb install
    #$uri = "C:\Windows\fonts\$fontNameCiv.otf"
    #Write-Host $uri 
    #if (-not(Test-Path -Path $uri )) {
    #    echo $fontNameCiv
    #    #dir $file | %{ $fonts.CopyHere($_.fullname) }
    #    cp "$PSScriptRoot/$fontNameCiv.otf" c:\windows\fonts\
    #}
}



