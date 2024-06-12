# Intune Device Actions PowerShell Script

## Overview

The `IntuneDeviceActions.ps1` script enables various management actions on devices enrolled in Microsoft Intune. These actions are helpful for handling devices that are no longer needed, being repurposed, or missing. Supported actions include wiping, retiring, syncing, locking, deleting, restarting, and shutting down devices. This script requires either device names/hostnames or device serial numbers as input parameters.

## Features

- Enables remote management actions on devices enrolled in Microsoft Intune.
- Supports a range of actions including wiping, retiring, syncing, locking, deleting, restarting, and shutting down devices.
- Accepts both device names/hostnames and device serial numbers as input.
- Provides detailed feedback during the execution of actions.

## Requirements

- Windows PowerShell 7 or later versions
- Microsoft Graph PowerShell Module
- Ensure Graph API application has "DeviceManagementManagedDevices.PrivilegedOperations.All" scope assigned

## Installation

1. Ensure you have an active internet connection.
2. Install the Microsoft Graph PowerShell module if not already installed:
    ```powershell
    Install-Module -Name "Microsoft.Graph" -Force
    ```
3. Download the `IntuneDeviceActions.ps1` script to your local machine.

## Usage

1. Open a PowerShell window with administrative privileges.
2. Navigate to the directory where the `IntuneDeviceActions.ps1` script is located.
3. Run the script with the desired action(s) and device identifiers (device names/hostnames or device serial numbers).

### Supported Actions

- **Wipe:** Initiate a remote wipe action to restore devices to factory default settings.
- **Retire:** Retire devices from Intune management.
- **Sync:** Trigger a remote sync action for devices.
- **Lock:** Lock devices remotely.
- **Delete:** Delete devices from Intune management.
- **Restart:** Initiate a remote restart action for devices.
- **Shutdown:** Initiate a remote shutdown action for devices.

### Parameters

- **DisplayNames:** A list of one or more device names/hostnames.
- **Serials:** A list of one or more device serial numbers.

### Examples

#### Using Device Names

```powershell
.\IntuneDeviceActions.ps1 -DisplayNames "DeviceName1", "DeviceName2" -Wipe
```
#### Using Serial Numbers

```powershell
.\IntuneDeviceActions.ps1 -Serials "SerialNumber1", "SerialNumber2" -Delete
```