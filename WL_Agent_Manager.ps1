<#
.Description
Script that installs or updates the Winlogbeat agent remotely on the server.
.PARAMETER hosts_file
File with the hostnames.
.PARAMETER service_name
Winlogbeat's service name.
.PARAMETER new_version_path
Path corresponding to the Winlogbeat's version to install/update.
.PARAMETER WorkDir
Path where Winlogbeat is copied.
.PARAMETER ForceLegacyPath
Option to use the old path instead of the new recommended path.
.EXAMPLE
PS> .\WL_Agent_Manager_Local.ps1 -hosts_file "hosts.txt" -service_name "winlogbeat" -new_version_path "winlogbeat" -WorkDir "C:\Program Files\winlogbeat" -ForceLegacyPath false
.SYNOPSIS
PowerShell script that installs/updates Winlogbeat remotely.
#>

Param([string] $hosts_file = "hosts_update.txt")
Param([string] $service_name = "winlogbeat")
Param([string] $new_version_path = "winlogbeat")
param([string] $WorkDir = "C:\Program Files\winlogbeat")
param([bool] $ForceLegacyPath = false)

Clear-Host

$date = Get-Date -Format "yyyy_MM_dd"
$log = "wl_agent_manager_$date.log"

$banner = @"
██╗    ██╗██╗       █████╗  ██████╗ ███████╗███╗   ██╗████████╗   ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
██║    ██║██║      ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝   ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
██║ █╗ ██║██║█████╗███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║█████╗██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
██║███╗██║██║╚════╝██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║╚════╝██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
╚███╔███╔╝███████╗ ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║      ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
 ╚══╝╚══╝ ╚══════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝v1.5
By Erick Rodríguez                                                                                                                              
"@
Write-Host $banner -ForegroundColor Green

Write-Output -InputObject "`n[*] Winlogbeat Remote Installation/Update"
Write-Output -InputObject "[*] Execution start date: $(Get-Date)"
Write-Output -InputObject "[*] Hosts File: $hosts_file"
Write-Output -InputObject "[*] Winlogbeat's service name: $service_name"
Write-Output -InputObject "[*] New version path: $new_version_path"
Write-Output -InputObject "[*] Winlogbeat's path: $WorkDir`n"

"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append
"Author: Erick Roberto Rodríguez Rodríguez" | Out-File -FilePath $log -Append
"Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" | Out-File -FilePath $log -Append
"GitHub: https://github.com/erickrr-bd/WL-Agent-Manager" | Out-File -FilePath $log -Append
"WL-Agent-Manager v1.5 - October 2025" | Out-File -FilePath $log -Append
"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append
"`n[*] Execution start date: $(Get-Date)" | Out-File -FilePath $log -Append
"[*] Hosts File: $hosts_file" | Out-File -FilePath $log -Append
"[*] Winlogbeat's service name: $service_name" | Out-File -FilePath $log -Append
"[*] New version path: $new_version_path" | Out-File -FilePath $log -Append
"[*] Winlogbeat's path: $WorkDir`n" | Out-File -FilePath $log -Append

