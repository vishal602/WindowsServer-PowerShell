####################################################################################################
#
# PowerShell Script of
#
# Set IP address and PC name of Windows Server 2019
#
# Created on 2022.5.19
#
# Note : Setting of IP address and PC name should be done before setting of Active Directory
#        In this script, following items are also treated or comfirmed:
#            Installation of Google Chrome
#            Existence of .NET Framework 4.8 (only confirmation)
#            Firewall setting for SQL Server
#
# Reference : -
#
####################################################################################################

######################################################################
#
# Set IP address and PC name before setting Active Directory
#
######################################################################

##############################
# Set IP address
##############################

## Set your appropriate value
$IPAddress = "192.168.1.10"
$DefaultGateway = "192.168.1.1"

## Set your appropriate value for DNS address
## Azure DNS address, 168.63.129.16
$DNSAddress = "168.63.129.16"

## Set your appropriate value
$PCNAME = "PC01"

Get-NetAdapter | New-NetIPAddress -AddressFamily `
 IPv4 -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway

Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DNSAddress

##############################
# Install Google Chrome
##############################

$GChrome = Read-Host "Do you wish to install Google Chrome? [Y/N]"

if( $GChrome -eq "Y"){

    Write-Host "Install Google Chrome" -ForegroundColor Yellow
    $Path = $env:TEMP
    $Installer = "chrome_installer.exe"
    Invoke-WebRequest `
     "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26browser%3D0%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26brand%3DGTPM/update2/installers/ChromeSetup.exe" `
     -OutFile $Path\$Installer
    Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait
    Remove-Item $Path\$Installer

    }else{

    Write-Host "Not install Google Chrome" -ForegroundColor Yellow
}

########################################
# Check existence of .NET Framework 4.8 (only confirmation)
########################################

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 

Write-Host "$date Checking if .NET Framework 4.8 is installed" -ForegroundColor Yellow

$net_framework_48 = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528040

<#
.Net Framework version  Release REG_DWORD
.NET Framework 4.5      378389
.NET Framework 4.5.1    378675
.NET Framework 4.5.2    379893
.NET Framework 4.6      393295
.NET Framework 4.6.1    394254
.NET Framework 4.6.2    394802
.NET Framework 4.7      460798
.NET Framework 4.7.1    461308
.NET Framework 4.7.2    461808
.NET Framework 4.8      528040
#>

if ($net_framework_48 -eq $True)
{
$message = ".NET Framework 4.8 is installed on the server"
Write-Host $message -ForegroundColor Yellow
}
else
{
$message = ".NET Framework 4.8 is missing on the server, please reach out to the Provisioning team and ask them to install .NET Framework 4.8"
Write-Host $message -ForegroundColor Yellow
# exit
}

########################################
# Firewall setting
########################################

## for SQL Server

$FWSQL = Read-Host "Do you wish to set firewall of port for SQL Server (port TCP1433, UDP1434)? [Y/N]"

    if( $FWSQL -eq "Y"){
        Write-Host "Set firewall of port for SQL Server" -ForegroundColor Yellow

        New-NetFirewallRule -DisplayName "SQL Server Remote 1433" `
         -Direction inbound -Profile Any -Action Allow -LocalPort 1433 -Protocol TCP

        New-NetFirewallRule -DisplayName "SQL Server Remote 1434" `
         -Direction inbound -Profile Any -Action Allow -LocalPort 1434 -Protocol UDP

        }else{

        Write-Host "Not set firewall of port for SQL Server" -ForegroundColor Yellow
    }

########################################
# Rename PC Name
########################################

$RePCName = Read-Host "Do you wish to rename PC name? [Y/N]"

    if( $RePCName -eq "Y"){
        Write-Host "Rename PC name" -ForegroundColor Yellow

        Rename-Computer $PCNAME -Restart -Force

        }else{

        Write-Host "Not rename PC name" -ForegroundColor Yellow
    }

Write-Host "Setting has been completed !" -ForegroundColor Yellow
