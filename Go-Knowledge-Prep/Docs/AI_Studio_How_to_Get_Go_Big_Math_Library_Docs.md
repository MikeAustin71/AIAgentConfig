# AI Studio How to Get the Latest Go Big Math Library Docs

## [See Power Shell Scripts Here!](D:\GoProjects\MikeAustin71\AIAgentConfig\Go-Knowledge-Prep)



# Gemini 4 Hydrogen Question No 1 - 2026-11-21 19:06-Hours

# Session Title: Go Documentation RAG


## Background

I have setup a Retrieval Augmented Generation (**Rag**) procedure to transmit the latest ***Go*** programming language documentation to my ***Kilo*** agent at the outset of every new session. This process is working will. 

Currently, I download and provide to the ***Kilo*** agent two types of documentation:

1. **Incremental Release Documentation**
2. ***Go* Language Specification Documentation for the Target *Go* Version**



### Incremental Update Documents

Incremental updates for individual ***Go*** versions are downloaded using ***curl*** commands from the following URL's.

```bash
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.23.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.24.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.25.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.26.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.27.md"
```

 Notice that these documents are provided in markdown format. 



### ***Go* Language Specification Documentation**

The ***Go*** Language Specification for ***Go Version 1.27*** is downloaded from:

```bash
https://raw.githubusercontent.com/golang/go/master/doc/go_spec.html
```

Notice that this document in provided in ***html*** format. After downloading, I convert the ***html*** to ***markdown*** using the ***Pandoc*** conversion application. 



##  Request

I now find that I need to down load and provide the documentation for the ***Math Big*** package. The URL for this package is:

```bash
https://pkg.go.dev/math/big
```

How can I locate and download the documentation for the ***Go*** ***Math Big*** package, ***Version 1.27***?

I realize will probably have to obtain this documentation in ***html*** format and manually convert it to ***markdown*** format. 



# Gemini 4 Hydrogen Response No 1 - 2026-11-21 19:26-Hours

You have **three solid ways** to get the Go 1.27 documentation for `math/big` into Markdown for your RAG pipeline—including a newer native Markdown API that lets you skip HTML and Pandoc entirely.

*(Note: As of November 2026, the latest Go 1.27 patch release is **`go1.27.4`**, while the initial release is **`go1.27.0`**.)*

---

### Method 1: Use the Official `pkg.go.dev` API (Native Markdown, No Pandoc Needed)

`pkg.go.dev` provides an official JSON REST API designed specifically for tooling and AI coding agents. Its `/v1/package/{path}` endpoint can return package documentation **already formatted as Markdown** (`doc=md` or `doc=markdown`) and optionally include runnable examples (`examples=true`).

Run this in WSL2 (requires `curl` and `jq`):

```bash
# 1. (Optional) Check exact stdlib version strings recognized by the API
curl -sL "https://pkg.go.dev/v1/versions/std" | jq '.versions[:5]'

# 2. Fetch math/big documentation directly as Markdown
curl -sL "https://pkg.go.dev/v1/package/math/big?version=v1.27.4&doc=md&examples=true" \
  | jq -r '.docs' > math_big_go1.27.4.md
```

* **Why this is ideal for your RAG setup:** It outputs clean Markdown with no website navigation, sidebars, or footer boilerplate—saving significant context tokens for your 32K/64K `qwen3.8-27b` and `gemma4:31b` models.
* **Version note:** Because Go 1.27 is currently the latest major release, omitting `&version=...` will also return the latest Go 1.27 version (you can inspect `.version` in the JSON output to verify). If `v1.27.4` returns an empty result or error depending on API version tag mapping (`v1.27.4` vs `go1.27.4`), check step 1 above or omit `version`.

---

### Method 2: Versioned `pkg.go.dev` HTML + Pandoc (Mirrors Your Current Workflow)

If you prefer to stick strictly to your `curl` + `pandoc` pipeline, `pkg.go.dev` pins standard library packages to a specific Go version by appending `@go1.27.x` to the URL:

* **Initial Go 1.27 release:** `https://pkg.go.dev/math/big@go1.27.0`
* **Latest Go 1.27 patch release:** `https://pkg.go.dev/math/big@go1.27.4`

**Important RAG tip:** Unlike `go_spec.html`, a full `pkg.go.dev` webpage contains navigation menus, search tips, "Jump to" modals, and footers. Converting the entire HTML file directly with Pandoc will inject noise into your RAG chunks. Extract the documentation container (`div.Documentation`) first before converting:

```bash
# Download the version-pinned HTML
curl -sL "https://pkg.go.dev/math/big@go1.27.4" -o math_big.html

# Extract only the package documentation block and convert to GitHub-Flavored Markdown
python3 -c '
import bs4
soup = bs4.BeautifulSoup(open("math_big.html", encoding="utf-8"), "html.parser")
doc = soup.select_one("div.Documentation") or soup.select_one("article")
print(doc)
' | pandoc -f html -t gfm --wrap=none -o math_big_go1.27.4.md
```

*(If you don't have BeautifulSoup installed in WSL2, `pip install beautifulsoup4` or `sudo apt install python3-bs4` adds it, or you can run `pandoc math_big.html -f html -t gfm --wrap=none -o math_big_go1.27.4.md` directly and trim the header/footer.)*

---

### Method 3: Generate Directly from Local Go 1.27 Source (Offline & Cleanest)

Since Go package documentation lives inside the source files (`$GOROOT/src/math/big/*.go`), you can extract it locally without hitting `pkg.go.dev` at all:

#### Option A: Clean Markdown via `gomarkdoc`
[`gomarkdoc`](https://github.com/princjef/gomarkdoc) generates structured Markdown (headings, signatures, fenced Go code blocks, and doc comments) straight from Go source:

```bash
go install github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest

# Point gomarkdoc at your Go 1.27 standard library math/big directory
GOROOT_127=$(GOTOOLCHAIN=go1.27.4 go env GOROOT)
gomarkdoc --output math_big_go1.27.4.md "${GOROOT_127}/src/math/big"
```

#### Option B: Plain Text via `go doc`
If your RAG chunks work fine with plain text, `go doc` is built into the Go toolchain:

```bash
GOTOOLCHAIN=go1.27.4 go doc -all math/big > math_big_go1.27.4.txt
```
*(In Go 1.27, you can also run `GOTOOLCHAIN=go1.27.4 go doc -ex math/big` to list runnable examples.)*

---

### Bonus Tip for Your Existing `go_spec.html` Download

Notice that your current language specification URL pulls from the `master` branch:
```text
https://raw.githubusercontent.com/golang/go/master/doc/go_spec.html
```
As development moves toward Go 1.28, `master` will drift ahead of Go 1.27. To strictly pin the Language Specification to **Go 1.27**, switch `master` to the release tag:
```text
https://raw.githubusercontent.com/golang/go/go1.27.4/doc/go_spec.html
```

### Sources

1. [reddit.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQGZ-DNoNUFK2bY_ddckjdiz3f3p6iWnXtjQbKoF6w1PA0BdiW2IiW-xkljJ59Dap_iHd9w6jDMMsLbURdLkDq4GOxIE_H0nh1l2dCjVqFVxQtZ6rrQ4Vn-8q7dMyW_8TDOnfRzxFnXFvSueky2fAFo3RNwRxuCnB2iMBg%3D%3D)
2. [iotdigitaltwinplm.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQGxtH8NFGR773Jfhrj6qJ7F929qzvdoXZ4uC6cDDHI1cfRmv0cF74l6Zs-k1vRdPnBhLS9Z5-eJhhh5UZ-lEDjuVNoZ8Q4LPKGNlsrsVmFUpE6AukN5yIQn3JCZTR1wdAvIK9Rw6KRg07mFc_jg2MhWquNN5gyAUjx6HvXXYm8zr3Xyb9A_P90SJI3s3sVVYUHExup7LbcRb5XUj-Tav5piSeKq5NSFLWEgy12_1fTau9bocAC-h0xc)
3. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQG6-zmh9pWYRm-URNysh4_7u1gVw6_hfRpJc3th7ffbb0Q8ZdJNG28hKSUz_MHxtsuyWKR8XiNBFxSU-zBaIlmsxYJZHEBPgmhZWOuUfzWMHoB64Ds16g%3D%3D)
4. [googleblog.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQHcetdZdYaiyGHPsZ_nZ9cie0izzqgEWsGglldGQHt5INp_gwVrZ7kv2Ue_QsBp0EQPqfLsYUEuWlzt78IPacuZ33hVenXQJVacPVSIc_sKL7VQNPPWM-Q7UbqPY3yjQ0rgW_3EBLeqMkIJzy0Huiy-DZDgv92YepReTZR9a-M%3D)
5. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQG-mGMBa_i6VB7_4d2rS4wzl8Ea8YnVO3zQxQKfCc4C-xT5aXxnHVUT6YYzCpP4AJ-a3icIp-ZzIBhGX6tt0Jx2WtdDeJj8G4CFJyzoUmnbwRu62UfP)
6. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQGlvGpuWJtHcrxiD0fJQ9RkBd_RkXnHh0p3_kvEYraxKBDkG7PINGr503v1pW1oAgmY1uFh8Xsv4YuhKmDZVsnRV4JLqvN51whPMUv1KRwW)
7. [wawand.co](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQHisaBhLwt3rrZahb6E46y-PJhbEN1M9lNtiSsSFfrvS9yZiQj9kiEcAxicUSGa3gJy_TUhRLRWLNZ2ZNZVtV4YinK_XNXiDAmQfNWuV9K2o0jqxklGQeSqOk1evUVJ1zbKAqZRsgXLbp9s-FTFKQ%3D%3D)
8. [stackoverflow.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQEycwyaXizn96nMCT8knDSmuUxI3NoGfBieU5l4bbWi9wXXP3jj8_JZEQ6NBrRDNzHLepadRo1nk2mPM6g54vFH3wYyf02HGjSD_yTV2EWynbb5LJu6EF1_cunJkt9pBSEwojIkIhkAsStL5HfGsa-mmiZeTzG7nQPxVv4JRvyUwO0wf7zkFGuTdEUQ0NDY8lfSM3dejD5yXGAXmzDVuFiMRL1UMpMb)
9. [notes-bin.top](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQF9R35947CLXpplHpn-nU8Dq7WVTaV5laX2mQVAPvA9AW6wCiDpQQliAUeckPL75SfCGXWO3rKUwk6Cpu-h2NVQSudG3W836sa_W3dEgW_ZQ_GpYP3DB4Tpc7sM6N4zrytI5osYC1Wylcp3wUgnfnq6PQ%3D%3D)
10. [zenn.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQEQ-x8B3qjjGhUTijoXA111fhNI_7p1NiUWYIFeQcxseUa75D6PjW6WnApKBMelXto7XiqgPSou9thclkc7vov1FDNMXr-_-LxoCDYDcO_NiwKLPliAZEQa6qvHahSNYzgHXmsxESo%3D)
11. [github.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQE7XLGlQQHhNKeXbIPQrk_Chucm0BMWnI8bVGJKW54ldqcpeOlUsjqwlnS9I6RpqKNU6Kai4SJnG3cNFzko2b4pmkAe17eJYzo30KDhCjA9azK8TobQsB8v4vQ%3D)
12. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQHkBST3iLA9JW6zBe7xTEE4NZ-U67eAhLD_6-001BDUq4Y15hOd4MyEEdfnqTczHDBSeYy3FRLegsMtvbsdXOnt9C7ij_Hn3PL0t75GwyYZ4EQ57k9OKRK6rYFsanTz7jOgagcU6pw0nL1hOK7ILMnYOdX5)
13. [linuxcommandlibrary.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQEYzpScrbO6S0x1aYzJ_XJLSQ88HcIVpCpVOS4Ca-ySjFtnenJN91i7RezGFSaqeMBNibPUYoWmFYAibfKeSuVWaegqu13Zk6pKY0N3a2i44m2Pi4FGioUHGAUlYz4LpqA%3D)
14. [victoriametrics.com](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQGQxWBgScAlmGRguZNjXZ8jXsKNcq7JqVaq5tR2IYto7rYxAjyyP_s_fObGIV1X5ndhR0BlphNdlW9v4ctbjAU8Muc_Oxe5uk-tS5LZeMJiIzooU1tjOs60g5YZDmlK)







