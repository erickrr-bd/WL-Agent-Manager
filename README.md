# WL-Agent-Manager v1.5

Winlogbeat reads from one or more event logs using Windows APIs, filters the events based on user-configured criteria, then sends the event data to the configured outputs (Elasticsearch or Logstash).

For more information:

[https://www.elastic.co/es/beats/winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/current/_winlogbeat_overview.html)

It's a tool that installs/updates the Winlogbeat agent (Elastic) on Windows systems through the domain controller and WinRM.

Born from the need to have a tool that is easy to run and use. Ideal if the automated and massive installation/update of Winlogbeat is required in your organization.

# Characteristics
- Remote installation/update via domain controller and WinRM
- Generate a log file with the process

# Requirements
- Domain Controller server (DC)
- PowerShell (A recent version is recommended)
- PowerShell Console (Executed with administrator permissions)
- Script execution enabled (Otherwise, run `Set-ExecutionPolicy Unrestricted`)
- WinRM service enabled (DC and clients)
- Port 5985 open (DC and clients)

# Running

```
usage: ./Tekium_Winlogbeat_Update_Script.ps1 [-hosts_file]

optional arguments:
  -hosts_file       Hostnames file name (default: hosts_update.txt)
```

By default, the script takes the hostnames from the "hosts_update.txt" file. Both the Winlogbeat folder and the file with the hostnames must be at the same directory level as the script.

This can be changed using the parameter: "hosts_file", where the name of the file or path from which the hostnames are read is indicated.

For example:

`.\Tekium_Winlogbeat_Update_Script.ps1 -hosts_file “archivo_hostnames.txt"`

The file's structure with the hostsnames must be the following. It's recommended to use hostnames instead of IP addresses, this way you avoid entering authentication credentials.

```
HOST1
HOST2
HOST3
HOSTWINDOWS
BDWINDOWS
DEVWINDOWS
```
# Generate executable file on Windows systems

It's possible to generate an executable for Windows systems (.exe) using the ps2exe tool. To do this, you must first install the plugin:

`Install-Module ps2exe`

To generate the executable you must use the tool as follows:

`ps2exe .\Tekium_Winlogbeat_Update_Script.ps1 .\Tekium_Winlogbeat_Update_Script.exe`

For more information:
[ps2exe tool](https://github.com/MScholtes/PS2EXE)

# Example output

```
-------------------------------------------------------------------------------------
Copyright©Tekium 2024. All rights reserved.
Author: Erick Roberto Rodríguez Rodríguez
Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com
GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script
Tekium-Winlogbeat-Update-Script v1.4.1 - May 2024
-------------------------------------------------------------------------------------

Execution start date: 04/27/2024 12:45:24
Hosts File: hosts.txt

27/04/2024 12:45:24 p. m. INFO - File found: hosts.txt
27/04/2024 12:45:38 p. m. INFO - Connection established with the server: WIN-9ACUHHQQNHM
27/04/2024 12:45:38 p. m. INFO - Winlogbeat service exists on server: WIN-9ACUHHQQNHM
27/04/2024 12:45:40 p. m. INFO - Status: Stopped on server: WIN-9ACUHHQQNHM
27/04/2024 12:45:40 p. m. INFO - Winlogbeat found on server: WIN-9ACUHHQQNHM
27/04/2024 12:45:40 p. m. INFO - Winlogbeat removed from server: WIN-9ACUHHQQNHM
27/04/2024 12:45:51 p. m. INFO - Winlogbeat installed/updated on server: WIN-9ACUHHQQNHM
27/04/2024 12:45:51 p. m. INFO - Status: Running on server: WIN-9ACUHHQQNHM
27/04/2024 12:45:53 p. m. ERROR - Failed to connect to server: PRUEBA
27/04/2024 12:45:53 p. m. ERROR - <f:WSManFault xmlns:f="http://schemas.microsoft.com/wbem/wsman/1/wsmanfault" Code="2150859193" Machine="WIN-2RER8RSOGA2.Tekium.com"><f:Message>El cliente WinRM no puede procesar la solicitud porque no puede resolverse el nombre de servidor. </f:Message></f:WSManFault>

Execution end date: 04/27/2024 12:45:54
```
