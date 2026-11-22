[CmdletBinding()]
param(
    [string]$Package = "math/big",
    [string]$Version = "v1.27.0",
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = "$($Package -replace '/', '_')_go$($Version.TrimStart('v')).md"
}

$uri = "https://pkg.go.dev/v1/package/${Package}?version=${Version}&doc=md&examples=true"
$response = Invoke-RestMethod -Uri $uri -Method Get

if ([string]::IsNullOrWhiteSpace($response.docs)) {
    Write-Error "API response did not contain 'docs' content."
    exit 1
}

$docs = $response.docs

# 1. Match website title format (e.g., "# big package - math/big")
$pkgName = if ($response.name) { $response.name } else { ($Package -split '/')[-1] }
$docs = $docs -replace '(?m)^# package [^\r\n]+', "# $pkgName package - $Package"

# 2. Expand relative stdlib/package links like (/fmt#Scanner) to full URLs
$docs = $docs -replace '\]\(/([a-zA-Z0-9_./#-]+)\)', '](https://pkg.go.dev/$1)'

# 3. Restore Markdown headings and HTML <a id="..."></a> anchors
$lines = $docs -split "`r?`n"
$out = [System.Collections.Generic.List[string]]::new($lines.Count + 256)
$section = ""
$inExample = $false

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match '^##\s+(Constants|Variables|Functions|Types)\b') {
        $section = $Matches[1]
        $inExample = $false
        $out.Add($line)
        continue
    }

    if ($line -match '^####\s+(Example\b.*)') {
        $inExample = $true
        # Nest examples under ### / #### symbols when inside Functions or Types
        if ($section -in @("Functions", "Types")) {
            $out.Add("##### $($Matches[1])")
        } else {
            $out.Add($line)
        }
        continue
    }

    if ($line -eq '```go') {
        $block = [System.Collections.Generic.List[string]]::new()
        $j = $i + 1
        while ($j -lt $lines.Count -and $lines[$j] -ne '```') {
            $block.Add($lines[$j])
            $j++
        }

        if (-not $inExample -and $block.Count -gt 0) {
            $first = $block[0].Trim()

            # Method: func (recv *Type) Name(...)
            if ($first -match '^func\s+\(\s*(?:[A-Za-z_][A-Za-z0-9_]*\s+)?(\*?)([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])?)\)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:\[|\()') {
                $ptr = $Matches[1]
                $rawType = $Matches[2]
                $cleanType = $rawType -replace '\[.*\]', ''
                $method = $Matches[3]
                $out.Add("<a id=`"${cleanType}.${method}`"></a>")
                $out.Add("#### func (${ptr}${rawType}) ${method}")
                $out.Add("")
            }
            # Function or Type Constructor: func Name(...)
            elseif ($first -match '^func\s+([A-Za-z_][A-Za-z0-9_]*)(?:\[[^\]]+\])?\s*\(') {
                $fnName = $Matches[1]
                $hLevel = if ($section -eq "Types") { "####" } else { "###" }
                $out.Add("<a id=`"${fnName}`"></a>")
                $out.Add("${hLevel} func ${fnName}")
                $out.Add("")
            }
            # Type definition: type Name ...
            elseif ($first -match '^type\s+([A-Za-z_][A-Za-z0-9_]*)\b') {
                $typeName = $Matches[1]
                $out.Add("<a id=`"${typeName}`"></a>")
                $out.Add("### type ${typeName}")
                $out.Add("")
            }
            # Const / Var blocks: anchor exported identifiers (e.g., Below, ToNearestEven, MaxBase)
            elseif ($first -match '^(?:const|var)\b') {
                $anchors = [System.Collections.Generic.List[string]]::new()
                foreach ($bLine in $block) {
                    $trimmed = $bLine.Trim()
                    if ($trimmed -match '^(?://|/\*|\*)') { continue }
                    if ($trimmed -match '^(?:const|var)\s+([A-Z][A-Za-z0-9_]*)\b') {
                        $anchors.Add("<a id=`"$($Matches[1])`"></a>")
                    }
                    elseif ($trimmed -notmatch '^(?:const|var)\s*\(' -and $trimmed -match '^([A-Z][A-Za-z0-9_]*)(?:\s|$)') {
                        $anchors.Add("<a id=`"$($Matches[1])`"></a>")
                    }
                }
                if ($anchors.Count -gt 0) {
                    $out.Add(($anchors -join ""))
                }
            }
        }

        # Emit the fenced code block
        $out.Add($line)
        foreach ($bLine in $block) { $out.Add($bLine) }
        if ($j -lt $lines.Count) { $out.Add($lines[$j]) }

        # Reset after an Example's code block so the next declaration isn't skipped
        $inExample = $false
        $i = $j
        continue
    }

    $out.Add($line)
}

($out -join "`n") | Set-Content -Path $OutputFile -NoNewline
Write-Host "Saved $($response.modulePath) ($($response.version)) to $OutputFile" -ForegroundColor Green
