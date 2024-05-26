<#
 
.SYNOPSIS:
    Intune Autopilot Cleanup Powershell action can delete devices from Intune that are no longer needed, or disposed during Hardware Refresh Program.
    The Delete action immediately removes the device immediately from the Intune Device List and issues a Retire action on the device.
    After delete action it find the Device Hardware Hashes in Intune Autopilot Collection and deletes it and removes the device from Microsoft Entra ID.
    Script input requires a Single or mutiple Device Serial Number as parameter.

.Description:
    IntuneAutopilotCleanup.ps1 is a PowerShell script to find Intune Enrolled Device information from Microsoft Endpoint Management and Microsoft Entra ID.
    Then it deletes the Enrolled Device and Remove Hardware Hashes from Microsoft Endpoint. Finally, it deletes the device from Microsoft Entra ID. 

.AUTHOR:
    Sumanjit Pan

.Version:
    1.0 

.Date: 
    24th May, 2024

.First Publish Date:
    24th May, 2024

#>

param (
    [string[]]$SerialNumbers
)

Function CheckInternet
{
$statuscode = (Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc).statuscode
if ($statuscode -ne 200){
''
''
Write-Host "Operation aborted. Unable to connect to Microsoft Graph, please check your internet connection." -ForegroundColor Red
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
    Import-Module -Name 'Microsoft.Graph.DeviceManagement','Microsoft.Graph.DeviceManagement.Actions','Microsoft.Graph.DeviceManagement.Enrollment','Microsoft.Graph.Identity.DirectoryManagement'
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
Write-Host '                                  Intune Autopilot Device Cleanup                                                ' -ForegroundColor Green
'===================================================================================================='

''                    
Write-Host "                                          IMPORTANT NOTES                                           " -ForegroundColor Red 
Write-Host "===================================================================================================="
Write-Host "This source code is freeware and is provided on an 'as is' basis without warranties of any kind," -ForegroundColor Yellow 
Write-Host "whether express or implied, including without limitation warranties that the code is free of defect," -ForegroundColor Yellow 
Write-Host "fit for a particular purpose or non-infringing. The entire risk as to the quality and performance of" -ForegroundColor Yellow 
Write-Host "the code is with the end user." -ForegroundColor yellow 
''
Write-Host "The Delete action immediately removes the device immediately from the Intune Device List and issues" -ForegroundColor Yellow 
Write-Host "a Retire action on the device. After delete action it find the Device Hardware Hashes in Intune" -ForegroundColor Yellow
Write-Host "Autopilot Collection and deletes it. Finally, it removes the device from Microsoft Entra ID." -ForegroundColor Yellow
''
Write-Host "For more information, kindly visit the below links:" -ForegroundColor yellow 
Write-Host "https://learn.microsoft.com/en-us/graph/api/intune-devices-manageddevice-delete?view=graph-rest-1.0&tabs=http" -ForegroundColor yellow
Write-Host "https://learn.microsoft.com/en-us/graph/api/intune-enrollment-windowsautopilotdeviceidentity-delete?view=graph-rest-1.0&tabs=http" -ForegroundColor Yellow
Write-Host "https://learn.microsoft.com/en-us/managed-desktop/operate/remove-devices" -ForegroundColor Yellow
"===================================================================================================="
''

CheckInternet
CheckMSGraph




if ($SerialNumbers) {
    foreach ($SerialNumber in $SerialNumbers) {
        # Check if device exists in Intune
        Write-Host "Searching the Device in Intune with Serial Number '$SerialNumber'....." -ForegroundColor Cyan
        $IntuneDevices = Get-MgDeviceManagementManagedDevice -Filter "contains(serialNumber,'$SerialNumber')"
        
        if ($IntuneDevices) {
            foreach ($IntuneDevice in $IntuneDevices) {
                Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $IntuneDevice.Id
                Write-Host "Device with serial number '$($SerialNumber)' found and removed from Intune." -ForegroundColor Green
            }
        } else {
            Write-Host "Device with serial number '$($SerialNumber)' not found in Intune." -ForegroundColor Yellow
        }

        # Check if device exists in Intune Autopilot Collection
        Write-Host "Searching the Device in Intune Autopilot Collection with Serial Number '$SerialNumber'....." -ForegroundColor Cyan
        $ApDevices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -Filter "contains(serialNumber,'$SerialNumber')"

        if ($ApDevices) {
            foreach ($ApDevice in $ApDevices) {
                Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -WindowsAutopilotDeviceIdentityId $ApDevice.Id
                Write-Host "Device with serial number '$($SerialNumber)' found and removed from Windows Autopilot." -ForegroundColor Green
            }
        } else {
            Write-Host "Device with serial number '$($SerialNumber)' not found in Intune Autopilot Collection." -ForegroundColor Yellow
        }

        # Check if device exists in Azure AD
        Write-Host "Searching the Device in Azure AD with Serial Number '$SerialNumber'....." -ForegroundColor Cyan
        $ApDeviceIds = $ApDevices | Select-Object -ExpandProperty AzureActiveDirectoryDeviceId

        if ($ApDeviceIds) {
            foreach ($DeviceId in $ApDeviceIds) {
                $Devices = Get-MgDevice -Filter "DeviceId eq '$DeviceId'"
                foreach ($Device in $Devices) {
                    Remove-MgDevice -DeviceId $Device.Id
                    Write-Host "Device with serial number '$($SerialNumber)' found and removed from Azure AD." -ForegroundColor Green
                }
            }
        } else {
            $AADDevices = Get-MgDevice -Filter "DisplayName eq 'Prefix-$($SerialNumber)'" 
            # Prefix Example: MSFT- #
            if ($AADDevices) {
                foreach ($AADDevice in $AADDevices) {
                    Remove-MgDevice -DeviceId $AADDevice.Id
                    Write-Host "Device with serial number '$($SerialNumber)' found and removed from Azure AD." -ForegroundColor Magenta
                }
            } else {
                Write-Host "Device with serial number '$($SerialNumber)' not found in Azure AD." -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "Enter the device serial Number as parameter (Example: .\IntuneAutopilotCleanup.ps1 -SerialNumbers 'SERIAL')" -ForegroundColor Red
}