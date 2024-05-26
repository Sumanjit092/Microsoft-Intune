# Intune Remote Wipe PowerShell Script

## Overview

The `IntuneRemoteWipe.ps1` script is designed to help IT administrators remove devices from Intune that are no longer needed, being repurposed, or missing. The Wipe action restores a device to its factory default settings. This script requires a device name/hostname or device serial number as input to initiate the wipe action.

## Features

- Finds Intune-enrolled devices using device names or serial numbers.
- Initiates a remote wipe to restore devices to factory default settings.
- Supports handling multiple devices at once.

## Requirements

- Windows PowerShell
- Microsoft Graph PowerShell Module

## Installation

1. Ensure you have an active internet connection.
2. Install the Microsoft Graph PowerShell module if not already installed:
    ```powershell
    Install-Module -Name "Microsoft.Graph" -Force
    ```
3. Download the `IntuneRemoteWipe.ps1` script to your local machine.

## Usage

1. Open a PowerShell window with administrative privileges.
2. Navigate to the directory where the `IntuneRemoteWipe.ps1` script is located.
3. Run the script with the device names or serial numbers you want to wipe. You can provide one or multiple device names or serial numbers.


### Using Device Names

```powershell
.\IntuneRemoteWipe.ps1 -DeviceNames "DeviceName1", "DeviceName2"
```
### Using Serial Numbers
```powershell

.\IntuneRemoteWipe.ps1 -Serials "SerialNumber1", "SerialNumber2"
```

### Parameters

- DeviceNames: A list of one or more device names/hostnames to be wiped.

- Serials: A list of one or more device serial numbers to be wiped.
### Example
- Using Device Names

```powershell

.\IntuneRemoteWipe.ps1 -DeviceNames "DESKTOP-ABC123", "LAPTOP-XYZ456"
```
- Using Serial Numbers
```powershell

.\IntuneRemoteWipe.ps1 -Serials "1234567890", "0987654321"
```
