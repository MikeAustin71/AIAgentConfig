<#
.SYNOPSIS
    Fixes relative go.dev links across all Markdown (.md) files in the current directory.

.DESCRIPTION
    Replaces relative paths (/blog/, /cmd/, /doc/, /issue/, /pkg/, /ref/) inside
    markdown link targets with their absolute 'https://go.dev/...' equivalents.
#>

# Define the target path prefixes to replace
$prefixes = @('blog', 'cmd', 'doc', 'issue', 'pkg', 'ref')

# Combine them into a regex alternation: (blog|cmd|doc|issue|pkg|ref)
$pattern = '\]\(\s*/(' + ($prefixes -join '|') + ')/'

# Target replacement: '](' followed by 'https://go.dev/$1/'
$replacement = '](https://go.dev/$1/'

# Get all .md files in the current working directory (excluding subdirectories)
$files = Get-ChildItem -Path . -Filter "*.md" -File

if ($files.Count -eq 0) {
    Write-Host "No .md files found in the current working directory." -ForegroundColor Yellow
    exit
}

Write-Host "Starting link replacement on $($files.Count) Markdown file(s)...`n" -ForegroundColor Cyan

$totalReplacements = 0

foreach ($file in $files) {
    # Read full file content using UTF-8
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    # Count how many matches exist in this file
    $matchesFound = [regex]::Matches($content, $pattern).Count

    if ($matchesFound -gt 0) {
        # Perform regex replacement
        $updatedContent = [regex]::Replace($content, $pattern, $replacement)

        # Write updated content back to the file using UTF-8
        [System.IO.File]::WriteAllText($file.FullName, $updatedContent, [System.Text.Encoding]::UTF8)

        Write-Host "  [UPDATED] $($file.Name) - replaced $matchesFound link(s)" -ForegroundColor Green
        $totalReplacements += $matchesFound
    } else {
        Write-Host "  [SKIPPED] $($file.Name) - no matching relative links found" -ForegroundColor DarkGray
    }
}

Write-Host "`nCompleted! Processed $($files.Count) file(s) with $totalReplacements total replacement(s)." -ForegroundColor Cyan
