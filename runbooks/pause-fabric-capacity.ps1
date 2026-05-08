param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$CapacityName
)

$ErrorActionPreference = "Continue"

# AUTH
Disable-AzContextAutosave -Scope Process | Out-Null
$context = (Connect-AzAccount -Identity).Context
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

Write-Output "Connected to Azure"

# CONFIG
$ApiVersion = "2023-11-01"
$apiQuery = "?api-version=$ApiVersion"

$baseUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Fabric/capacities/$CapacityName"

$token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com/").Token

$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# GET STATE
$getUri = "$baseUri$apiQuery"
Write-Output "Checking capacity state..."

$capacity = Invoke-RestMethod -Method GET -Uri $getUri -Headers $headers

$state = $capacity.properties.state
$provisioningState = $capacity.properties.provisioningState

Write-Output "State: $state"
Write-Output "ProvisioningState: $provisioningState"

# SAFETY CHECK
if ($state -ne "Active") {
    Write-Output "Skipping: not Active"
    return
}

if ($provisioningState -ne "Succeeded") {
    Write-Output "Skipping: not ready"
    return
}

# SUSPEND
$suspendUri = "$baseUri/suspend$apiQuery"

Write-Output "Pausing Fabric capacity..."

try {
    $response = Invoke-WebRequest -Method POST -Uri $suspendUri -Headers $headers -UseBasicParsing
    Write-Output "Paused successfully (HTTP $($response.StatusCode))"
}
catch {
    Write-Output "Error during suspend call"

    if ($_.Exception.Response -ne $null) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Output $body
    }
}