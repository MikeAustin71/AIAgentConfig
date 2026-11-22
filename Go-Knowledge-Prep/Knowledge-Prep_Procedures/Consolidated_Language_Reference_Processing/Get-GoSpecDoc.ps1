[CmdletBinding()]
param(
    [string]$Version = "go1.27.0",
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

# Normalize inputs like "1.27.4" or "v1.27.4" -> "go1.27.4" (leaves "master" as-is)
if ($Version -match '^v?(\d+\.\d+(?:\.\d+)?)$') {
    $Version = "go$($Matches[1])"
}

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = "go_spec_${Version}.md"
}

$uri = "https://raw.githubusercontent.com/golang/go/${Version}/doc/go_spec.html"
Write-Host "Downloading Go Language Specification from: $uri" -ForegroundColor Cyan
$html = Invoke-RestMethod -Uri $uri -Method Get

# 1. Extract Title and Subtitle from the leading <!--{ ... }--> JSON header
$title = "The Go Programming Language Specification"
$subtitle = $Version

$headerMatch = [regex]::Match($html, '(?s)^\s*<!--(\{.*?\})-->\s*')
if ($headerMatch.Success) {
    try {
        $meta = $headerMatch.Groups[1].Value | ConvertFrom-Json
        if ($meta.Title)    { $title = $meta.Title }
        if ($meta.Subtitle) { $subtitle = "$($meta.Subtitle) ($Version)" }
    } catch { }
    $html = $html.Substring($headerMatch.Length)
}

# Helper: encode an anchor ID as an alphanumeric hex token so Pandoc never drops or escapes it
function New-AnchorToken([string]$id) {
    $hex = [Convert]::ToHexString([System.Text.Encoding]::UTF8.GetBytes($id))
    return "GOANCHOR${hex}GOANCHOR"
}

# 2. Preserve heading IDs (<h1..h6 id="...">) across Pandoc
$html = [regex]::Replace($html, '<h([1-6])([^>]*?)\sid="([^"]+)"([^>]*)>', {
    param($m)
    $token = New-AnchorToken $m.Groups[3].Value
    return "<p>${token}</p>`n<h$($m.Groups[1].Value)$($m.Groups[2].Value)$($m.Groups[4].Value)>"
})

# 3. Clean <pre> and <pre class="ebnf"> blocks: preserve inner <a id/name="..."> anchors above the fence
$html = [regex]::Replace($html, '(?s)<pre([^>]*)>(.*?)</pre>', {
    param($m)
    $attrs = $m.Groups[1].Value
    $body  = $m.Groups[2].Value

    $tokens = [System.Collections.Generic.List[string]]::new()
    if ($attrs -match '(?:id|name)="([^"]+)"') {
        $tokens.Add((New-AnchorToken $Matches[1]))
    }
    foreach ($am in [regex]::Matches($body, '<(?:a|span)[^>]*?\s(?:id|name)="([^"]+)"[^>]*>')) {
        $tokens.Add((New-AnchorToken $am.Groups[1].Value))
    }

    # Strip inner HTML tags (like <a href="...">) so Pandoc emits a clean fenced block
    $cleanBody = [regex]::Replace($body, '<[^>]+>', '')
    $langClass = if ($attrs -match 'class="[^"]*(?:ebnf|grammar)[^"]*"') { ' class="language-ebnf"' } else { '' }

    $prefix = if ($tokens.Count -gt 0) { "<p>$($tokens -join '')</p>`n" } else { '' }
    return "${prefix}<pre><code${langClass}>${cleanBody}</code></pre>"
})

# 4. Preserve remaining inline/standalone <a id="..."> or <span id="..."> anchors
$html = [regex]::Replace($html, '<(a|span)[^>]*?\s(?:id|name)="([^"]+)"[^>]*>(.*?)</\1>', {
    param($m)
    $token = New-AnchorToken $m.Groups[2].Value
    return "${token}$($m.Groups[3].Value)"
})

# 5. Locate Pandoc (native Windows first, then WSL2)
$useWslPandoc = $false
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    $null = wsl which pandoc 2>$null
    if ($LASTEXITCODE -eq 0) {
        $useWslPandoc = $true
    } else {
        Write-Error "Pandoc was not found on Windows PATH or inside WSL2. Install it via: winget install JohnMacFarlane.Pandoc"
        exit 1
    }
}

$tempBase = [System.IO.Path]::GetTempFileName()
$tempHtml = "${tempBase}.html"
$tempMd   = "${tempBase}.md"

try {
    $html | Set-Content -Path $tempHtml -NoNewline

    if ($useWslPandoc) {
        $wslHtml = (wsl wslpath -a ($tempHtml -replace '\\', '/')).Trim()
        $wslMd   = (wsl wslpath -a ($tempMd   -replace '\\', '/')).Trim()
        wsl pandoc $wslHtml -f html -t gfm --wrap=none -o $wslMd
    } else {
        pandoc $tempHtml -f html -t gfm --wrap=none -o $tempMd
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Pandoc conversion failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }

    $md = Get-Content -Path $tempMd -Raw
}
finally {
    Remove-Item -Path $tempBase, $tempHtml, $tempMd -ErrorAction SilentlyContinue
}

# 6. Restore <a id="..."></a> anchors, clean spacing, expand relative links, and prepend Title
$md = [regex]::Replace($md, 'GOANCHOR([0-9A-F]+)GOANCHOR', {
    param($m)
    $id = [System.Text.Encoding]::UTF8.GetString([Convert]::FromHexString($m.Groups[1].Value))
    return "<a id=`"${id}`"></a>"
})

# Tighten anchor lines so they sit directly above headings and code fences
$md = $md -replace '((?:<a id="[^"]+"></a>)+)\r?\n+(?=#{1,6}\s|```)', "`$1`n"

# Expand root-relative go.dev links like (/ref/mem) -> (https://go.dev/ref/mem)
$md = $md -replace '\]\(/([a-zA-Z0-9_./#-]+)\)', '](https://go.dev/$1)'

$finalDoc = "# ${title}`n`n*${subtitle}*`n`n$($md.TrimStart())"
$finalDoc | Set-Content -Path $OutputFile -NoNewline

Write-Host "Saved Go Language Specification (${Version}) to: $OutputFile" -ForegroundColor Green
