<#
.SYNOPSIS
    The PowerShell script automates the management of BitLocker encryption on the system drive. It verifies if BitLocker is protecting the drive,
    retrieves the recovery key protector ID, and attempts to back up the recovery key to Azure Active Directory (AAD). The script ensures system
    security by confirming BitLocker protection and provides a streamlined process for safeguarding recovery keys in Azure AD, enhancing data
    recovery capabilities and administrative oversight.

.DESCRIPTION
    BitLockerManagement.ps1 is a PowerShell script designed to automate BitLocker encryption management tasks. The script performs the following actions:
    
    1. Checks if BitLocker is protecting the system drive.
    2. Retrieves the recovery key protector ID for the system drive.
    3. Attempts to back up the BitLocker recovery key to Azure Active Directory (AAD).

    Script execution requires administrative privileges and handles common scenarios such as verifying BitLocker protection status and securely storing recovery keys.

.AUTHOR
    Sumanjit Pan

.Version
    1.2

.Date
    15th June, 2024

.First Publish Date
    12th April, 2022
#>

# Define the system drive letter
$DriveLetter = $env:SystemDrive

# Function to test if BitLocker is protecting the specified drive
function Test-Bitlocker {
    param (
        [string]$BitlockerDrive
    )
    # Check if BitLocker is protecting the drive
    if (-not (Get-BitLockerVolume -MountPoint $BitlockerDrive -ErrorAction SilentlyContinue)) {
        Write-Output "BitLocker is not protecting drive $BitlockerDrive. Script terminated."
        exit 0
    }
}

# Function to retrieve the key protector ID of the BitLocker-protected drive
function Get-KeyProtectorId {
    param (
        [string]$BitlockerDrive
    )
    # Get BitLocker volume information
    $BitLockerVolume = Get-BitLockerVolume -MountPoint $BitlockerDrive
    # Find the key protector of type 'RecoveryPassword'
    $KeyProtector = $BitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
    if ($KeyProtector -eq $null) {
        Write-Error "No recovery password found for BitLocker on drive $BitlockerDrive."
        exit 1
    }
    # Return the key protector ID
    return $KeyProtector.KeyProtectorId
}

# Function to attempt to back up the BitLocker key to Azure AD
function Invoke-BitlockerBackup {
    param (
        [string]$BitlockerDrive,
        [string]$BitlockerKey
    )
    try {
        # Backup the key to Azure AD
        BackupToAAD-BitLockerKeyProtector -MountPoint $BitlockerDrive -KeyProtectorId $BitlockerKey -ErrorAction Stop
        Write-Output "BitLocker key backup to Azure AD attempted. Please verify manually."
        # Log success or other relevant information
        Add-Content -Path "C:\Windows\Logs\BitLockerManagement.log" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Backup to Azure AD successful."
    } catch {
        Write-Error "An unexpected error occurred during BitLocker key backup: $_"
        # Log the error
        Add-Content -Path "C:\Windows\Logs\BitLockerManagement.log" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Backup to Azure AD failed: $_"
        exit 1
    }
}

# Test if BitLocker is protecting the system drive
Test-Bitlocker -BitlockerDrive $DriveLetter

# Retrieve the key protector ID of the BitLocker-protected drive
$KeyProtectorId = Get-KeyProtectorId -BitlockerDrive $DriveLetter

# Attempt to back up the BitLocker key to Azure AD
Invoke-BitlockerBackup -BitlockerDrive $DriveLetter -BitlockerKey $KeyProtectorId