$hosts_list = Get-Content -Path $hosts_file -ErrorAction SilentlyContinue -ErrorVariable Err
if(-not $?){
    Write-Host -Object "`n[*] File not found: $hosts_file" -ForegroundColor Red
    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
}
else{
    Write-Host -Object "`n[*] File found: $hosts_file" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - File found: $hosts_file" | Out-File -FilePath $log -Append
    foreach($hostname in $hosts_list){
        Write-Output -InputObject "`n[*] Server: $hostname"
        (Get-Date).ToString() + " INFO - Server: $hostname" | Out-File -FilePath $log -Append
        Write-Output -InputObject "[*] Validating connection via WinRM with the server: $hostname"
        (Get-Date).ToString() + " INFO - Validating connection via WinRM with the server: $hostname" | Out-File -FilePath $log -Append
        $winrm_validation = Test-WSMan -ComputerName $hostname -ErrorAction SilentlyContinue -ErrorVariable Err
        if($winrm_validation){
            Write-Host -Object "[*] WinRM connection allowed with the server: $hostname" -ForegroundColor Green
            (Get-Date).ToString() + " INFO - WinRM connection allowed with the server: $hostname" | Out-File -FilePath $log -Append
            Write-Output -InputObject "[*] Validating Winlogbeat's Service on server: $hostname"
            (Get-Date).ToString() + " INFO - Validating Winlogbeat's Service on server: $hostname" | Out-File -FilePath $log -Append
            $winlogbeat_exists = Invoke-Command -ComputerName $hostname -ScriptBlock {
                param($service_name)
                $svc = Get-Service -Name $service_name -ErrorAction SilentlyContinue
                if ($null -ne $svc) {
                    return "OK"
                } 
                else {
                    return "NOTFOUND"
                }
            } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_exists -eq "OK"){
                Write-Host -Object "[*] Winlogbeat's Service exists on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's Service exists on server: $hostname" | Out-File -FilePath $log -Append
                Write-Output -InputObject "[*] Validating status of the Winlogbeat's Service on server:  $hostname"
                (Get-Date).ToString() + " INFO - Validating status of the Winlogbeat's Service on server:  $hostname" | Out-File -FilePath $log -Append
                $service_status = Invoke-Command -ComputerName $hostname -ScriptBlock{
                    param($service_name)
                    $service_status = (Get-Service -Name "$service_name").status.ToString()
                    return $service_status
                } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
                Write-Host -Object "[*] Winlogbeat's Service status: $service_status" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's Service status on server: $service_status" | Out-File -FilePath $log -Append
                if($service_status -ne "Stopped"){
                    Write-Output -InputObject "[*] Killing Winlogbeat's Service on server:  $hostname"
                    (Get-Date).ToString() + " INFO - Killing Winlogbeat's Service on server:  $hostname" | Out-File -FilePath $log -Append
                    $service_stopping = Invoke-Command -ComputerName $hostname -ScriptBlock{
                        param($service_name)
                        Get-Process -Name $service_name -ErrorAction SilentlyContinue | Stop-Process -Force
                        Start-Sleep -Seconds 5
                        $proc = Get-Process -Name $service_name -ErrorAction SilentlyContinue
                        if($null -eq $proc){
                            return "OK"
                        }
                        else{
                            return "ERROR"
                        }
                    } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
                    if($service_stopping -ne "OK"){
                        Write-Host -Object "[*] Winlogbeat's Service didn't kill on server: $hostname" -ForegroundColor Red
                        (Get-Date).ToString() + " ERROR - Winlogbeat's Service didn't kill on server: $hostname" | Out-File -FilePath $log -Append
                        (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                    }
                    else{
                        Write-Host -Object "[*] Winlogbeat's Service killed on server: $hostname" -ForegroundColor Green
                        (Get-Date).ToString() + " INFO - Winlogbeat's Service killed on server: $hostname" | Out-File -FilePath $log -Append
                        Write-Output -InputObject "[*] Removing  Winlogbeat's Service on server:  $hostname"
                        (Get-Date).ToString() + " INFO - Removing Winlogbeat's Service on server:  $hostname" | Out-File -FilePath $log -Append
                        $winlogbeat_removed = Invoke-Command -ComputerName $hostname -ScriptBlock{
                            param($service_name)
                            sc.exe delete $service_name
                            if(Get-Service -Name $service_name -ErrorAction SilentlyContinue){
                                return "ERROR"
                            }
                            else{
                                return "OK"
                            }
                        } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
                        if($winlogbeat_removed -eq "OK"){
                            Write-Host -Object "[*] Winlogbeat's Service removed on server: $hostname" -ForegroundColor Green
                            (Get-Date).ToString() + " INFO - Winlogbeat's Service removed on server: $hostname" | Out-File -FilePath $log -Append
                        }
                        else{
                            Write-Host -Object "[*] Winlogbeat's Service not removed on server: $hostname" -ForegroundColor Red
                            (Get-Date).ToString() + " ERROR - Winlogbeat's Service not removed on server: $hostname" | Out-File -FilePath $log -Append
                            (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                        }
                    }
                }
                else{
                    Write-Output -InputObject "[*] Removing  Winlogbeat's Service on server:  $hostname"
                    (Get-Date).ToString() + " INFO - Removing Winlogbeat's Service on server:  $hostname" | Out-File -FilePath $log -Append
                    $winlogbeat_removed = Invoke-Command -ComputerName $hostname -ScriptBlock{
                        param($service_name)
                        sc.exe delete $service_name
                        if(Get-Service -Name $service_name -ErrorAction SilentlyContinue){
                            return "ERROR"
                        }
                        else{
                            return "OK"
                        }
                    } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
                    if($winlogbeat_removed -eq "OK"){
                        Write-Host -Object "[*] Winlogbeat's Service removed on server: $hostname" -ForegroundColor Green
                        (Get-Date).ToString() + " INFO - Winlogbeat's Service removed on server: $hostname" | Out-File -FilePath $log -Append
                    }
                    else{
                        Write-Host -Object "[*] Winlogbeat's Service not removed on server: $hostname" -ForegroundColor Red
                        (Get-Date).ToString() + " ERROR - Winlogbeat's Service not removed on server: $hostname" | Out-File -FilePath $log -Append
                        (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                    }
                }
            }
            else{
                Write-Host -Object "[*] Winlogbeat's Service doesn't exist on server: $hostname" -ForegroundColor Yellow
                (Get-Date).ToString() + " WARN - Winlogbeat's Service doesn't exist on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "[*] Creating Winlogbeat's Service on server:  $hostname"
            (Get-Date).ToString() + " INFO - Creating Winlogbeat's Service on server:  $hostname" | Out-File -FilePath $log -Append
            $winlogbeat_created = Invoke-Command -ComputerName $hostname -ScriptBlock{
                param($WorkDir, $ForceLegacyPath)
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
                    return "OK"
                }catch{
                    return "ERROR"
                }   
            } -ArgumentList $WorkDir, $ForceLegacyPath -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_created -eq "OK"){
                Write-Host -Object "[*] Winlogbeat's Service created on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's Service created on server: $hostname" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host -Object "[*] Winlogbeat's Service not created on server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " ERROR - Winlogbeat's Service not created on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "[*] Validating whether the Winlogbeat exists on server:  $hostname"
            (Get-Date).ToString() + " INFO - Validating whether the Winlogbeat exists on server:  $hostname" | Out-File -FilePath $log -Append
            $winlogbeat_path = Invoke-Command -ComputerName $hostname -ScriptBlock{
                param($WorkDir)
                if(Test-Path -Path $WorkDir){
                    return "OK"
                }
                else{
                    return "NOTFOUND"
                } 
            } -ArgumentList $WorkDir -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_path -eq "OK"){
                Write-Host -Object "[*] Winlogbeat exists on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat exists on server: $hostname" | Out-File -FilePath $log -Append
                Write-Host -Object "[*] Removing Winlogbeat on server: $hostname"
                (Get-Date).ToString() + " INFO - Removing Winlogbeat on server: $hostname" | Out-File -FilePath $log -Append
                $winlogbeat_path_removed = Invoke-Command -ComputerName $hostname -ScriptBlock{
                    param($WorkDir)
                    Remove-Item -Path $WorkDir -Recurse -Force
                    Start-Sleep -Seconds 3
                    if(Test-Path -Path $WorkDir){
                        return "ERROR"
                    }
                    else{
                        return "OK"
                    }
                } -ArgumentList $WorkDir -ErrorAction SilentlyContinue -ErrorVariable Err
                if($winlogbeat_path_removed -eq "OK"){
                     Write-Host -Object "[*] Winlogbeat removed on server: $hostname" -ForegroundColor Green
                    (Get-Date).ToString() + " INFO - Winlogbeat removed on server: $hostname" | Out-File -FilePath $log -Append
                }
                else{
                    Write-Host -Object "[*] Winlogbeat not removed on server: $hostname" -ForegroundColor Red
                    (Get-Date).ToString() + " ERROR - Winlogbeat not removed on server: $hostname" | Out-File -FilePath $log -Append
                    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                }
            }
            else{
                Write-Host -Object "[*] Winlogbeat doesn't exist on server: $hostname" -ForegroundColor Yellow
                (Get-Date).ToString() + " WARN - Winlogbeat doesn't exist on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "[*] Copying Winlogbeat on server: $hostname"
            (Get-Date).ToString() + " INFO - Copying Winlogbeat on server: $hostname" | Out-File -FilePath $log -Append
            $sess = New-PSSession -ComputerName $hostname
            Copy-Item -Path $new_version_path -Destination $WorkDir -ToSession $sess -Recurse
            $winlogbeat_copied = Invoke-Command -ComputerName $hostname -ScriptBlock{
                param($WorkDir)
                if(Test-Path -Path $WorkDir){
                    return "OK"
                }
                else{
                    return "ERROR"
                } 
            } -ArgumentList $workDir -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_copied -eq "OK"){
                Write-Host -Object "[*] Winlogbeat copied on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat copied on server: $hostname" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host -Object "[*] Winlogbeat not copied on server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " ERROR - Winlogbeat not copied on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "[*] Starting Winlogbeat's Service on server: $hostname"
            (Get-Date).ToString() + " INFO - Starting Winlogbeat's Service on server: $hostname" | Out-File -FilePath $log -Append
            $winlogbeat_started = Invoke-Command -ComputerName $hostname -ScriptBlock{
                param($service_name)
                Start-Service -Name $service_name
                Start-Sleep 3
                $service_status = (Get-Service -Name "$service_name").status.ToString()
                return $service_status
            } -ArgumentList $service_name -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_started -eq "Running"){
                Write-Host -Object "[*] Winlogbeat's Service started on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's Service started on server: $hostname" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host -Object "[*] Winlogbeat's Service not started on server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " ERROR - Winlogbeat's Service not started on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
        }
        else{
            Write-Host -Object "[*] WinRM connection not allowed with the server: $hostname" -ForegroundColor Red
            (Get-Date).ToString() + " ERROR - WinRM connection not allowed with the server: $hostname" | Out-File -FilePath $log -Append
            (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
        }
    }
}