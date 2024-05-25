<#
 
.SYNOPSIS:
    Intune Wipe Powershell action can remove devices from Intune that are no longer needed, being repurposed, or missing.
    The Wipe device action restores a device to its factory default settings.
    Script input requires a or mutiple Device Name/Host Name or Device Serial Number for Wipe the device as parameter.

.Description:
    IntuneRemoteWipe.ps1 is a PowerShell script to find Intune Enrolled Device information from Microsoft Endpoint Management and Wipe the device. 

.AUTHOR:
    Sumanjit Pan

.Version:
    1.0 

.Date: 
    16th May, 2024

.First Publish Date:
    16th May, 2024

#>

param (
    [string[]]$DeviceNames,
    [string[]]$Serials
)

Function CheckInternet
{
$statuscode = (Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc).statuscode
if ($statuscode -ne 200){
''
''
Write-Host "Operation aborted. Unable to connect to Microsoft Graph, please check your internet connection." -ForegroundColor red -BackgroundColor Black
exit
}
}

Function CheckMSGraph{
''
Write-Host "Checking Microsoft Graph Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable | Where-Object {$_.Name -like "Microsoft.Graph"}) 
    {
    Write-Host "Microsoft Graph Module has installed." -ForegroundColor Green
    Import-Module -Name 'Microsoft.Graph.DeviceManagement','Microsoft.Graph.DeviceManagement.Actions'
    Write-Host "Microsoft Graph Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else
    {
    Write-Host "Microsoft Graph Module is not installed." -ForegroundColor Red
    ''
    Write-Host "Installing Microsoft Graph Module....." -ForegroundColor Yellow
    Install-Module -Name "Microsoft.Graph" -Force
                                
    if (Get-Module -ListAvailable | Where-Object {$_.Name -like "Microsoft.Graph"}) {                                
    Write-Host "Microsoft Graph Module has installed." -ForegroundColor Green
    Import-Module -Name 'Microsoft.Graph.DeviceManagement','Microsoft.Graph.DeviceManagement.Actions'
    Write-Host "Microsoft Graph Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else
    {
    ''
    ''
    Write-Host "Operation aborted. Microsoft Graph Module was not installed." -ForegroundColor Red
    Exit}
    }

Write-Host "Connecting to Microsoft Graph PowerShell..." -ForegroundColor Magenta

Connect-MgGraph -ClientId "App Client ID" -TenantId "Entra ID Tenant ID" -NoWelcome

$MgContext= Get-mgContext

Write-Host "User '$($MgContext.Account)' has connected to TenantId '$($MgContext.TenantId)' Microsoft Graph API successfully." -ForegroundColor Green
''
''
}

Cls
'===================================================================================================='
Write-Host '                                        Intune Remote Wipe                                                ' -ForegroundColor Green
'===================================================================================================='

''                    
Write-Host "                                          IMPORTANT NOTES                                           " -ForegroundColor red 
Write-Host "===================================================================================================="
Write-Host "This source code is freeware and is provided on an 'as is' basis without warranties of any kind," -ForegroundColor yellow 
Write-Host "whether express or implied, including without limitation warranties that the code is free of defect," -ForegroundColor yellow 
Write-Host "fit for a particular purpose or non-infringing. The entire risk as to the quality and performance of" -ForegroundColor yellow 
Write-Host "the code is with the end user." -ForegroundColor yellow 
''
Write-Host "By using the Wipe actions, you can remove devices from Intune that are no longer needed, being" -ForegroundColor yellow 
Write-Host "repurposed, or missing. The Wipe device action restores a device to its factory default settings." -ForegroundColor yellow  
''
Write-Host "A wipe is useful for resetting a device before you give the device to a new user, or when the" -ForegroundColor yellow 
Write-Host "device has been lost or stolen. Be careful about selecting Wipe. Data on the device can't be" -ForegroundColor yellow 
Write-Host "recovered. The method that 'Wipe' uses to remove data is simple file deletion, and the drive is" -ForegroundColor yellow 
Write-Host "BitLocker decrypted as part of this process. " -ForegroundColor yellow 
''
Write-Host "For more information, kindly visit the below links:" -ForegroundColor yellow 
Write-Host "https://learn.microsoft.com/en-us/graph/api/intune-devices-manageddevice-wipe?view=graph-rest-1.0&tabs=http" -ForegroundColor yellow
Write-Host "https://learn.microsoft.com/en-us/mem/intune/remote-actions/devices-wipe" -ForegroundColor yellow

"===================================================================================================="
''

CheckInternet
CheckMSGraph

if ($DeviceNames) {
    foreach ($DeviceName in $DeviceNames) {
        Write-Host "Searching Intune Devices with Device Name or Hostname '$DeviceName'....." -ForegroundColor Cyan
        $IntuneDevices = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$DeviceName'"
        if ($IntuneDevices) {
            foreach ($IntuneDevice in $IntuneDevices) {
                Write-Host "Hostname or Device Name '$DeviceName' found in Intune. Initiating remote wipe....." -ForegroundColor Green
                Clear-MgDeviceManagementManagedDevice -ManagedDeviceId $IntuneDevice.Id
                Write-Host "Remote wipe initiated for Hostname or Device Name '$DeviceName'. Please keep the device online for at least an hour." -ForegroundColor Green
            }
        } else {
            Write-Host "'Hostname or Device Name '$DeviceName' not found in Intune or already removed from Intune." -ForegroundColor Yellow
        }
    }
}
elseif ($Serials) {
    foreach ($Serial in $Serials) {
        Write-Host "Searching Intune Devices with Serial Number '$Serial'..... " -ForegroundColor Cyan
        $IntuneDevices = Get-MgDeviceManagementManagedDevice -Filter "contains(serialNumber,'$Serial')"
        if ($IntuneDevices) {
            foreach ($IntuneDevice in $IntuneDevices) {
                Write-Host "Device with Serial Number'$Serial' found in Intune. Initiating remote wipe....." -ForegroundColor Green
                Clear-MgDeviceManagementManagedDevice -ManagedDeviceId $IntuneDevice.Id
                Write-Host "Remote wipe initiated for Device with Serial Number '$Serial'. Please keep the device online for at least an hour." -ForegroundColor Green
            }
        } else {
            Write-Host "Device with Serial Number '$Serial' not found in Intune or already removed from Intune." -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "Enter the Device Name or Serial Number as parameters. (Example: .\IntuneRemoteWipe.ps1 -Serials 'SERIAL')" -ForegroundColor Red
}
