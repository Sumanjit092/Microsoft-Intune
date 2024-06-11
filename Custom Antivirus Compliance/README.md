# Antivirus Compliance Toolkit for Microsoft Intune

Welcome to the Antivirus Compliance Toolkit repository! This toolkit includes a PowerShell script and JSON rules tailored to facilitate antivirus compliance checks within Microsoft Intune. The PowerShell script is designed to detect any active antivirus product on a Windows system, while the JSON rules can be modified to accommodate different antivirus products.

## PowerShell Script

The PowerShell script, named `AvComplianceCheck.ps1`, serves as the core of this toolkit. It's responsible for identifying any active antivirus software on a Windows device and assessing its real-time protection status. Once executed, the script provides a concise summary of the detected antivirus product's status in a compressed JSON format.

### Usage

To use the script effectively:

1. **Run the Script**: Execute the `AvComplianceCheck.ps1` script in a PowerShell session with administrative privileges.
2. **Output**: The script will generate a JSON object summarizing the status of the detected antivirus product.

#### Uploading the Script to Intune

1. Navigate to the Microsoft Intune admin center.
2. Access **Devices** > **Endpoint Security** > **Device Compliance** > **Scripts** > **Add**.
3. Specify the platform as **Windows 10 and later**.
4. Provide a Name and Description for the script.
5. Copy and paste the script contents into the designated area.
6. Click **Create** to upload the script.

## JSON Rules

The JSON rules included in this toolkit define compliance checks tailored for Windows Defender. However, these rules are easily customizable to accommodate different antivirus solutions.

### Rules Overview

The predefined rules cover essential compliance checks:

1. **Windows Defender Installation**: Verifies if Windows Defender is installed.
2. **Security Provider Recognition**: Ensures the recognized security provider functions as an antivirus.
3. **Real-Time Protection Enabled**: Validates that real-time protection is active.
4. **Definitions Up-to-Date**: Ensures the antivirus definitions are current.

### Modifying the Rules

Customizing the rules for a different antivirus product is straightforward:

1. Adjust the `SettingName` and `Operand` values in the JSON rules to match your product.
2. Ensure all rules accurately reflect your antivirus product's settings.

#### Example JSON Rule Modification

```json
{
  "SettingName": "Your Antivirus Product Name",
  "Operator": "IsEquals",
  "DataType": "String",
  "Operand": "Your Antivirus Product Name",
  "MoreInfoUrl": "https://your-antivirus-product-url",
  "RemediationStrings": [
    {
      "Language": "en_US",
      "Title": "Your Antivirus Product was not detected.",
      "Description": "You must have Your Antivirus Product installed on your device to protect it from malware."
    }
  ]
}
```
#### Uploading the JSON to Intune Custom Compliance Policy

1. Go to the Microsoft Intune admin center.
2. Navigate to **Devices** > **Compliance policies** > **Policies** > **Create policy**.
3. Choose **Windows 10 and later** as the platform and **Custom** as the policy type.
4. Select the discovery script option.
5. Upload the modified JSON rules.
6. Configure the policy settings as needed and assign it to the desired groups.

This toolkit streamlines the process of managing antivirus compliance within Microsoft Intune
