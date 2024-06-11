$AvProducts = Get-WmiObject -Namespace 'root\SecurityCenter2' -Class AntiVirusProduct
$ActiveAvProduct = $null

foreach ($AvProduct in $AvProducts) {
    $hexProductState = [Convert]::ToString($AvProduct.productState, 16).PadLeft(6, '0')
    $hexRealTimeProtection = $hexProductState.Substring(2, 2)

    $RealTimeProtectionStatus = switch ($hexRealTimeProtection) {
        '00' { 'Off' }
        '01' { 'Expired' }
        '10' { 'On' }
        '11' { 'Snoozed' }
        default { 'Unknown' }
    }

    if ($RealTimeProtectionStatus -eq 'On') {
        $ActiveAvProduct = $AvProduct
        break
    }
}

if ($ActiveAvProduct) {
    $hexProductState = [Convert]::ToString($ActiveAvProduct.productState, 16).PadLeft(6, '0')
    $hexSecurityServiceProvider = $hexProductState.Substring(0, 2)
    $hexRealTimeProtection = $hexProductState.Substring(2, 2)
    $hexDefinitionStatus = $hexProductState.Substring(4, 2)

    $SecurityServiceProvider = switch ($hexSecurityServiceProvider) {
        '00' { 'None' } 
        '01' { 'Firewall' } 
        '02' { 'AutoupdateSettings' } 
        '04' { 'Antivirus' } 
        '08' { 'Antispyware' } 
        '16' { 'InternetSettings' } 
        '32' { 'UserAccountControl' } 
        '64' { 'Service' } 
        default { 'Unknown' } 
    }

    $RealTimeProtectionStatus = switch ($hexRealTimeProtection) {
        '00' { 'Off' }
        '01' { 'Expired' }
        '10' { 'On' }
        '11' { 'Snoozed' }
        default { 'Unknown' }
    }

    $DefinitionStatus = switch ($hexDefinitionStatus) {
        '00' { 'UpToDate' }
        '10' { 'OutOfDate' }
        default { 'Unknown' }
    }

    $AvSummary = [PSCustomObject]@{
        ProductName = $ActiveAvProduct.displayName
        ServiceEnabled = $SecurityServiceProvider
        RealTimeProtectionEnabled = $RealTimeProtectionStatus
        DefinitionsUpToDate = $DefinitionStatus
    }
}
else {
    $AvSummary = [PSCustomObject]@{
        ProductName = 'Error: No active Antivirus product found'
        ServiceEnabled = 'Error: No active Antivirus product found'
        RealTimeProtectionEnabled = 'Error: No active Antivirus product found'
        DefinitionsUpToDate = 'Error: No active Antivirus product found'
    }
}

return $AvSummary | ConvertTo-Json -Compress
