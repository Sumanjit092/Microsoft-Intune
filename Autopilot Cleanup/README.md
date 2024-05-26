# Intune Autopilot Cleanup PowerShell Script

## Overview

The `IntuneAutopilotCleanup.ps1` script is designed to streamline the process of removing devices from Intune, cleaning up hardware hashes in the Intune Autopilot collection, and deleting devices from Microsoft Entra ID. This is particularly useful during hardware refresh programs or when devices are no longer needed.

## Features

- Deletes devices from the Intune Device List.
- Removes hardware hashes from the Intune Autopilot collection.
- Deletes devices from Microsoft Entra ID.
- Handles single or multiple device serial numbers as input.

## Requirements

- Windows PowerShell
- Microsoft Graph PowerShell Module

## Installation

1. Ensure you have an active internet connection.
2. Install the Microsoft Graph PowerShell module if not already installed:
    ```powershell
    Install-Module -Name "Microsoft.Graph" -Force
    ```
3. Download the `IntuneAutopilotCleanup.ps1` script to your local machine.

## Usage

1. Open a PowerShell window with administrative privileges.
2. Navigate to the directory where the `IntuneAutopilotCleanup.ps1` script is located.
3. Run the script with the device serial numbers you want to clean up. You can provide one or multiple serial numbers.
    ```powershell
    .\IntuneAutopilotCleanup.ps1 -SerialNumbers "SERIAL1", "SERIAL2", "SERIAL3"
    ```

## Parameters

- `-SerialNumbers`: A list of one or more device serial numbers to be cleaned up.

## Example

```powershell
.\IntuneAutopilotCleanup.ps1 -SerialNumbers "1234567890", "0987654321"
