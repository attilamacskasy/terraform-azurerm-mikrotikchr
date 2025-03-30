# Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
# Set-ExecutionPolicy Bypass -Scope Process -Force
# Requires -RunAsAdministrator
# NOTE: This script must be run on a Hyper-V host with the Hyper-V role enabled.

$ErrorActionPreference = "Stop"

# Define URLs and paths
$DownloadUrl = "https://download.mikrotik.com/routeros/7.18.2/chr-7.18.2.vhdx.zip"
$FileName = "chr-7.18.2.vhdx.zip"
$ExtractedFile = "chr-7.18.2.vhdx"
$ConvertedFile = "chr-7.18.2.vhd"
$DownloadPath = "$PWD\$FileName"
$ExtractPath = "$PWD"
$LogTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = "$PWD\conversion-log-$LogTimestamp.txt"

# Prompt and delete if file exists
function CheckAndPrompt {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        $response = Read-Host "File '$Path' already exists. Do you want to delete it? (Y/N)"
        if ($response -eq 'Y' -or $response -eq 'y') {
            Remove-Item $Path -Force
            Write-Host "Deleted: $Path"
        } else {
            Write-Host "Aborting script as requested."
            exit
        }
    }
}

# Logging function
function LogDebug {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

# Measure execution time
function Measure-Time {
    param (
        [string]$Label,
        [ScriptBlock]$Action
    )
    LogDebug "Starting: $Label"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & $Action
    $sw.Stop()
    LogDebug "Finished: $Label in $($sw.Elapsed.TotalSeconds) seconds.`n"
}

# Check and prompt before overwriting any existing files
CheckAndPrompt -Path $DownloadPath
CheckAndPrompt -Path "$ExtractPath\$ExtractedFile"
CheckAndPrompt -Path "$ExtractPath\$ConvertedFile"

# Start total timer
$TotalTimer = [System.Diagnostics.Stopwatch]::StartNew()

LogDebug "=== MikroTik Cloud Hosted Router (CHR) VHDX Download and Conversion Script Started ==="

# Step 1: Download the file using BITS
Measure-Time -Label "Downloading Cloud Hosted Router (CHR) VHDX ZIP with BITS" -Action {
    Start-BitsTransfer -Source $DownloadUrl -Destination $DownloadPath
}

# Step 2: Extract the ZIP file
Measure-Time -Label "Unzipping Cloud Hosted Router (CHR) VHDX File" -Action {
    Expand-Archive -Path $DownloadPath -DestinationPath $ExtractPath -Force
}

# Step 3: Convert VHDX to VHD
Measure-Time -Label "Converting Cloud Hosted Router (CHR) VHDX to VHD" -Action {
    Convert-VHD -Path "$ExtractPath\$ExtractedFile" -DestinationPath "$ExtractPath\$ConvertedFile" -VHDType Fixed
}

$TotalTimer.Stop()
LogDebug "=== Script Completed in $($TotalTimer.Elapsed.TotalSeconds) seconds ==="
LogDebug "Converted file path: $ExtractPath\$ConvertedFile"
