# Unity Build Validation Script for Windows
# Usage: .\unity-build.ps1 -ProjectPath <path> [-BuildTarget <target>]

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [Parameter(Mandatory=$false)]
    [string]$BuildTarget = "StandaloneWindows64"
)

$ErrorActionPreference = "Stop"

# Resolve absolute path
$ProjectPath = (Resolve-Path $ProjectPath).Path

# Generate unique log file
$LogFile = Join-Path $env:TEMP "unity-build-$PID.log"

# Validate project path
$AssetsPath = Join-Path $ProjectPath "Assets"
if (-not (Test-Path $AssetsPath)) {
    Write-Error "[ERROR] Assets folder not found at: $ProjectPath"
    Write-Host "Please specify a valid Unity project path."
    exit 1
}

# Find Unity Editor
function Find-Unity {
    # Unity Hub default locations
    $hubPaths = @(
        "C:\Program Files\Unity\Hub\Editor\*\Editor\Unity.exe",
        "C:\Program Files (x86)\Unity\Hub\Editor\*\Editor\Unity.exe"
    )

    # Direct install location
    $directPaths = @(
        "C:\Program Files\Unity\Editor\Unity.exe",
        "C:\Program Files (x86)\Unity\Editor\Unity.exe"
    )

    # Try Hub paths first (get latest version)
    foreach ($pattern in $hubPaths) {
        $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue |
                 Sort-Object { [version]($_.Directory.Parent.Name -replace '[^\d.]', '') } -Descending |
                 Select-Object -First 1
        if ($found) {
            return $found.FullName
        }
    }

    # Try direct paths
    foreach ($path in $directPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    # Try environment PATH
    $unityInPath = Get-Command Unity -ErrorAction SilentlyContinue
    if ($unityInPath) {
        return $unityInPath.Source
    }

    return $null
}

$UnityPath = Find-Unity
if (-not $UnityPath) {
    Write-Error "[ERROR] Unity Editor not found."
    Write-Host "Please install Unity or set the path manually."
    exit 1
}

Write-Host "Unity: $UnityPath"
Write-Host "Project: $ProjectPath"
Write-Host "Target: $BuildTarget"
Write-Host "Log: $LogFile"
Write-Host ""

# Run Unity build validation
$processArgs = @(
    "-batchmode",
    "-quit",
    "-projectPath", $ProjectPath,
    "-buildTarget", $BuildTarget,
    "-logFile", $LogFile
)

$process = Start-Process -FilePath $UnityPath -ArgumentList $processArgs -Wait -PassThru -NoNewWindow

# Output log file path for analyzer
if (Test-Path $LogFile) {
    Write-Host "LOG_FILE_PATH:$LogFile"
} else {
    Write-Error "[ERROR] Log file not created: $LogFile"
    exit 1
}
