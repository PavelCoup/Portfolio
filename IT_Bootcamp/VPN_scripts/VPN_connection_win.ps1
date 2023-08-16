if (Test-Path "$PSScriptRoot\VPN_access.json") {
    $FilePath = "$PSScriptRoot\VPN_access.json"
} else {
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = "C:\"
    $openFileDialog.Filter = "json (*.json)|*.json|All files (*.*)|*.*"
    $openFileDialog.FilterIndex = 1
    $openFileDialog.RestoreDirectory = $true
    $result = $openFileDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $FilePath = $openFileDialog.FileName
    } else {
        Write-Host "file not selected"
        exit 1
    }
}

$jsonData = Get-Content -Path $FilePath -Raw | ConvertFrom-Json

if (Get-VpnConnection `
    -Name $jsonData.NameConnection `
    -AllUserConnection `
    -ErrorAction SilentlyContinue) {
    
    rasdial $jsonData.NameConnection /disconnect
    Remove-VpnConnection `
        -Name $jsonData.NameConnection `
        -AllUserConnection `
        -Force
}

Add-VpnConnection `
    -AllUserConnection `
    -Name $jsonData.NameConnection `
    -ServerAddress $jsonData.ServerAddress `
    -TunnelType L2TP `
    -L2tpPsk $jsonData.IPsecSecret `
    -Force -EncryptionLevel "Optional" `
    -AuthenticationMethod MSChapv2 `
    -RememberCredential `
    -SplitTunneling:$true `
    -PassThru

# Install-Module -Name VPNCredentialsHelper
# Set-VpnConnectionUsernamePassword -ConnectionName $jsonData.NameConnection -Username $jsonData.Username -Password $jsonData.Password

rasdial.exe $jsonData.NameConnection $jsonData.Username $jsonData.Password

if (!(Get-NetRoute `
    -DestinationPrefix $jsonData.DestinationPrefix `
    -InterfaceAlias $jsonData.NameConnection `
    -NextHop $jsonData.RemoteGateway `
    -RouteMetric 1 `
    -ErrorAction SilentlyContinue)) {
    
    New-NetRoute `
    -DestinationPrefix $jsonData.DestinationPrefix `
    -InterfaceAlias $jsonData.NameConnection `
    -NextHop $jsonData.RemoteGateway `
    -RouteMetric 1
}

$hostsFolder = "$env:SystemRoot\System32\drivers\etc"
$hostsPath = "$hostsFolder\hosts"
Copy-Item -Path $hostsPath -Destination "$hostsFolder\hosts.bak" -Force
$hostsContent = Get-Content "$hostsFolder\hosts.bak"
$hostsContent = $hostsContent | Where-Object { $_ -notmatch $jsonData.DnsSuffix }

foreach ($addhost in ($jsonData.hosts | Get-Member -MemberType NoteProperty)) {
    $hostname = $addhost.Name
    $ipAddress = $jsonData.hosts.$($addhost.Name)
    $hostsContent += "$ipAddress $hostname"
}

$hostsContent | Set-Content $hostsPath -Force