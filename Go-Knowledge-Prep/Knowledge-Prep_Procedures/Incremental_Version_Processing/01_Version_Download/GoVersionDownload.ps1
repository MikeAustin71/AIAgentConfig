# GoVersionDownload.ps1
# Script to download Go release notes markdown files to the script's directory.

# Ensure we have the directory where the script is located
$targetDirectory = $PSScriptRoot
if (-not $targetDirectory) {
    # Fallback to current working directory if executed interactively
    $targetDirectory = (Get-Location).Path
}

# 1. Array of download URLs
$downloadUrls = @(
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.23.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.24.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.25.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.26.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.27.md"
)

Write-Host "Target download folder: $targetDirectory`n" -ForegroundColor Cyan

# 2. Loop through the array
foreach ($url in $downloadUrls) {
    # Extract file name from URL (e.g., 'go1.23.md')
    $fileName = Split-Path -Leaf $url
    $destinationPath = Join-Path -Path $targetDirectory -ChildPath $fileName

    Write-Host "Downloading $fileName..." -NoNewline

    # 3. Execute curl
    # Note: Using 'curl.exe' directly ensures Windows calls the native curl binary
    # rather than PowerShell 5.1's built-in alias for Invoke-WebRequest.
    # Flags:
    #   -f: Fail silently on HTTP errors (e.g., 404 for unreleased versions)
    #   -s: Silent mode (suppress progress bar)
    #   -S: Show error message if it fails
    #   -L: Follow redirects
    #   -o: Output file destination
    curl.exe -fsSL "$url" -o "$destinationPath"

    if ($LASTEXITCODE -eq 0) {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [Failed / Not Found (Exit Code: $LASTEXITCODE)]" -ForegroundColor Red
        # Clean up empty file if curl created one on failure
        if ((Test-Path $destinationPath) -and ((Get-Item $destinationPath).Length -eq 0)) {
            Remove-Item $destinationPath -Force
        }
    }
}

Write-Host "`nDownload process complete." -ForegroundColor Cyan
