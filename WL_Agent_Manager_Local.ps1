<#
.Description
Script that installs or updates the Winlogbeat agent locally on the server.
.PARAMETER service_name
Winlogbeat's service name.
.PARAMETER new_version_path
Path corresponding to the Winlogbeat's version to install/update.
.PARAMETER WorkDir
Path where Winlogbeat is copied.
.PARAMETER ForceLegacyPath
Option to use the old path instead of the new recommended path.
.EXAMPLE
PS> .\WL_Agent_Manager_Local.ps1 -service_name "winlogbeat" -new_version_path "winlogbeat" -WorkDir "C:\Program Files\winlogbeat" -ForceLegacyPath false
.SYNOPSIS
PowerShell script that installs/updates Winlogbeat locally..
#>

Param([string] $service_name = "winlogbeat")
Param([string] $new_version_path = "winlogbeat")
param([string] $WorkDir = "C:\Program Files\winlogbeat")
param([bool] $ForceLegacyPath = false)

Clear-Host

$date = Get-Date -Format "yyyy_MM_dd"
$log = "wl_agent_manager_local_$date.log"

$banner = @"
██╗    ██╗██╗       █████╗  ██████╗ ███████╗███╗   ██╗████████╗   ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
██║    ██║██║      ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝   ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
██║ █╗ ██║██║█████╗███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║█████╗██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
██║███╗██║██║╚════╝██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║╚════╝██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
╚███╔███╔╝███████╗ ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║      ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
 ╚══╝╚══╝ ╚══════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝v1.5
By Erick Rodriguez                                                                                                                              
"@
Write-Host $banner -ForegroundColor Green

Write-Output -InputObject "`n[*] Winlogbeat Local Installation/Update"
Write-Output -InputObject "[*] Execution start date: $(Get-Date)"
Write-Output -InputObject "[*] Winlogbeat's service name: $service_name"
Write-Output -InputObject "[*] New version path: $new_version_path"
Write-Output -InputObject "[*] Winlogbeat's path: $WorkDir`n"

"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append
"Author: Erick Roberto Rodriguez Rodri­guez" | Out-File -FilePath $log -Append
"Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" | Out-File -FilePath $log -Append
"GitHub: https://github.com/erickrr-bd/WL-Agent-Manager" | Out-File -FilePath $log -Append
"WL-Agent-Manager v1.5 - October 2025" | Out-File -FilePath $log -Append
"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append

