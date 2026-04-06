param(
    [string]$Model = "qianfan-code-latest",
    [string]$BaseUrl = "https://qianfan.baidubce.com/anthropic/coding",
    [string]$AuthToken,
    [switch]$Release,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CliArgs
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

function Normalize-QianfanToken {
    param(
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $normalized = $Value.Trim()
    if ($normalized.Length -ge 2) {
        $first = $normalized.Substring(0, 1)
        $last = $normalized.Substring($normalized.Length - 1, 1)
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            $normalized = $normalized.Substring(1, $normalized.Length - 2).Trim()
        }
    }

    return $normalized
}

if ([string]::IsNullOrWhiteSpace($env:HOME)) {
    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $env:HOME = $env:USERPROFILE
    }
    elseif (-not [string]::IsNullOrWhiteSpace($env:HOMEDRIVE) -and -not [string]::IsNullOrWhiteSpace($env:HOMEPATH)) {
        $env:HOME = "$($env:HOMEDRIVE)$($env:HOMEPATH)"
    }
}

$resolvedAuthToken = $AuthToken
if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    $resolvedAuthToken = $env:ANTHROPIC_AUTH_TOKEN
}
if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    $resolvedAuthToken = $env:QIANFAN_API_KEY
}
if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    $resolvedAuthToken = $env:QIANFAN_CODING_API_KEY
}
if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    $resolvedAuthToken = $env:BAIDU_QIANFAN_API_KEY
}
if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    $resolvedAuthToken = $env:BCE_QIANFAN_API_KEY
}

$resolvedAuthToken = Normalize-QianfanToken $resolvedAuthToken

if ([string]::IsNullOrWhiteSpace($resolvedAuthToken)) {
    throw "Set ANTHROPIC_AUTH_TOKEN, QIANFAN_API_KEY, QIANFAN_CODING_API_KEY, BAIDU_QIANFAN_API_KEY, or BCE_QIANFAN_API_KEY before running start-qianfan-coding.ps1."
}

if (-not $resolvedAuthToken.StartsWith("bce-v3/")) {
    Write-Warning "The provided Qianfan Coding Plan key does not start with 'bce-v3/'. If requests fail with invalid_iam_token, re-copy the dedicated Coding Plan API key from the Baidu console."
}

Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
Remove-Item Env:OPENAI_API_KEY -ErrorAction SilentlyContinue
Remove-Item Env:OPENAI_BASE_URL -ErrorAction SilentlyContinue
Remove-Item Env:OPENAI_MODEL -ErrorAction SilentlyContinue

$env:ANTHROPIC_AUTH_TOKEN = $resolvedAuthToken
$env:ANTHROPIC_BASE_URL = $BaseUrl
$env:ANTHROPIC_MODEL = $Model
$env:ANTHROPIC_SMALL_FAST_MODEL = $Model
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $Model
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $Model
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $Model
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
$env:API_TIMEOUT_MS = "600000"

$cargo = Join-Path $env:USERPROFILE ".cargo\bin\cargo.exe"
if (-not (Test-Path $cargo)) {
    throw "cargo.exe was not found at $cargo"
}

$vsDevCmd = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"
if (-not (Test-Path $vsDevCmd)) {
    throw "VsDevCmd.bat was not found at $vsDevCmd"
}

$escapedArgs = @("--model", $Model) + $CliArgs
$argString = ($escapedArgs | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        } else {
            $_
        }
    }) -join " "

$cargoSubcommand = if ($Release) { "run --release -p rusty-claude-cli --" } else { "run -p rusty-claude-cli --" }
$command = "`"$vsDevCmd`" -arch=x64 -host_arch=x64 >nul && `"$cargo`" $cargoSubcommand $argString"

cmd.exe /c $command
exit $LASTEXITCODE
