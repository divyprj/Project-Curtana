Set-StrictMode -Version Latest

function Get-CurtanaRoot {
    [CmdletBinding()]
    param(
        [string]$StartPath = (Get-Location).Path
    )

    $current = Resolve-Path -LiteralPath $StartPath
    $item = Get-Item -LiteralPath $current
    if (-not $item.PSIsContainer) {
        $item = $item.Directory
    }

    while ($null -ne $item) {
        $toolkitConfig = Join-Path $item.FullName "configs\toolkit.json"
        $readme = Join-Path $item.FullName "README.md"
        if ((Test-Path -LiteralPath $toolkitConfig) -and (Test-Path -LiteralPath $readme)) {
            return $item.FullName
        }
        $item = $item.Parent
    }

    throw "Project-Curtana root not found from $StartPath"
}

function Find-CurtanaPlatformTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("adb", "fastboot")]
        [string]$Name,

        [string]$Root = (Get-CurtanaRoot)
    )

    $local = Join-Path $Root "tools\platform-tools\$Name.exe"
    if (Test-Path -LiteralPath $local) {
        return $local
    }

    $fromPath = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $fromPath) {
        return $fromPath.Source
    }

    throw "$Name was not found in tools\platform-tools or PATH"
}

function Get-CurtanaAdbDevice {
    [CmdletBinding()]
    param(
        [string]$Root = (Get-CurtanaRoot)
    )

    $adb = Find-CurtanaPlatformTool -Name adb -Root $Root
    $output = & $adb devices -l
    [pscustomobject]@{
        Tool = $adb
        Output = $output
        HasAuthorizedDevice = ($output -match "\sdevice\s")
        HasUnauthorizedDevice = ($output -match "\sunauthorized\s")
    }
}

function Get-CurtanaFastbootDevice {
    [CmdletBinding()]
    param(
        [string]$Root = (Get-CurtanaRoot)
    )

    $fastboot = Find-CurtanaPlatformTool -Name fastboot -Root $Root
    $devices = & $fastboot devices
    $product = & $fastboot getvar product 2>&1
    $unlocked = & $fastboot getvar unlocked 2>&1
    [pscustomobject]@{
        Tool = $fastboot
        Devices = $devices
        Product = $product
        Unlocked = $unlocked
        HasDevice = ($devices -match "\S+\s+fastboot")
    }
}

function Test-CurtanaSha256 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$Expected
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    [pscustomobject]@{
        Path = (Resolve-Path -LiteralPath $Path).Path
        SHA256 = $hash
        Expected = $Expected
        Matches = if ($Expected) { $hash -eq $Expected.ToLowerInvariant() } else { $null }
    }
}

Export-ModuleMember -Function Get-CurtanaRoot, Find-CurtanaPlatformTool, Get-CurtanaAdbDevice, Get-CurtanaFastbootDevice, Test-CurtanaSha256