Write-Output -InputObject "[*] Hostname: $(hostname)"
(Get-Date).ToString() + " INFO - Hostname: $(hostname)" | Out-File -FilePath $log -Append
Write-Output -InputObject "[*] Validating Winlogbeat's Service on server: $(hostname)"
(Get-Date).ToString() + " INFO - Validating Winlogbeat's Service on server: $(hostname)" | Out-File -FilePath $log -Append
$svc = Get-Service -Name $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
if ($null -ne $svc) {
    Write-Host -Object "[*] Winlogbeat's service exists on server: $(hostname)" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - Winlogbeat's service exists on server: $(hostname)" | Out-File -FilePath $log -Append
    Write-Output -InputObject "[*] Validating status of the Winlogbeat service on server:  $(hostname)"
    (Get-Date).ToString() + " INFO - Validating status of the Winlogbeat service on server:  $(hostname)" | Out-File -FilePath $log -Append
    $service_status = (Get-Service -Name "$service_name").status.ToString()
    Write-Host -Object "[*] Winlogbeat's service status: $service_status" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - Winlogbeat's service status on server: $service_status" | Out-File -FilePath $log -Append
    if($service_status -ne "Stopped"){
        Write-Output -InputObject "[*] Killing Winlogbeat's Service on server:  $(hostname)"
        (Get-Date).ToString() + " INFO - Killing Winlogbeat's Service on server:  $(hostname)" | Out-File -FilePath $log -Append
        Get-Process -Name $service_name -ErrorAction SilentlyContinue -ErrorVariable Err | Stop-Process -Force
        Start-Sleep -Seconds 3
        $proc = Get-Process -Name $service_name -ErrorAction SilentlyContinue
        if($null -eq $proc){
            Write-Host -Object "[*] Winlogbeat's Service killed on server: $(hostname)" -ForegroundColor Green
            (Get-Date).ToString() + " INFO - Winlogbeat's Service killed on server: $(hostname)" | Out-File -FilePath $log -Append
        }
        else{
            Write-Host -Object "[*] Winlogbeat's Service didn't kill on server: $(hostname)" -ForegroundColor Red
            (Get-Date).ToString() + " ERROR - Winlogbeat's Service didn't kill on server: $(hostname)" | Out-File -FilePath $log -Append
            (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append 
        }
    }
    Write-Output -InputObject "[*] Removing  Winlogbeat's Service on server:  $(hostname)"
    (Get-Date).ToString() + " INFO - Removing Winlogbeat's Service on server:  $(hostname)" | Out-File -FilePath $log -Append
    sc.exe delete $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
    if(Get-Service -Name $service_name -ErrorAction SilentlyContinue){
        Write-Host -Object "[*] Winlogbeat's service not removed on server: $(hostname)" -ForegroundColor Red
        (Get-Date).ToString() + " ERROR - Winlogbeat's service not removed on server: $(hostname)" | Out-File -FilePath $log -Append
        (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
    }
    else{
        Write-Host -Object "[*] Winlogbeat's service removed on server: $(hostname)" -ForegroundColor Green
        (Get-Date).ToString() + " INFO - Winlogbeat's service removed on server: $(hostname)" | Out-File -FilePath $log -Append
    }
} 
else {
    Write-Host -Object "[*] Winlogbeat's service doesn't exist on server: $(hostname)" -ForegroundColor Yellow
    (Get-Date).ToString() + " WARN - Winlogbeat's service doesn't exist on server: $(hostname)" | Out-File -FilePath $log -Append
    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
}
Write-Output -InputObject "[*] Creating Winlogbeat's Service on server:  $(hostname)"
(Get-Date).ToString() + " INFO - Creating Winlogbeat's Service on server: $(hostname)" | Out-File -FilePath $log -Append
try{
    $BasePath = "$env:ProgramFiles\Winlogbeat-Data"
    $LegacyDataPath = "$env:PROGRAMDATA\Winlogbeat"

    If ($ForceLegacyPath -eq $True) {
        $BasePath = $LegacyDataPath
    }
    elseif (Test-Path $LegacyDataPath) {
        Write-Output "[*] Files found at $LegacyDataPath, moving them to $BasePath"
        Try {
            Move-Item $LegacyDataPath $BasePath -ErrorAction Stop
        } Catch {
            Write-Output "[*] Could not move $LegacyDataPath to $BasePath"
            Write-Output "make sure the folder can be moved or set -ForceLegacyPath" 
            Write-Output "to force using $LegacyDataPath as the data path"
            Throw $_.Exception
        }
    }

    $HomePath = "$BasePath\Winlogbeat"
    $LogsPath = "$HomePath\logs"
    $KeystorePath = "$WorkDir\data\Winlogbeat.keystore"

    $FullCmd = "`"$WorkDir\winlogbeat.exe`" " +
               "--environment=windows_service " +
               "-c `"$WorkDir\winlogbeat.yml`" " +
               "--path.home `"$WorkDir`" " +
               "--path.data `"$HomePath`" " +
               "--path.logs `"$LogsPath`" " +
               "-E keystore.path=`"$KeyStorePath`" " +
               "-E logging.files.redirect_stderr=true"

    New-Service -name winlogbeat `
                -displayName Winlogbeat `
                -binaryPathName $FullCmd
}catch{
   Write-Output "[*] ERROR creating Winlogbeat's service"
}
$svc = Get-Service -Name $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
if ($null -ne $svc) {
     Write-Host -Object "`n[*] Winlogbeat's service created on server: $(hostname)" -ForegroundColor Green
     (Get-Date).ToString() + " INFO - Winlogbeat's service created on server: $(hostname)" | Out-File -FilePath $log -Append
}
else{
    Write-Host -Object "`n[*] Winlogbeat's service not created on server: $(hostname)" -ForegroundColor Red
    (Get-Date).ToString() + " ERROR - Winlogbeat's service not created on server: $(hostname)" | Out-File -FilePath $log -Append
    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
}
Write-Output -InputObject "[*] Validating whether Winlogbeat exists on server:  $(hostname)"
(Get-Date).ToString() + " INFO - Validating whether Winlogbeat exists on server:  $(hostname)" | Out-File -FilePath $log -Append
if(Test-Path -Path $WorkDir){
    Write-Host -Object "[*] Winlogbeat exists on server: $(hostname)" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - Winlogbeat exists on server: $(hostname)" | Out-File -FilePath $log -Append
    Write-Host -Object "[*] Removing Winlogbeat's current version on server: $(hostname)"
    (Get-Date).ToString() + " INFO - Removing Winlogbeat's current version on server: $(hostname)" | Out-File -FilePath $log -Append
    Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable Err
    Start-Sleep -Seconds 3
    if(Test-Path -Path $WorkDir){
        Write-Host -Object "[*] Winlogbeat not removed on server: $(hostname)" -ForegroundColor Red
        (Get-Date).ToString() + " ERROR - Winlogbeat not removed on server: $(hostname)" | Out-File -FilePath $log -Append
        (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
    }
    else{
        Write-Host -Object "[*] Winlogbeat removed on server: $(hostname)" -ForegroundColor Green
        (Get-Date).ToString() + " INFO - Winlogbeat removed on server: $(hostname)" | Out-File -FilePath $log -Append
    }
}
else{
     Write-Host -Object "[*] Winlogbeat doesn't exist on server: $(hostname)" -ForegroundColor Yellow
     (Get-Date).ToString() + " WARN - Winlogbeat doesn't exist on server: $(hostname)" | Out-File -FilePath $log -Append
}
Write-Output -InputObject "[*] Copying Winlogbeat on server: $(hostname)"
(Get-Date).ToString() + " INFO - Copying Winlogbeat on server: $(hostname)" | Out-File -FilePath $log -Append
Copy-Item -Path $new_version_path -Destination $WorkDir -Recurse -ErrorAction SilentlyContinue -ErrorVariable Err
if(Test-Path -Path $WorkDir){
    Write-Host -Object "[*] Winlogbeat's copied on server: $(hostname)" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - Winlogbeat's copied on server: $(hostname)" | Out-File -FilePath $log -Append
}
else{
    Write-Host -Object "[*] Winlogbeat's not copied on server: $(hostname)" -ForegroundColor Red
    (Get-Date).ToString() + " ERROR - Winlogbeat's not copied on server: $(hostname)" | Out-File -FilePath $log -Append
    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
}
Write-Output -InputObject "[*] Starting Winlogbeat's service on server: $(hostname)"
(Get-Date).ToString() + " INFO - Starting Winlogbeat's service on server: $(hostname)" | Out-File -FilePath $log -Append
Start-Service -Name $service_name
Start-Sleep 3
$service_status = (Get-Service -Name "$service_name").status.ToString()
Write-Host -Object "[*] Winlogbeat's service status: $service_status" -ForegroundColor Green
(Get-Date).ToString() + " INFO - Winlogbeat's service status on server: $service_status" | Out-File -FilePath $log -Append
Write-Output -InputObject "`n[*] Execution completion date: $(Get-Date)"