# Gemini 4 Hydrogen Question No 2 - 2026-11-21 19:38-Hours

## Request

Please generate a PowerShell script which will be stored in a file and run from the command line. 

The script should incorporate:

```powershell
curl -sL "https://pkg.go.dev/v1/package/math/big?version=v1.27.4&doc=md&examples=true" \
  | jq -r '.docs' > math_big_go1.27.4.md
```

 By the way, I tried this syntax in a powershell **`.ps1`** script file and it failed with the following error message:

```bash
Line |
   2 |    | jq -r '.docs' > math_big_go1.27.4.md
     |      ~~
     | The term 'jq' is not recognized as a name of a cmdlet, function, script file, or executable program. Check the
     | spelling of the name, or if a path was included, verify that the path is correct and try again.
```



# Gemini 4 Hydrogen Response No 2 - 2026-11-21 19:46-Hours

### Why the Original Command Failed in PowerShell

There are three incompatibilities when pasting that Bash command directly into a Windows `.ps1` script:

1. **`jq` is not installed by default on Windows:** That causes the `The term 'jq' is not recognized...` error. PowerShell has built-in JSON parsing (`Invoke-RestMethod` and `ConvertFrom-Json`), so you don't need `jq` at all.
2. **Line continuation syntax differs:** Bash uses `\`, whereas PowerShell uses a backtick (`` ` ``).
3. **`curl` in Windows PowerShell 5.1:** In the default Windows PowerShell (`powershell.exe`), `curl` is an alias for `Invoke-WebRequest`, which does not accept `-sL`. (You would either use `curl.exe` explicitly or use PowerShell's native `Invoke-RestMethod`.)

---

### PowerShell Script (`Get-GoPackageDoc.ps1`)

Save the following as `Get-GoPackageDoc.ps1`. It uses native PowerShell (`Invoke-RestMethod`) to query the `pkg.go.dev` JSON API with **zero external dependencies** (`jq` not required), extracts the `.docs` Markdown field, and writes clean **UTF-8 (without BOM)** so WSL2 and your RAG tools read it cleanly.

```powershell
<#
.SYNOPSIS
    Downloads Go package documentation in Markdown format from the pkg.go.dev API.

.EXAMPLE
    .\Get-GoPackageDoc.ps1
    Downloads math/big v1.27.4 to math_big_go1.27.4.md in the current directory.

.EXAMPLE
    .\Get-GoPackageDoc.ps1 -Package "encoding/json" -Version "v1.27.4" -OutputFile "json_go1.27.4.md"
#>

[CmdletBinding()]
param(
    [string]$Package = "math/big",
    [string]$Version = "v1.27.4",
    [string]$OutputFile
)

$ErrorActionPreference = "Stop"

# Ensure TLS 1.2 is enabled on Windows PowerShell 5.1
if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

# Build default output filename if not provided (e.g., math_big_go1.27.4.md)
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $safePkg = $Package -replace '/', '_'
    $verLabel = $Version.TrimStart('v')
    $OutputFile = "${safePkg}_go${verLabel}.md"
}

$uri = "https://pkg.go.dev/v1/package/${Package}?version=${Version}&doc=md&examples=true"

Write-Host "Fetching documentation from: $uri" -ForegroundColor Cyan

try {
    # Invoke-RestMethod automatically follows redirects and parses the JSON response
    $response = Invoke-RestMethod -Uri $uri -Method Get
}
catch {
    Write-Error "Failed to fetch documentation from pkg.go.dev API: $_"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($response.docs)) {
    Write-Error "API response did not contain 'docs' content. Returned version: $($response.version)"
    exit 1
}

# Resolve path against PowerShell's working directory and write UTF-8 without BOM
$fullOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($fullOutputPath, $response.docs, $utf8NoBom)

Write-Host "Saved $($response.modulePath) ($($response.version)) documentation to: $fullOutputPath" -ForegroundColor Green
```

---

### How to Run It from the Command Line

From PowerShell in the directory containing `Get-GoPackageDoc.ps1`:

```powershell
# Run with defaults (math/big v1.27.4 -> math_big_go1.27.4.md)
.\Get-GoPackageDoc.ps1

# Or specify any standard library or third-party package:
.\Get-GoPackageDoc.ps1 -Package "crypto/sha256" -Version "v1.27.4"
```

If Windows blocks local scripts due to execution policy, run it with:
```powershell
powershell -ExecutionPolicy Bypass -File .\Get-GoPackageDoc.ps1
```

---

### Alternative: Direct `curl.exe` One-Liner (No `jq` Needed)

If you specifically want to use Windows' built-in `curl.exe` inside a script without `jq`, you can pipe its output to PowerShell's `ConvertFrom-Json` instead:

```powershell
(curl.exe -sL "https://pkg.go.dev/v1/package/math/big?version=v1.27.4&doc=md&examples=true" | ConvertFrom-Json).docs |
    Set-Content -Path "math_big_go1.27.4.md" -Encoding UTF8
```

### Sources

1. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQFZ80Wvj-OIPquTvtX0s52tCxi8GsPFVYO2j6zvx-DLPQUGf5eBforpG0MPrAsIHn0Rl6FzT5fL3c4XczxVDEGQTg3dBLkBmC8cWe0-Eu8%3D)
2. [go.dev](https://www.google.com/url?sa=E&q=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fgrounding-api-redirect%2FAUZIYQE80M9z6dZvmP9A3dpoC4IpEJb_zmWotpIG3LuAKsprMS8luSw55p5FkzQJsfvRpmwtFAMIALa6wuhaZ6akcRBeUTbTzpgeV9FayTiFBujzPd0iUcm99NUylJg22XH-PiLjOV-1WynZSSEd)



# Gemini 4 Hydrogen Question No 3 - 2026-11-21 19:49-Hours

I'm using Powershell ***Version 7.7.0***. Does that affect the `Get-GoPackageDoc.ps1` script that you provided?





# Gemini 4 Hydrogen Response No 3 - 2026-11-21 19:52-Hours

**No—`Get-GoPackageDoc.ps1` works as-is on PowerShell 7.7.0.**

None of the breaking changes introduced in PowerShell 7.7.0 (such as `New-Guid` defaulting to UUIDv7, stricter `-Property` validation on `Format-*` cmdlets, or `-Switch:$false` parameter adjustments) affect any cmdlet or .NET 11 API used in the script.

Here is how PowerShell 7.7.0 interacts with the script and a couple of minor details worth knowing:

### 1. Everything in `Get-GoPackageDoc.ps1` Is 7.7-Compatible
* **`Invoke-RestMethod`:** Works natively in 7.7.0 with modern TLS and automatic JSON parsing.
* **The TLS 1.2 block (`if ($PSVersionTable.PSVersion.Major -lt 6)`):** Automatically skipped in 7.7.0, since .NET 11 handles modern TLS by default.
* **UTF-8 (No BOM) writing:** `[System.IO.File]::WriteAllText` with `UTF8Encoding($false)` works identically on .NET 11.

### 2. Optional Simplification for PowerShell 7.7-Only Environments
I wrote the `.ps1` script to avoid BOM and UTF-16LE encoding issues in older Windows PowerShell 5.1. Because you are on **7.7.0**, PowerShell's native file cmdlets (`Set-Content`, `Out-File`, and `>`) **already default to UTF-8 without BOM**.

If you don't need backward compatibility with Windows PowerShell 5.1, you can shorten the script significantly:

```powershell
[CmdletBinding()]
param(
    [string]$Package = "math/big",
    [string]$Version = "v1.27.4",
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

$response.docs | Set-Content -Path $OutputFile -NoNewline
Write-Host "Saved $($response.modulePath) ($($response.version)) to $OutputFile" -ForegroundColor Green
```

### 3. Two 7.7.0 Operational Notes
* **Use `pwsh`, not `powershell`, from external callers:** If you invoke the script from `cmd.exe`, JetBrains, Zed, or a batch file, run:
  ```powershell
  pwsh -ExecutionPolicy Bypass -File .\Get-GoPackageDoc.ps1
  ```
  Running `powershell` instead of `pwsh` launches Windows 11's legacy 5.1 engine. Also note that PowerShell 7.7.0 is distributed as an MSIX package rather than a traditional MSI, so calling `pwsh` directly (relying on `PATH` / the Windows App Execution Alias) is safer than hardcoding `C:\Program Files\PowerShell\7\pwsh.exe`.
* **Why your original snippet failed on `jq` rather than `curl`:** Unlike Windows PowerShell 5.1, PowerShell 7.x removed the `curl` alias, so `curl -sL` in 7.7.0 actually invoked Windows' `curl.exe`. However, the Bash trailing `\` would still be passed as a literal argument to `curl.exe` rather than acting as a line continuation, and `jq` is still absent unless installed separately (e.g., via `winget install jqlang.jq`). With `Invoke-RestMethod`, you don't need either tool.





# Gemini 4 Hydrogen Question No 4 - 2026-11-21 20:04-Hours

I ran the script you provided:

```powershell
[CmdletBinding()]
param(
    [string]$Package = "math/big",
    [string]$Version = "v1.27.4",
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

$response.docs | Set-Content -Path $OutputFile -NoNewline
Write-Host "Saved $($response.modulePath) ($($response.version)) to $OutputFile" -ForegroundColor Green

```

It returned the following markdown: 

(Note: I added the Table of Contents)

------



- [package big](#package-big)
  	- [Example (eConvergents)](#example-econvergents)
  		- [Example (fibonacci)](#example-fibonacci)
  		- [Example (sqrt2)](#example-sqrt2)
  - [Constants](#constants)
  - [Functions](#functions)
  - [Types](#types)
    	- [Example (shift)](#example-shift)
    	- [Example](#example)
    	- [Example](#example-1)
    	- [Example](#example-2)
    	- [Example](#example-3)
    	- [Example](#example-4)
    	- [Example](#example-5)
    	- [Example](#example-6)
    	- [Example](#example-7)
    	- [Example](#example-8)
    	- [Example](#example-9)


# package big

Package big implements arbitrary-precision arithmetic (big numbers). The following numeric types are supported:

	Int    signed integers
	Rat    rational numbers
	Float  floating-point numbers

The zero value for an [Int](#Int), [Rat](#Rat), or [Float](#Float) correspond to 0. Thus, new values can be declared in the usual ways and denote 0 without further initialization:

	var x Int        // &x is an *Int of value 0
	var r = &Rat{}   // r is a *Rat of value 0
	y := new(Float)  // y is a *Float of value 0

Alternatively, new values can be allocated and initialized with factory functions of the form:

	func NewT(v V) *T

For instance, [NewInt](#NewInt)(x) returns an \*[Int](#Int) set to the value of the int64 argument x, [NewRat](#NewRat)(a, b) returns a \*[Rat](#Rat) set to the fraction a/b where a and b are int64 values, and [NewFloat](#NewFloat)(f) returns a \*[Float](#Float) initialized to the float64 argument f. More flexibility is provided with explicit setters, for instance:

	var z1 Int
	z1.SetUint64(123)                 // z1 := 123
	z2 := new(Rat).SetFloat64(1.25)   // z2 := 5/4
	z3 := new(Float).SetInt(z1)       // z3 := 123.0

Setters, numeric operations and predicates are represented as methods of the form:

	func (z *T) SetV(v V) *T          // z = v
	func (z *T) Unary(x *T) *T        // z = unary x
	func (z *T) Binary(x, y *T) *T    // z = x binary y
	func (x *T) Pred() P              // p = pred(x)

with T one of [Int](#Int), [Rat](#Rat), or [Float](#Float). For unary and binary operations, the result is the receiver (usually named z in that case; see below); if it is one of the operands x or y it may be safely overwritten (and its memory reused).

Arithmetic expressions are typically written as a sequence of individual method calls, with each call corresponding to an operation. The receiver denotes the result and the method arguments are the operation's operands. For instance, given three \*Int values a, b and c, the invocation

	c.Add(a, b)

computes the sum a + b and stores the result in c, overwriting whatever value was held in c before. Unless specified otherwise, operations permit aliasing of parameters, so it is perfectly ok to write

	sum.Add(sum, x)

to accumulate values x in a sum.

(By always passing in a result value via the receiver, memory use can be much better controlled. Instead of having to allocate new memory for each result, an operation can reuse the space allocated for the result value, and overwrite that value with the new result in the process.)

Notational convention: Incoming method parameters (including the receiver) are named consistently in the API to clarify their use. Incoming operands are usually named x, y, a, b, and so on, but never z. A parameter specifying the result is named z (typically the receiver).

For instance, the arguments for (\*Int).Add are named x and y, and because the receiver specifies the result destination, it is called z:

	func (z *Int) Add(x, y *Int) *Int

Methods of this form typically return the incoming receiver as well, to enable simple call chaining.

Methods which don't require a result value to be passed in (for instance, [Int.Sign](#Int.Sign)), simply return the result. In this case, the receiver is typically the first operand, named x:

	func (x *Int) Sign() int

Various methods support conversions between strings and corresponding numeric values, and vice versa: \*[Int](#Int), \*[Rat](#Rat), and \*[Float](#Float) values implement the Stringer interface for a (default) string representation of the value, but also provide SetString methods to initialize a value from a string in a variety of supported formats (see the respective SetString documentation).

Finally, \*[Int](#Int), \*[Rat](#Rat), and \*[Float](#Float) satisfy [fmt.Scanner](/fmt#Scanner) for scanning and (except for \*[Rat](#Rat)) the Formatter interface for formatted printing.

#### Example (eConvergents)

This example demonstrates how to use big.Rat to compute the first 15 terms in the sequence of rational convergents for the constant e (base of natural logarithm).

```go
// Copyright 2015 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package big_test

import (
	"fmt"
	"math/big"
)

// Use the classic continued fraction for e
//
//	e = [1; 0, 1, 1, 2, 1, 1, ... 2n, 1, 1, ...]
//
// i.e., for the nth term, use
//
//	   1          if   n mod 3 != 1
//	(n-1)/3 * 2   if   n mod 3 == 1
func recur(n, lim int64) *big.Rat {
	term := new(big.Rat)
	if n%3 != 1 {
		term.SetInt64(1)
	} else {
		term.SetInt64((n - 1) / 3 * 2)
	}

	if n > lim {
		return term
	}

	// Directly initialize frac as the fractional
	// inverse of the result of recur.
	frac := new(big.Rat).Inv(recur(n+1, lim))

	return term.Add(term, frac)
}

// This example demonstrates how to use big.Rat to compute the
// first 15 terms in the sequence of rational convergents for
// the constant e (base of natural logarithm).
func Example_eConvergents() {
	for i := 1; i <= 15; i++ {
		r := recur(0, int64(i))

		// Print r both as a fraction and as a floating-point number.
		// Since big.Rat implements fmt.Formatter, we can use %-13s to
		// get a left-aligned string representation of the fraction.
		fmt.Printf("%-13s = %s\n", r, r.FloatString(8))
	}

	// Output:
	// 2/1           = 2.00000000
	// 3/1           = 3.00000000
	// 8/3           = 2.66666667
	// 11/4          = 2.75000000
	// 19/7          = 2.71428571
	// 87/32         = 2.71875000
	// 106/39        = 2.71794872
	// 193/71        = 2.71830986
	// 1264/465      = 2.71827957
	// 1457/536      = 2.71828358
	// 2721/1001     = 2.71828172
	// 23225/8544    = 2.71828184
	// 25946/9545    = 2.71828182
	// 49171/18089   = 2.71828183
	// 517656/190435 = 2.71828183
}

```

Output:

```
2/1           = 2.00000000
3/1           = 3.00000000
8/3           = 2.66666667
11/4          = 2.75000000
19/7          = 2.71428571
87/32         = 2.71875000
106/39        = 2.71794872
193/71        = 2.71830986
1264/465      = 2.71827957
1457/536      = 2.71828358
2721/1001     = 2.71828172
23225/8544    = 2.71828184
25946/9545    = 2.71828182
49171/18089   = 2.71828183
517656/190435 = 2.71828183

```

#### Example (fibonacci)

This example demonstrates how to use big.Int to compute the smallest Fibonacci number with 100 decimal digits and to test whether it is prime.

```go
{

	a := big.NewInt(0)
	b := big.NewInt(1)

	// Initialize limit as 10^99, the smallest integer with 100 digits.
	var limit big.Int
	limit.Exp(big.NewInt(10), big.NewInt(99), nil)

	for a.Cmp(&limit) < 0 {

		a.Add(a, b)

		a, b = b, a
	}
	fmt.Println(a)

	fmt.Println(a.ProbablyPrime(20))

}
```

Output:

```
1344719667586153181419716641724567886890850696275767987106294472017884974410332069524504824747437757
false

```

#### Example (sqrt2)

This example shows how to use big.Float to compute the square root of 2 with a precision of 200 bits, and how to print the result as a decimal number.

```go
{
	// We'll do computations with 200 bits of precision in the mantissa.
	const prec = 200

	steps := int(math.Log2(prec))

	two := new(big.Float).SetPrec(prec).SetInt64(2)
	half := new(big.Float).SetPrec(prec).SetFloat64(0.5)

	x := new(big.Float).SetPrec(prec).SetInt64(1)

	t := new(big.Float)

	for i := 0; i <= steps; i++ {
		t.Quo(two, x)
		t.Add(x, t)
		x.Mul(half, t)
	}

	fmt.Printf("sqrt(2) = %.50f\n", x)

	t.Mul(x, x)
	fmt.Printf("error = %e\n", t.Sub(two, t))

}
```

Output:

```
sqrt(2) = 1.41421356237309504880168872420969807856967187537695
error = 0.000000e+00

```

## Constants

```go
const (
	MaxExp  = math.MaxInt32  // largest supported exponent
	MinExp  = math.MinInt32  // smallest supported exponent
	MaxPrec = math.MaxUint32 // largest (theoretically) supported precision; likely memory-limited
)
```

Exponent and precision limits.

```go
const (
	Trunc = ToZero        // T-division (same as Go division)
	Floor = ToNegativeInf // F-division
	Round = ToNearestEven // R-division
	Ceil  = ToPositiveInf // C-division
)
```

Rounding modes that determine how the integer quotient is adjusted in an integer division. See Daan Leijen, “Division and Modulus for Computer Scientists”, for details.

```go
const MaxBase = 10 + ('z' - 'a' + 1) + ('Z' - 'A' + 1)
```

MaxBase is the largest number base accepted for string conversions.

## Functions

```go
func Jacobi(x, y *Int) int
```

Jacobi returns the Jacobi symbol (x/y), either +1, -1, or 0. The y argument must be an odd integer.

## Types

```go
type Accuracy int8
```

Accuracy describes the rounding error produced by the most recent operation that generated a [Float](#Float) value, relative to the exact value.

```go
const (
	Below Accuracy = -1
	Exact Accuracy = 0
	Above Accuracy = +1
)
```

Constants describing the [Accuracy](#Accuracy) of a [Float](#Float).

```go
func (i Accuracy) String() string
```

```go
type ErrNaN struct {
	// contains filtered or unexported fields
}
```

An ErrNaN panic is raised by a [Float](#Float) operation that would lead to a NaN under IEEE 754 rules. An ErrNaN implements the error interface.

```go
func (err ErrNaN) Error() string
```

```go
type Float struct {
	// contains filtered or unexported fields
}
```

A nonzero finite Float represents a multi-precision floating point number

	sign × mantissa × 2**exponent

with 0.5 \<= mantissa \< 1.0, and MinExp \<= exponent \<= MaxExp. A Float may also be zero (+0, -0) or infinite (+Inf, -Inf). All Floats are ordered, and the ordering of two Floats x and y is defined by x.Cmp(y).

Each Float value also has a precision, rounding mode, and accuracy. The precision is the maximum number of mantissa bits available to represent the value. The rounding mode specifies how a result should be rounded to fit into the mantissa bits, and accuracy describes the rounding error with respect to the exact result.

Unless specified otherwise, all operations (including setters) that specify a \*Float variable for the result (usually via the receiver with the exception of [Float.MantExp](#Float.MantExp)), round the numeric result according to the precision and rounding mode of the result variable.

If the provided result precision is 0 (see below), it is set to the precision of the argument with the largest precision value before any rounding takes place, and the rounding mode remains unchanged. Thus, uninitialized Floats provided as result arguments will have their precision set to a reasonable value determined by the operands, and their mode is the zero value for RoundingMode (ToNearestEven).

By setting the desired precision to 24 or 53 and using matching rounding mode (typically [ToNearestEven](#ToNearestEven)), Float operations produce the same results as the corresponding float32 or float64 IEEE 754 arithmetic for operands that correspond to normal (i.e., not denormal) float32 or float64 numbers. Exponent underflow and overflow lead to a 0 or an Infinity for different values than IEEE 754 because Float exponents have a much larger range.

The zero (uninitialized) value for a Float is ready to use and represents the number +0.0 exactly, with precision 0 and rounding mode [ToNearestEven](#ToNearestEven).

Operations always take pointer arguments (\*Float) rather than Float values, and each unique Float value requires its own unique \*Float pointer. To "copy" a Float value, an existing (or newly allocated) Float must be set to a new value using the [Float.Set](#Float.Set) method; shallow copies of Floats are not supported and may lead to errors.

#### Example (shift)

```go
{

	for s := -5; s <= 5; s++ {
		x := big.NewFloat(0.5)
		x.SetMantExp(x, x.MantExp(nil)+s)
		fmt.Println(x)
	}

}
```

Output:

```
0.015625
0.03125
0.0625
0.125
0.25
0.5
1
2
4
8
16

```

```go
func NewFloat(x float64) *Float
```

NewFloat allocates and returns a new [Float](#Float) set to x, with precision 53 and rounding mode [ToNearestEven](#ToNearestEven). NewFloat panics with [ErrNaN](#ErrNaN) if x is a NaN.

```go
func ParseFloat(s string, base int, prec uint, mode RoundingMode) (f *Float, b int, err error)
```

ParseFloat is like f.Parse(s, base) with f set to the given precision and rounding mode.

```go
func (z *Float) Abs(x *Float) *Float
```

Abs sets z to the (possibly rounded) value |x| (the absolute value of x) and returns z.

```go
func (x *Float) Acc() Accuracy
```

Acc returns the accuracy of x produced by the most recent operation, unless explicitly documented otherwise by that operation.

```go
func (z *Float) Add(x, y *Float) *Float
```

Add sets z to the rounded sum x+y and returns z. If z's precision is 0, it is changed to the larger of x's or y's precision before the operation. Rounding is performed according to z's precision and rounding mode; and z's accuracy reports the result error relative to the exact (not rounded) result. Add panics with [ErrNaN](#ErrNaN) if x and y are infinities with opposite signs. The value of z is undefined in that case.

#### Example

```go
{
	// Operate on numbers of different precision.
	var x, y, z big.Float
	x.SetInt64(1000)
	y.SetFloat64(2.718281828)
	z.SetPrec(32)
	z.Add(&x, &y)
	fmt.Printf("x = %.10g (%s, prec = %d, acc = %s)\n", &x, x.Text('p', 0), x.Prec(), x.Acc())
	fmt.Printf("y = %.10g (%s, prec = %d, acc = %s)\n", &y, y.Text('p', 0), y.Prec(), y.Acc())
	fmt.Printf("z = %.10g (%s, prec = %d, acc = %s)\n", &z, z.Text('p', 0), z.Prec(), z.Acc())

}
```

Output:

```
x = 1000 (0x.fap+10, prec = 64, acc = Exact)
y = 2.718281828 (0x.adf85458248cd8p+2, prec = 53, acc = Exact)
z = 1002.718282 (0x.faadf854p+10, prec = 32, acc = Below)

```

```go
func (x *Float) Append(buf []byte, fmt byte, prec int) []byte
```

Append appends to buf the string form of the floating-point number x, as generated by x.Text, and returns the extended buffer.

```go
func (x *Float) AppendText(b []byte) ([]byte, error)
```

AppendText implements the [encoding.TextAppender](/encoding#TextAppender) interface. Only the [Float](#Float) value is marshaled (in full precision), other attributes such as precision or accuracy are ignored.

```go
func (x *Float) Cmp(y *Float) int
```

Cmp compares x and y and returns:

  - \-1 if x \< y;
  - 0 if x == y (incl. -0 == 0, -Inf == -Inf, and +Inf == +Inf);
  - \+1 if x > y.

#### Example

```go
{
	inf := math.Inf(1)
	zero := 0.0

	operands := []float64{-inf, -1.2, -zero, 0, +1.2, +inf}

	fmt.Println("   x     y  cmp")
	fmt.Println("---------------")
	for _, x64 := range operands {
		x := big.NewFloat(x64)
		for _, y64 := range operands {
			y := big.NewFloat(y64)
			fmt.Printf("%4g  %4g  %3d\n", x, y, x.Cmp(y))
		}
		fmt.Println()
	}

}
```

Output:

```
   x     y  cmp
---------------
-Inf  -Inf    0
-Inf  -1.2   -1
-Inf    -0   -1
-Inf     0   -1
-Inf   1.2   -1
-Inf  +Inf   -1

-1.2  -Inf    1
-1.2  -1.2    0
-1.2    -0   -1
-1.2     0   -1
-1.2   1.2   -1
-1.2  +Inf   -1

  -0  -Inf    1
  -0  -1.2    1
  -0    -0    0
  -0     0    0
  -0   1.2   -1
  -0  +Inf   -1

   0  -Inf    1
   0  -1.2    1
   0    -0    0
   0     0    0
   0   1.2   -1
   0  +Inf   -1

 1.2  -Inf    1
 1.2  -1.2    1
 1.2    -0    1
 1.2     0    1
 1.2   1.2    0
 1.2  +Inf   -1

+Inf  -Inf    1
+Inf  -1.2    1
+Inf    -0    1
+Inf     0    1
+Inf   1.2    1
+Inf  +Inf    0

```

```go
func (z *Float) Copy(x *Float) *Float
```

Copy sets z to x, with the same precision, rounding mode, and accuracy as x. Copy returns z. If x and z are identical, Copy is a no-op.

#### Example

```go
{
	var x, z big.Float

	x.SetFloat64(1.23)
	r := z.Copy(&x)
	fmt.Printf("a) r = %g, z = %g, x = %g, r == z = %v\n", r, &z, &x, r == &z)

	z.SetInt64(42)
	fmt.Printf("b) r = %g, z = %g, r == z = %v\n", r, &z, r == &z)

	x.SetPrec(1)
	z.Copy(&x)
	fmt.Printf("c) z = %g, x = %g, z == x = %v\n", &z, &x, &z == &x)

}
```

Output:

```
a) r = 1.23, z = 1.23, x = 1.23, r == z = true
b) r = 42, z = 42, r == z = true
c) z = 1, x = 1, z == x = false

```

```go
func (x *Float) Float32() (float32, Accuracy)
```

Float32 returns the float32 value nearest to x. If x is too small to be represented by a float32 (|x| \< [math.SmallestNonzeroFloat32](/math#SmallestNonzeroFloat32)), the result is (0, [Below](#Below)) or (-0, [Above](#Above)), respectively, depending on the sign of x. If x is too large to be represented by a float32 (|x| > [math.MaxFloat32](/math#MaxFloat32)), the result is (+Inf, [Above](#Above)) or (-Inf, [Below](#Below)), depending on the sign of x.

```go
func (x *Float) Float64() (float64, Accuracy)
```

Float64 returns the float64 value nearest to x. If x is too small to be represented by a float64 (|x| \< [math.SmallestNonzeroFloat64](/math#SmallestNonzeroFloat64)), the result is (0, [Below](#Below)) or (-0, [Above](#Above)), respectively, depending on the sign of x. If x is too large to be represented by a float64 (|x| > [math.MaxFloat64](/math#MaxFloat64)), the result is (+Inf, [Above](#Above)) or (-Inf, [Below](#Below)), depending on the sign of x.

```go
func (x *Float) Format(s fmt.State, format rune)
```

Format implements [fmt.Formatter](/fmt#Formatter). It accepts all the regular formats for floating-point numbers ('b', 'e', 'E', 'f', 'F', 'g', 'G', 'x') as well as 'p' and 'v'. See (\*Float).Text for the interpretation of 'p'. The 'v' format is handled like 'g'. Format also supports specification of the minimum precision in digits, the output field width, as well as the format flags '+' and ' ' for sign control, '0' for space or zero padding, and '-' for left or right justification. See the fmt package for details.

```go
func (z *Float) GobDecode(buf []byte) error
```

GobDecode implements the [encoding/gob.GobDecoder](/encoding/gob#GobDecoder) interface. The result is rounded per the precision and rounding mode of z unless z's precision is 0, in which case z is set exactly to the decoded value.

```go
func (x *Float) GobEncode() ([]byte, error)
```

GobEncode implements the [encoding/gob.GobEncoder](/encoding/gob#GobEncoder) interface. The [Float](#Float) value and all its attributes (precision, rounding mode, accuracy) are marshaled.

```go
func (x *Float) Int(z *Int) (*Int, Accuracy)
```

Int returns the result of truncating x towards zero; or nil if x is an infinity. The result is [Exact](#Exact) if x.IsInt(); otherwise it is [Below](#Below) for x > 0, and [Above](#Above) for x \< 0. If a non-nil \*[Int](#Int) argument z is provided, [Int](#Int) stores the result in z instead of allocating a new [Int](#Int).

```go
func (x *Float) Int64() (int64, Accuracy)
```

Int64 returns the integer resulting from truncating x towards zero. If [math.MinInt64](/math#MinInt64) \<= x \<= [math.MaxInt64](/math#MaxInt64), the result is [Exact](#Exact) if x is an integer, and [Above](#Above) (x \< 0) or [Below](#Below) (x > 0) otherwise. The result is ([math.MinInt64](/math#MinInt64), [Above](#Above)) for x \< [math.MinInt64](/math#MinInt64), and ([math.MaxInt64](/math#MaxInt64), [Below](#Below)) for x > [math.MaxInt64](/math#MaxInt64).

```go
func (x *Float) IsInf() bool
```

IsInf reports whether x is +Inf or -Inf.

```go
func (x *Float) IsInt() bool
```

IsInt reports whether x is an integer. ±Inf values are not integers.

```go
func (x *Float) MantExp(mant *Float) (exp int)
```

MantExp breaks x into its mantissa and exponent components and returns the exponent. If a non-nil mant argument is provided its value is set to the mantissa of x, with the same precision and rounding mode as x. The components satisfy x == mant × 2\*\*exp, with 0.5 \<= |mant| \< 1.0. Calling MantExp with a nil argument is an efficient way to get the exponent of the receiver.

Special cases are:

	(  ±0).MantExp(mant) = 0, with mant set to   ±0
	(±Inf).MantExp(mant) = 0, with mant set to ±Inf

x and mant may be the same in which case x is set to its mantissa value.

```go
func (x *Float) MarshalText() (text []byte, err error)
```

MarshalText implements the [encoding.TextMarshaler](/encoding#TextMarshaler) interface. Only the [Float](#Float) value is marshaled (in full precision), other attributes such as precision or accuracy are ignored.

```go
func (x *Float) MinPrec() uint
```

MinPrec returns the minimum precision required to represent x exactly (i.e., the smallest prec before x.SetPrec(prec) would start rounding x). The result is 0 for |x| == 0 and |x| == Inf.

```go
func (x *Float) Mode() RoundingMode
```

Mode returns the rounding mode of x.

```go
func (z *Float) Mul(x, y *Float) *Float
```

Mul sets z to the rounded product x\*y and returns z. Precision, rounding, and accuracy reporting are as for [Float.Add](#Float.Add). Mul panics with [ErrNaN](#ErrNaN) if one operand is zero and the other operand an infinity. The value of z is undefined in that case.

```go
func (z *Float) Neg(x *Float) *Float
```

Neg sets z to the (possibly rounded) value of x with its sign negated, and returns z.

```go
func (z *Float) Parse(s string, base int) (f *Float, b int, err error)
```

Parse parses s which must contain a text representation of a floating- point number with a mantissa in the given conversion base (the exponent is always a decimal number), or a string representing an infinite value.

For base 0, an underscore character “\_” may appear between a base prefix and an adjacent digit, and between successive digits; such underscores do not change the value of the number, or the returned digit count. Incorrect placement of underscores is reported as an error if there are no other errors. If base != 0, underscores are not recognized and thus terminate scanning like any other character that is not a valid radix point or digit.

It sets z to the (possibly rounded) value of the corresponding floating- point value, and returns z, the actual base b, and an error err, if any. The entire string (not just a prefix) must be consumed for success. If z's precision is 0, it is changed to 64 before rounding takes effect. The number must be of the form:

	number    = [ sign ] ( float | "inf" | "Inf" ) .
	sign      = "+" | "-" .
	float     = ( mantissa | prefix pmantissa ) [ exponent ] .
	prefix    = "0" [ "b" | "B" | "o" | "O" | "x" | "X" ] .
	mantissa  = digits "." [ digits ] | digits | "." digits .
	pmantissa = [ "_" ] digits "." [ digits ] | [ "_" ] digits | "." digits .
	exponent  = ( "e" | "E" | "p" | "P" ) [ sign ] digits .
	digits    = digit { [ "_" ] digit } .
	digit     = "0" ... "9" | "a" ... "z" | "A" ... "Z" .

The base argument must be 0, 2, 8, 10, or 16. Providing an invalid base argument will lead to a run-time panic.

For base 0, the number prefix determines the actual base: A prefix of “0b” or “0B” selects base 2, “0o” or “0O” selects base 8, and “0x” or “0X” selects base 16. Otherwise, the actual base is 10 and no prefix is accepted. The octal prefix "0" is not supported (a leading "0" is simply considered a "0").

A "p" or "P" exponent indicates a base 2 (rather than base 10) exponent; for instance, "0x1.fffffffffffffp1023" (using base 0) represents the maximum float64 value. For hexadecimal mantissae, the exponent character must be one of 'p' or 'P', if present (an "e" or "E" exponent indicator cannot be distinguished from a mantissa digit).

The returned \*Float f is nil and the value of z is valid but not defined if an error is reported.

```go
func (x *Float) Prec() uint
```

Prec returns the mantissa precision of x in bits. The result may be 0 for |x| == 0 and |x| == Inf.

```go
func (z *Float) Quo(x, y *Float) *Float
```

Quo sets z to the rounded quotient x/y and returns z. Precision, rounding, and accuracy reporting are as for [Float.Add](#Float.Add). Quo panics with [ErrNaN](#ErrNaN) if both operands are zero or infinities. The value of z is undefined in that case.

```go
func (x *Float) Rat(z *Rat) (*Rat, Accuracy)
```

Rat returns the rational number corresponding to x; or nil if x is an infinity. The result is [Exact](#Exact) if x is not an Inf. If a non-nil \*[Rat](#Rat) argument z is provided, [Rat](#Rat) stores the result in z instead of allocating a new [Rat](#Rat).

```go
func (z *Float) Scan(s fmt.ScanState, ch rune) error
```

Scan is a support routine for [fmt.Scanner](/fmt#Scanner); it sets z to the value of the scanned number. It accepts formats whose verbs are supported by [fmt.Scan](/fmt#Scan) for floating point values, which are: 'b' (binary), 'e', 'E', 'f', 'F', 'g' and 'G'. Scan doesn't handle ±Inf.

#### Example

```go
{

	f := new(big.Float)
	_, err := fmt.Sscan("1.19282e99", f)
	if err != nil {
		log.Println("error scanning value:", err)
	} else {
		fmt.Println(f)
	}

}
```

Output:

```
1.19282e+99

```

```go
func (z *Float) Set(x *Float) *Float
```

Set sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to the precision of x before setting z (and rounding will have no effect). Rounding is performed according to z's precision and rounding mode; and z's accuracy reports the result error relative to the exact (not rounded) result.

```go
func (z *Float) SetFloat64(x float64) *Float
```

SetFloat64 sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to 53 (and rounding will have no effect). SetFloat64 panics with [ErrNaN](#ErrNaN) if x is a NaN.

```go
func (z *Float) SetInf(signbit bool) *Float
```

SetInf sets z to the infinite Float -Inf if signbit is set, or +Inf if signbit is not set, and returns z. The precision of z is unchanged and the result is always [Exact](#Exact).

```go
func (z *Float) SetInt(x *Int) *Float
```

SetInt sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to the larger of x.BitLen() or 64 (and rounding will have no effect).

```go
func (z *Float) SetInt64(x int64) *Float
```

SetInt64 sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to 64 (and rounding will have no effect).

```go
func (z *Float) SetMantExp(mant *Float, exp int) *Float
```

SetMantExp sets z to mant × 2\*\*exp and returns z. The result z has the same precision and rounding mode as mant. SetMantExp is an inverse of [Float.MantExp](#Float.MantExp) but does not require 0.5 \<= |mant| \< 1.0. Specifically, for a given x of type \*[Float](#Float), SetMantExp relates to [Float.MantExp](#Float.MantExp) as follows:

	mant := new(Float)
	new(Float).SetMantExp(mant, x.MantExp(mant)).Cmp(x) == 0

Special cases are:

	z.SetMantExp(  ±0, exp) =   ±0
	z.SetMantExp(±Inf, exp) = ±Inf

z and mant may be the same in which case z's exponent is set to exp.

```go
func (z *Float) SetMode(mode RoundingMode) *Float
```

SetMode sets z's rounding mode to mode and returns an exact z. z remains unchanged otherwise. z.SetMode(z.Mode()) is a cheap way to set z's accuracy to [Exact](#Exact).

```go
func (z *Float) SetPrec(prec uint) *Float
```

SetPrec sets z's precision to prec and returns the (possibly) rounded value of z. Rounding occurs according to z's rounding mode if the mantissa cannot be represented in prec bits without loss of precision. SetPrec(0) maps all finite values to ±0; infinite values remain unchanged. If prec > [MaxPrec](#MaxPrec), it is set to [MaxPrec](#MaxPrec).

```go
func (z *Float) SetRat(x *Rat) *Float
```

SetRat sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to the largest of a.BitLen(), b.BitLen(), or 64; with x = a/b.

```go
func (z *Float) SetString(s string) (*Float, bool)
```

SetString sets z to the value of s and returns z and a boolean indicating success. s must be a floating-point number of the same format as accepted by [Float.Parse](#Float.Parse), with base argument 0. The entire string (not just a prefix) must be valid for success. If the operation failed, the value of z is undefined but the returned value is nil.

#### Example

```go
{
	f := new(big.Float)
	f.SetString("3.14159")
	fmt.Println(f)

}
```

Output:

```
3.14159

```

```go
func (z *Float) SetUint64(x uint64) *Float
```

SetUint64 sets z to the (possibly rounded) value of x and returns z. If z's precision is 0, it is changed to 64 (and rounding will have no effect).

```go
func (x *Float) Sign() int
```

Sign returns:

  - \-1 if x \< 0;
  - 0 if x is ±0;
  - \+1 if x > 0.

```go
func (x *Float) Signbit() bool
```

Signbit reports whether x is negative or negative zero.

```go
func (z *Float) Sqrt(x *Float) *Float
```

Sqrt sets z to the rounded square root of x, and returns it.

If z's precision is 0, it is changed to x's precision before the operation. Rounding is performed according to z's precision and rounding mode, but z's accuracy is not computed. Specifically, the result of z.Acc() is undefined.

The function panics if z \< 0. The value of z is undefined in that case.

```go
func (x *Float) String() string
```

String formats x like x.Text('g', 10). (String must be called explicitly, [Float.Format](#Float.Format) does not support %s verb.)

```go
func (z *Float) Sub(x, y *Float) *Float
```

Sub sets z to the rounded difference x-y and returns z. Precision, rounding, and accuracy reporting are as for [Float.Add](#Float.Add). Sub panics with [ErrNaN](#ErrNaN) if x and y are infinities with equal signs. The value of z is undefined in that case.

```go
func (x *Float) Text(format byte, prec int) string
```

Text converts the floating-point number x to a string according to the given format and precision prec. The format is one of:

	'e'	-d.dddde±dd, decimal exponent, at least two (possibly 0) exponent digits
	'E'	-d.ddddE±dd, decimal exponent, at least two (possibly 0) exponent digits
	'f'	-ddddd.dddd, no exponent
	'g'	like 'e' for large exponents, like 'f' otherwise
	'G'	like 'E' for large exponents, like 'f' otherwise
	'x'	-0xd.dddddp±dd, hexadecimal mantissa, decimal power of two exponent
	'p'	-0x.dddp±dd, hexadecimal mantissa, decimal power of two exponent (non-standard)
	'b'	-ddddddp±dd, decimal mantissa, decimal power of two exponent (non-standard)

For the power-of-two exponent formats, the mantissa is printed in normalized form:

	'x'	hexadecimal mantissa in [1, 2), or 0
	'p'	hexadecimal mantissa in [½, 1), or 0
	'b'	decimal integer mantissa using x.Prec() bits, or 0

Note that the 'x' form is the one used by most other languages and libraries.

If format is a different character, Text returns a "%" followed by the unrecognized format character.

The precision prec controls the number of digits (excluding the exponent) printed by the 'e', 'E', 'f', 'g', 'G', and 'x' formats. For 'e', 'E', 'f', and 'x', it is the number of digits after the decimal point. For 'g' and 'G' it is the total number of digits. A negative precision selects the smallest number of decimal digits necessary to identify the value x uniquely using x.Prec() mantissa bits. The prec value is ignored for the 'b' and 'p' formats.

Note that Text may return a different result than strconv.FormatFloat for corresponding arguments if the matching float32 or float64 number provided to strconv.FormatFloat is a denormalized number.

```go
func (x *Float) Uint64() (uint64, Accuracy)
```

Uint64 returns the unsigned integer resulting from truncating x towards zero. If 0 \<= x \<= [math.MaxUint64](/math#MaxUint64), the result is [Exact](#Exact) if x is an integer and [Below](#Below) otherwise. The result is (0, [Above](#Above)) for x \< 0, and ([math.MaxUint64](/math#MaxUint64), [Below](#Below)) for x > [math.MaxUint64](/math#MaxUint64).

```go
func (z *Float) UnmarshalText(text []byte) error
```

UnmarshalText implements the [encoding.TextUnmarshaler](/encoding#TextUnmarshaler) interface. The result is rounded per the precision and rounding mode of z. If z's precision is 0, it is changed to 64 before rounding takes effect.

```go
type Int struct {
	// contains filtered or unexported fields
}
```

An Int represents a signed multi-precision integer. The zero value for an Int represents the value 0.

Operations always take pointer arguments (\*Int) rather than Int values, and each unique Int value requires its own unique \*Int pointer. To "copy" an Int value, an existing (or newly allocated) Int must be set to a new value using the [Int.Set](#Int.Set) method; shallow copies of Ints are not supported and may lead to errors.

Note that methods may leak the Int's value through timing side-channels. Because of this and because of the scope and complexity of the implementation, Int is not well-suited to implement cryptographic operations. The standard library avoids exposing non-trivial Int methods to attacker-controlled inputs and the determination of whether a bug in math/big is considered a security vulnerability might depend on the impact on the standard library.

```go
func NewInt(x int64) *Int
```

NewInt allocates and returns a new [Int](#Int) set to x.

```go
func (z *Int) Abs(x *Int) *Int
```

Abs sets z to |x| (the absolute value of x) and returns z.

```go
func (z *Int) Add(x, y *Int) *Int
```

Add sets z to the sum x+y and returns z.

```go
func (z *Int) And(x, y *Int) *Int
```

And sets z = x & y and returns z.

```go
func (z *Int) AndNot(x, y *Int) *Int
```

AndNot sets z = x &^ y and returns z.

```go
func (x *Int) Append(buf []byte, base int) []byte
```

Append appends the string representation of x, as generated by x.Text(base), to buf and returns the extended buffer.

```go
func (x *Int) AppendText(b []byte) (text []byte, err error)
```

AppendText implements the [encoding.TextAppender](/encoding#TextAppender) interface.

```go
func (z *Int) Binomial(n, k int64) *Int
```

Binomial sets z to the binomial coefficient C(n, k) and returns z.

```go
func (x *Int) Bit(i int) uint
```

Bit returns the value of the i'th bit of x. That is, it returns (x>>i)&1. The bit index i must be >= 0.

```go
func (x *Int) BitLen() int
```

BitLen returns the length of the absolute value of x in bits. The bit length of 0 is 0.

```go
func (x *Int) Bits() []Word
```

Bits provides raw (unchecked but fast) access to x by returning its absolute value as a little-endian [Word](#Word) slice. The result and x share the same underlying array. Bits is intended to support implementation of missing low-level [Int](#Int) functionality outside this package; it should be avoided otherwise.

```go
func (x *Int) Bytes() []byte
```

Bytes returns the absolute value of x as a big-endian byte slice.

To use a fixed length slice, or a preallocated one, use [Int.FillBytes](#Int.FillBytes).

```go
func (x *Int) Cmp(y *Int) (r int)
```

Cmp compares x and y and returns:

  - \-1 if x \< y;
  - 0 if x == y;
  - \+1 if x > y.

```go
func (x *Int) CmpAbs(y *Int) int
```

CmpAbs compares the absolute values of x and y and returns:

  - \-1 if |x| \< |y|;
  - 0 if |x| == |y|;
  - \+1 if |x| > |y|.

```go
func (z *Int) Div(x, y *Int) *Int
```

Div sets z to the quotient x/y for y != 0 and returns z. If y == 0, a division-by-zero run-time panic occurs. Div implements Euclidean division (unlike Go); see [Int.DivMod](#Int.DivMod) for more details.

```go
func (z *Int) DivMod(x, y, m *Int) (*Int, *Int)
```

DivMod sets z to the quotient x div y and m to the modulus x mod y and returns the pair (z, m) for y != 0. If y == 0, a division-by-zero run-time panic occurs.

DivMod implements Euclidean division and modulus (unlike Go):

	q = x div y  such that
	m = x - y*q  with 0 <= m < |y|

(See Raymond T. Boute, “The Euclidean definition of the functions div and mod”. ACM Transactions on Programming Languages and Systems (TOPLAS), 14(2):127-144, New York, NY, USA, 4/1992. ACM press.) See [Int.QuoRem](#Int.QuoRem) for T-division and modulus (like Go).

```go
func (z *Int) Divide(x, y, r *Int, mode RoundingMode) (*Int, *Int)
```

Divide computes the integer quotient q and remainder r such that

	q = f(x/y)
	r = x - y*q

where f is described by the rounding mode, which must be one of [Trunc](#Trunc), [Floor](#Floor), [Round](#Round) or [Ceil](#Ceil). Divide sets z to q if z != nil, updates r if r != nil, and returns the pair (z, r) if y != 0. If y == 0, a division-by-zero run-time panic occurs.

```go
func (z *Int) Exp(x, y, m *Int) *Int
```

Exp sets z = x\*\*y mod |m| (i.e. the sign of m is ignored), and returns z. If m == nil or m == 0, z = x\*\*y unless y \<= 0 then z = 1. If m != 0, y \< 0, and x and m are not relatively prime, z is unchanged and nil is returned.

Modular exponentiation of inputs of a particular size is not a cryptographically constant-time operation.

```go
func (x *Int) FillBytes(buf []byte) []byte
```

FillBytes sets buf to the absolute value of x, storing it as a zero-extended big-endian byte slice, and returns buf.

If the absolute value of x doesn't fit in buf, FillBytes will panic.

```go
func (x *Int) Float64() (float64, Accuracy)
```

Float64 returns the float64 value nearest x, and an indication of any rounding that occurred.

```go
func (x *Int) Format(s fmt.State, ch rune)
```

Format implements [fmt.Formatter](/fmt#Formatter). It accepts the formats 'b' (binary), 'o' (octal with 0 prefix), 'O' (octal with 0o prefix), 'd' (decimal), 'x' (lowercase hexadecimal), and 'X' (uppercase hexadecimal). Also supported are the full suite of package fmt's format flags for integral types, including '+' and ' ' for sign control, '#' for leading zero in octal and for hexadecimal, a leading "0x" or "0X" for "%#x" and "%#X" respectively, specification of minimum digits precision, output field width, space or zero padding, and '-' for left or right justification.

```go
func (z *Int) GCD(x, y, a, b *Int) *Int
```

GCD sets z to the greatest common divisor of a and b and returns z. If x or y are not nil, GCD sets their value such that z = a\*x + b\*y.

a and b may be positive, zero or negative. (Before Go 1.14 both had to be > 0.) Regardless of the signs of a and b, z is always >= 0.

If a == b == 0, GCD sets z = x = y = 0.

If a == 0 and b != 0, GCD sets z = |b|, x = 0, y = sign(b) \* 1.

If a != 0 and b == 0, GCD sets z = |a|, x = sign(a) \* 1, y = 0.

```go
func (z *Int) GobDecode(buf []byte) error
```

GobDecode implements the [encoding/gob.GobDecoder](/encoding/gob#GobDecoder) interface.

```go
func (x *Int) GobEncode() ([]byte, error)
```

GobEncode implements the [encoding/gob.GobEncoder](/encoding/gob#GobEncoder) interface.

```go
func (x *Int) Int64() int64
```

Int64 returns the int64 representation of x. If x cannot be represented in an int64, the result is undefined.

```go
func (x *Int) IsInt64() bool
```

IsInt64 reports whether x can be represented as an int64.

```go
func (x *Int) IsUint64() bool
```

IsUint64 reports whether x can be represented as a uint64.

```go
func (z *Int) Lsh(x *Int, n uint) *Int
```

Lsh sets z = x \<\< n and returns z.

```go
func (x *Int) MarshalJSON() ([]byte, error)
```

MarshalJSON implements the [encoding/json.Marshaler](/encoding/json#Marshaler) interface.

```go
func (x *Int) MarshalText() (text []byte, err error)
```

MarshalText implements the [encoding.TextMarshaler](/encoding#TextMarshaler) interface.

```go
func (z *Int) Mod(x, y *Int) *Int
```

Mod sets z to the modulus x%y for y != 0 and returns z. If y == 0, a division-by-zero run-time panic occurs. Mod implements Euclidean modulus (unlike Go); see [Int.DivMod](#Int.DivMod) for more details.

```go
func (z *Int) ModInverse(g, n *Int) *Int
```

ModInverse sets z to the multiplicative inverse of g in the ring ℤ/nℤ and returns z. If g and n are not relatively prime, g has no multiplicative inverse in the ring ℤ/nℤ.  In this case, z is unchanged and the return value is nil. If n == 0, a division-by-zero run-time panic occurs.

```go
func (z *Int) ModSqrt(x, p *Int) *Int
```

ModSqrt sets z to a square root of x mod p if such a square root exists, and returns z. The modulus p must be an odd prime. If x is not a square mod p, ModSqrt leaves z unchanged and returns nil. This function panics if p is not an odd integer, its behavior is undefined if p is odd but not prime.

```go
func (z *Int) Mul(x, y *Int) *Int
```

Mul sets z to the product x\*y and returns z.

```go
func (z *Int) MulRange(a, b int64) *Int
```

MulRange sets z to the product of all integers in the range \[a, b] inclusively and returns z. If a > b (empty range), the result is 1.

```go
func (z *Int) Neg(x *Int) *Int
```

Neg sets z to -x and returns z.

```go
func (z *Int) Not(x *Int) *Int
```

Not sets z = ^x and returns z.

```go
func (z *Int) Or(x, y *Int) *Int
```

Or sets z = x | y and returns z.

```go
func (x *Int) ProbablyPrime(n int) bool
```

ProbablyPrime reports whether x is probably prime, applying the Miller-Rabin test with n pseudorandomly chosen bases as well as a Baillie-PSW test.

If x is prime, ProbablyPrime returns true. If x is chosen randomly and not prime, ProbablyPrime probably returns false. The probability of returning true for a randomly chosen non-prime is at most ¼ⁿ.

ProbablyPrime is 100% accurate for inputs less than 2⁶⁴. See Menezes et al., Handbook of Applied Cryptography, 1997, pp. 145-149, and FIPS 186-4 Appendix F for further discussion of the error probabilities.

ProbablyPrime is not suitable for judging primes that an adversary may have crafted to fool the test.

As of Go 1.8, ProbablyPrime(0) is allowed and applies only a Baillie-PSW test. Before Go 1.8, ProbablyPrime applied only the Miller-Rabin tests, and ProbablyPrime(0) panicked.

```go
func (z *Int) Quo(x, y *Int) *Int
```

Quo sets z to the quotient x/y for y != 0 and returns z. If y == 0, a division-by-zero run-time panic occurs. Quo implements truncated division (like Go); see [Int.QuoRem](#Int.QuoRem) for more details.

```go
func (z *Int) QuoRem(x, y, r *Int) (*Int, *Int)
```

QuoRem sets z to the quotient x/y and r to the remainder x%y and returns the pair (z, r) for y != 0. If y == 0, a division-by-zero run-time panic occurs.

QuoRem implements T-division and modulus (like Go):

	q = x/y      with the result truncated to zero
	r = x - y*q

(See Daan Leijen, “Division and Modulus for Computer Scientists”.) See [Int.DivMod](#Int.DivMod) for Euclidean division and modulus (unlike Go).

```go
func (z *Int) Rand(rnd *rand.Rand, n *Int) *Int
```

Rand sets z to a pseudo-random number in \[0, n) and returns z.

As this uses the [math/rand](/math/rand) package, it must not be used for security-sensitive work. Use [crypto/rand.Int](/crypto/rand#Int) instead.

```go
func (z *Int) Rem(x, y *Int) *Int
```

Rem sets z to the remainder x%y for y != 0 and returns z. If y == 0, a division-by-zero run-time panic occurs. Rem implements truncated modulus (like Go); see [Int.QuoRem](#Int.QuoRem) for more details.

```go
func (z *Int) Rsh(x *Int, n uint) *Int
```

Rsh sets z = x >> n and returns z.

```go
func (z *Int) Scan(s fmt.ScanState, ch rune) error
```

Scan is a support routine for [fmt.Scanner](/fmt#Scanner); it sets z to the value of the scanned number. It accepts the formats 'b' (binary), 'o' (octal), 'd' (decimal), 'x' (lowercase hexadecimal), and 'X' (uppercase hexadecimal).

#### Example

```go
{

	i := new(big.Int)
	_, err := fmt.Sscan("18446744073709551617", i)
	if err != nil {
		log.Println("error scanning value:", err)
	} else {
		fmt.Println(i)
	}

}
```

Output:

```
18446744073709551617

```

```go
func (z *Int) Set(x *Int) *Int
```

Set sets z to x and returns z.

```go
func (z *Int) SetBit(x *Int, i int, b uint) *Int
```

SetBit sets z to x, with x's i'th bit set to b (0 or 1). That is,

  - if b is 1, SetBit sets z = x | (1 \<\< i);
  - if b is 0, SetBit sets z = x &^ (1 \<\< i);
  - if b is not 0 or 1, SetBit will panic.

```go
func (z *Int) SetBits(abs []Word) *Int
```

SetBits provides raw (unchecked but fast) access to z by setting its value to abs, interpreted as a little-endian [Word](#Word) slice, and returning z. The result and abs share the same underlying array. SetBits is intended to support implementation of missing low-level [Int](#Int) functionality outside this package; it should be avoided otherwise.

```go
func (z *Int) SetBytes(buf []byte) *Int
```

SetBytes interprets buf as the bytes of a big-endian unsigned integer, sets z to that value, and returns z.

```go
func (z *Int) SetInt64(x int64) *Int
```

SetInt64 sets z to x and returns z.

```go
func (z *Int) SetString(s string, base int) (*Int, bool)
```

SetString sets z to the value of s, interpreted in the given base, and returns z and a boolean indicating success. The entire string (not just a prefix) must be valid for success. If SetString fails, the value of z is undefined but the returned value is nil.

The base argument must be 0 or a value between 2 and [MaxBase](#MaxBase). For base 0, the number prefix determines the actual base: A prefix of “0b” or “0B” selects base 2, “0”, “0o” or “0O” selects base 8, and “0x” or “0X” selects base 16. Otherwise, the selected base is 10 and no prefix is accepted.

For bases \<= 36, lower and upper case letters are considered the same: The letters 'a' to 'z' and 'A' to 'Z' represent digit values 10 to 35. For bases > 36, the upper case letters 'A' to 'Z' represent the digit values 36 to 61.

For base 0, an underscore character “\_” may appear between a base prefix and an adjacent digit, and between successive digits; such underscores do not change the value of the number. Incorrect placement of underscores is reported as an error if there are no other errors. If base != 0, underscores are not recognized and act like any other character that is not a valid digit.

#### Example

```go
{
	i := new(big.Int)
	i.SetString("644", 8)
	fmt.Println(i)

}
```

Output:

```
420

```

```go
func (z *Int) SetUint64(x uint64) *Int
```

SetUint64 sets z to x and returns z.

```go
func (x *Int) Sign() int
```

Sign returns:

  - \-1 if x \< 0;
  - 0 if x == 0;
  - \+1 if x > 0.

```go
func (z *Int) Sqrt(x *Int) *Int
```

Sqrt sets z to ⌊√x⌋, the largest integer such that z² ≤ x, and returns z. It panics if x is negative.

```go
func (x *Int) String() string
```

String returns the decimal representation of x as generated by x.Text(10).

```go
func (z *Int) Sub(x, y *Int) *Int
```

Sub sets z to the difference x-y and returns z.

```go
func (x *Int) Text(base int) string
```

Text returns the string representation of x in the given base. Base must be between 2 and 62, inclusive. The result uses the lower-case letters 'a' to 'z' for digit values 10 to 35, and the upper-case letters 'A' to 'Z' for digit values 36 to 61. No prefix (such as "0x") is added to the string. If x is a nil pointer it returns "\<nil>".

```go
func (x *Int) TrailingZeroBits() uint
```

TrailingZeroBits returns the number of consecutive least significant zero bits of |x|.

```go
func (x *Int) Uint64() uint64
```

Uint64 returns the uint64 representation of x. If x cannot be represented in a uint64, the result is undefined.

```go
func (z *Int) UnmarshalJSON(text []byte) error
```

UnmarshalJSON implements the [encoding/json.Unmarshaler](/encoding/json#Unmarshaler) interface.

```go
func (z *Int) UnmarshalText(text []byte) error
```

UnmarshalText implements the [encoding.TextUnmarshaler](/encoding#TextUnmarshaler) interface.

```go
func (z *Int) Xor(x, y *Int) *Int
```

Xor sets z = x ^ y and returns z.

```go
type Rat struct {
	// contains filtered or unexported fields
}
```

A Rat represents a quotient a/b of arbitrary precision. The zero value for a Rat represents the value 0.

Operations always take pointer arguments (\*Rat) rather than Rat values, and each unique Rat value requires its own unique \*Rat pointer. To "copy" a Rat value, an existing (or newly allocated) Rat must be set to a new value using the [Rat.Set](#Rat.Set) method; shallow copies of Rats are not supported and may lead to errors.

```go
func NewRat(a, b int64) *Rat
```

NewRat creates a new [Rat](#Rat) with numerator a and denominator b.

```go
func (z *Rat) Abs(x *Rat) *Rat
```

Abs sets z to |x| (the absolute value of x) and returns z.

```go
func (z *Rat) Add(x, y *Rat) *Rat
```

Add sets z to the sum x+y and returns z.

```go
func (x *Rat) AppendText(b []byte) ([]byte, error)
```

AppendText implements the [encoding.TextAppender](/encoding#TextAppender) interface.

```go
func (x *Rat) Cmp(y *Rat) int
```

Cmp compares x and y and returns:

  - \-1 if x \< y;
  - 0 if x == y;
  - \+1 if x > y.

```go
func (x *Rat) Denom() *Int
```

Denom returns the denominator of x; it is always > 0. The result is a reference to x's denominator, unless x is an uninitialized (zero value) [Rat](#Rat), in which case the result is a new [Int](#Int) of value 1. (To initialize x, any operation that sets x will do, including x.Set(x).) If the result is a reference to x's denominator it may change if a new value is assigned to x, and vice versa.

```go
func (x *Rat) Float32() (f float32, exact bool)
```

Float32 returns the nearest float32 value for x and a bool indicating whether f represents x exactly. If the magnitude of x is too large to be represented by a float32, f is an infinity and exact is false. The sign of f always matches the sign of x, even if f == 0.

```go
func (x *Rat) Float64() (f float64, exact bool)
```

Float64 returns the nearest float64 value for x and a bool indicating whether f represents x exactly. If the magnitude of x is too large to be represented by a float64, f is an infinity and exact is false. The sign of f always matches the sign of x, even if f == 0.

```go
func (x *Rat) FloatPrec() (n int, exact bool)
```

FloatPrec returns the number n of non-repeating digits immediately following the decimal point of the decimal representation of x. The boolean result indicates whether a decimal representation of x with that many fractional digits is exact or rounded.

Examples:

	x      n    exact    decimal representation n fractional digits
	0      0    true     0
	1      0    true     1
	1/2    1    true     0.5
	1/3    0    false    0       (0.333... rounded)
	1/4    2    true     0.25
	1/6    1    false    0.2     (0.166... rounded)

```go
func (x *Rat) FloatString(prec int) string
```

FloatString returns a string representation of x in decimal form with prec digits of precision after the radix point. The last digit is rounded to nearest, with halves rounded away from zero.

```go
func (z *Rat) GobDecode(buf []byte) error
```

GobDecode implements the [encoding/gob.GobDecoder](/encoding/gob#GobDecoder) interface.

```go
func (x *Rat) GobEncode() ([]byte, error)
```

GobEncode implements the [encoding/gob.GobEncoder](/encoding/gob#GobEncoder) interface.

```go
func (z *Rat) Inv(x *Rat) *Rat
```

Inv sets z to 1/x and returns z. If x == 0, Inv panics.

```go
func (x *Rat) IsInt() bool
```

IsInt reports whether the denominator of x is 1.

```go
func (x *Rat) MarshalText() (text []byte, err error)
```

MarshalText implements the [encoding.TextMarshaler](/encoding#TextMarshaler) interface.

```go
func (z *Rat) Mul(x, y *Rat) *Rat
```

Mul sets z to the product x\*y and returns z.

```go
func (z *Rat) Neg(x *Rat) *Rat
```

Neg sets z to -x and returns z.

```go
func (x *Rat) Num() *Int
```

Num returns the numerator of x; it may be \<= 0. The result is a reference to x's numerator; it may change if a new value is assigned to x, and vice versa. The sign of the numerator corresponds to the sign of x.

```go
func (z *Rat) Quo(x, y *Rat) *Rat
```

Quo sets z to the quotient x/y and returns z. If y == 0, Quo panics.

```go
func (x *Rat) RatString() string
```

RatString returns a string representation of x in the form "a/b" if b != 1, and in the form "a" if b == 1.

```go
func (z *Rat) Scan(s fmt.ScanState, ch rune) error
```

Scan is a support routine for fmt.Scanner. It accepts the formats 'e', 'E', 'f', 'F', 'g', 'G', and 'v'. All formats are equivalent.

#### Example

```go
{

	r := new(big.Rat)
	_, err := fmt.Sscan("1.5000", r)
	if err != nil {
		log.Println("error scanning value:", err)
	} else {
		fmt.Println(r)
	}

}
```

Output:

```
3/2

```

```go
func (z *Rat) Set(x *Rat) *Rat
```

Set sets z to x (by making a copy of x) and returns z.

```go
func (z *Rat) SetFloat64(f float64) *Rat
```

SetFloat64 sets z to exactly f and returns z. If f is not finite, SetFloat returns nil.

```go
func (z *Rat) SetFrac(a, b *Int) *Rat
```

SetFrac sets z to a/b and returns z. If b == 0, SetFrac panics.

```go
func (z *Rat) SetFrac64(a, b int64) *Rat
```

SetFrac64 sets z to a/b and returns z. If b == 0, SetFrac64 panics.

```go
func (z *Rat) SetInt(x *Int) *Rat
```

SetInt sets z to x (by making a copy of x) and returns z.

```go
func (z *Rat) SetInt64(x int64) *Rat
```

SetInt64 sets z to x and returns z.

```go
func (z *Rat) SetString(s string) (*Rat, bool)
```

SetString sets z to the value of s and returns z and a boolean indicating success. s can be given as a (possibly signed) fraction "a/b", or as a floating-point number optionally followed by an exponent. If a fraction is provided, both the dividend and the divisor may be a decimal integer or independently use a prefix of “0b”, “0” or “0o”, or “0x” (or their upper-case variants) to denote a binary, octal, or hexadecimal integer, respectively. The divisor may not be signed. If a floating-point number is provided, it may be in decimal form or use any of the same prefixes as above but for “0” to denote a non-decimal mantissa. A leading “0” is considered a decimal leading 0; it does not indicate octal representation in this case. An optional base-10 “e” or base-2 “p” (or their upper-case variants) exponent may be provided as well, except for hexadecimal floats which only accept an (optional) “p” exponent (because an “e” or “E” cannot be distinguished from a mantissa digit). If the exponent's absolute value is too large, the operation may fail. The entire string, not just a prefix, must be valid for success. If the operation failed, the value of z is undefined but the returned value is nil.

#### Example

```go
{
	r := new(big.Rat)
	r.SetString("355/113")
	fmt.Println(r.FloatString(3))

}
```

Output:

```
3.142

```

```go
func (z *Rat) SetUint64(x uint64) *Rat
```

SetUint64 sets z to x and returns z.

```go
func (x *Rat) Sign() int
```

Sign returns:

  - \-1 if x \< 0;
  - 0 if x == 0;
  - \+1 if x > 0.

```go
func (x *Rat) String() string
```

String returns a string representation of x in the form "a/b" (even if b == 1).

```go
func (z *Rat) Sub(x, y *Rat) *Rat
```

Sub sets z to the difference x-y and returns z.

```go
func (z *Rat) UnmarshalText(text []byte) error
```

UnmarshalText implements the [encoding.TextUnmarshaler](/encoding#TextUnmarshaler) interface.

```go
type RoundingMode byte
```

RoundingMode determines how a [Float](#Float) value is rounded to the desired precision. Rounding may change the [Float](#Float) value; the rounding error is described by the [Float](#Float)'s [Accuracy](#Accuracy).

#### Example

```go
{
	operands := []float64{2.6, 2.5, 2.1, -2.1, -2.5, -2.6}

	fmt.Print("   x")
	for mode := big.ToNearestEven; mode <= big.ToPositiveInf; mode++ {
		fmt.Printf("  %s", mode)
	}
	fmt.Println()

	for _, f64 := range operands {
		fmt.Printf("%4g", f64)
		for mode := big.ToNearestEven; mode <= big.ToPositiveInf; mode++ {

			f := new(big.Float).SetPrec(2).SetMode(mode).SetFloat64(f64)
			fmt.Printf("  %*g", len(mode.String()), f)
		}
		fmt.Println()
	}

}
```

Output:

```
   x  ToNearestEven  ToNearestAway  ToZero  AwayFromZero  ToNegativeInf  ToPositiveInf
 2.6              3              3       2             3              2              3
 2.5              2              3       2             3              2              3
 2.1              2              2       2             3              2              3
-2.1             -2             -2      -2            -3             -3             -2
-2.5             -2             -3      -2            -3             -3             -2
-2.6             -3             -3      -2            -3             -3             -2

```

```go
const (
	ToNearestEven RoundingMode = iota // == IEEE 754-2008 roundTiesToEven
	ToNearestAway                     // == IEEE 754-2008 roundTiesToAway
	ToZero                            // == IEEE 754-2008 roundTowardZero
	AwayFromZero                      // no IEEE 754-2008 equivalent
	ToNegativeInf                     // == IEEE 754-2008 roundTowardNegative
	ToPositiveInf                     // == IEEE 754-2008 roundTowardPositive
)
```

These constants define supported rounding modes.

```go
func (i RoundingMode) String() string
```

```go
type Word uint
```

A Word represents a single digit of a multi-precision unsigned integer.

------

## Analysis of ***script*** Output

- The title doesn't match the web site, but that is easily fixed.
- The ***script*** output eliminates headers and, in that respect, the extracted document doesn't match the documentation on the web page: [big package - math/big - Go Packages](https://pkg.go.dev/math/big)
- A great many of the internal links are broken due to missing headers. 

## Question

Is there any way to address these issues, or should I return to downloading the ***html*** and running a conversion?



# Gemini 4 Hydrogen Response No 5 - 2026-11-21 20:26-Hours



Your diagnosis is spot-on. The `pkg.go.dev` API's `doc=md` renderer has two quirks:

1. **It strips symbol headings:** It turns `<h3>type Float</h3>` and `<h4>func (*Float) Add</h4>` into plain ````go```` fenced blocks instead of Markdown headings (`###` / `####`), while still keeping the `[Float](#Float)` and `[Float.Add](#Float.Add)` links inside the prose.
2. **It uses relative cross-package links:** Links like `[fmt.Scanner](/fmt#Scanner)` lack the `https://pkg.go.dev` domain.

### Should You Go Back to HTML + Pandoc?

You **can** fetch clean HTML directly from the same API without scraping the full webpage—just change `doc=md` to **`doc=html`**:
```powershell
(Invoke-RestMethod "https://pkg.go.dev/v1/package/math/big?version=v1.27.4&doc=html&examples=true").docs |
    pandoc -f html -t gfm --wrap=none -o math_big_go1.27.4.md
```
**However, raw `doc=html` + Pandoc has two drawbacks for RAG:**
1. It pulls `pkg.go.dev` UI clutter into your headings (pilcrow `[¶](#Float)` links and `cs.opensource.google` source-code URLs on every function/type name) plus raw `<details>` tags around Examples.
2. Even with `### type Float` restored, GitHub-Flavored Markdown (`gfm`) auto-generates lowercase slug IDs like `#type-float` rather than `#Float`, so **every `[Float](#Float)` internal link still breaks** unless you inject explicit `<a id="Float"></a>` anchors.

---

### Recommended Fix: Restore Headings, Anchors, Title & Links Directly in `Get-GoPackageDoc.ps1`

Because the `doc=md` output is already clean (no `¶` clutter, clean `go` code fences, clean `Output:` blocks), the cleanest solution is to post-process it right inside `Get-GoPackageDoc.ps1`.

The updated script below fixes **all three issues** in one pass:
* **Title:** Changes `# package big` to `# big package - math/big` to match the website.
* **Headings:** Restores `### type ...`, `### func ...`, and `#### func (...) ...` headers above every declaration block (and nests `##### Example` under symbols so your Table of Contents mirrors the website).
* **Working Internal Anchors:** Inserts `<a id="Symbol"></a>` and `<a id="Type.Method"></a>` (including constants/vars like `<a id="ToNearestEven"></a>` and `<a id="Below"></a>`) so internal links resolve properly.
* **External Stdlib Links:** Expands `/fmt#Scanner` into `https://pkg.go.dev/fmt#Scanner`.

```powershell
[CmdletBinding()]
param(
    [string]$Package = "math/big",
    [string]$Version = "v1.27.4",
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
```

### What Your Output & TOC Will Look Like Now

Running `pwsh -File .\Get-GoPackageDoc.ps1` produces proper nested headings and working anchors like:
```markdown
## Functions

<a id="Jacobi"></a>
### func Jacobi

...

## Types

<a id="Float"></a>
### type Float

...

<a id="NewFloat"></a>
#### func NewFloat

...

<a id="Float.Add"></a>
#### func (*Float) Add
```
* Your TOC generator will now index every type, function, and method cleanly underneath `## Functions` and `## Types`.
* Internal links like `[Float](#Float)`, `[NewInt](#NewInt)`, `[Int.Sign](#Int.Sign)`, and `[ToNearestEven](#ToNearestEven)` will jump directly to the corresponding `<a id="..."></a>` anchor.
* Your RAG pipeline gets clean Markdown chunks split cleanly along `###` and `####` symbol boundaries without Pandoc HTML noise.



# Gemini 4 Hydrogen Summary  2026-11-21 20:48

```
Ok! I think this will work! THANKS!
```



# Gemini 4 Hydrogen Question No 5 - 2026-11-21 21:02

## Background

Previously, you mentioned that the correct URL for pulling down the ***Go*** Language Reference was:

```bash
https://raw.githubusercontent.com/golang/go/go1.27.4/doc/go_spec.html
```



The current Powershell script does not work with this type of URL.

## Request

Could you provide a different PowerShell script for PowerShell 7.7.0 which will:

Pull down the language specification as markdown.

Parse the mark down in a similar manner to that provided by the earlier script which processed the ***`math/big`*** package.



# Gemini 4 Hydrogen Question No 5 - 2026-11-21 21:10

The earlier script (`Get-GoPackageDoc.ps1`) calls the **`pkg.go.dev` REST API**, which only serves Go *packages* (like `math/big`). The **Go Language Specification** is not served through that API—it lives as an HTML source document in the `golang/go` repository (`doc/go_spec.html`).

Because `go_spec.html` is HTML, converting it straight through Pandoc causes the **exact same three issues** you spotted in `math/big`:
1. **Missing Title:** The title and subtitle are stored inside a leading `<!--{ ... }-->` JSON comment rather than an `<h1>` tag, so Pandoc drops them.
2. **Broken Internal Links:** `go_spec.html` uses `<h2 id="Variable_declarations">`, `<h3 id="Floating-point_literals">`, and `<a id="SourceFile">` inside `<pre class="ebnf">` blocks. Pandoc's `gfm` writer strips those `id` attributes and generates lowercase hyphenated slugs (`#variable-declarations`), breaking links like `[variable declarations](#Variable_declarations)` and `[SourceFile](#SourceFile)`.
3. **Messy EBNF & Relative Links:** `<pre class="ebnf">` blocks contain nested `<a>` tags, forcing Pandoc to emit raw HTML `<pre>` tags instead of clean fenced ```` ```ebnf ```` blocks, and cross-document links like `/ref/mem` lack `https://go.dev`.

---

### PowerShell 7.7.0 Script (`Get-GoSpecDoc.ps1`)

Save the following as **`Get-GoSpecDoc.ps1`**. It downloads `go_spec.html` for your target Go version, extracts the JSON title/subtitle, preserves every heading and EBNF anchor (`<a id="..."></a>`) across Pandoc, converts cleanly via Pandoc (automatically using Windows `pandoc` if installed, or falling back to `wsl pandoc` in your WSL2 environment), and fixes relative `https://go.dev/...` links.

```powershell
[CmdletBinding()]
param(
    [string]$Version = "go1.27.4",
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
```

---

### How to Run It

From PowerShell 7.7.0:
```powershell
# Default: downloads go1.27.4 -> go_spec_go1.27.4.md
.\Get-GoSpecDoc.ps1

# Or target another Go tag / branch:
.\Get-GoSpecDoc.ps1 -Version "go1.27.0"
```

### What You Get in `go_spec_go1.27.4.md`
* **Matching Title & Subtitle:** Starts cleanly with `# The Go Programming Language Specification` and its exact version/date.
* **Clean Hierarchy & TOC:** `## Notation`, `## Source code representation`, `### Letters and digits`, etc., all with `<a id="..."></a>` directly above each heading so links like `[Variable declarations](#Variable_declarations)` and `[Floating-point literals](#Floating-point_literals)` work.
* **Clean Fenced EBNF Blocks:** All grammar rules become clean ```` ```ebnf ```` blocks with their production anchors (e.g., `<a id="SourceFile"></a>`) preserved right above them.
* **Full External Links:** Relative links like `/ref/mem` or `/pkg/unsafe` resolve to `https://go.dev/...`.





```
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.23.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.24.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.25.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.26.md",
    "https://raw.githubusercontent.com/golang/website/master/_content/doc/go1.27.md"
```

