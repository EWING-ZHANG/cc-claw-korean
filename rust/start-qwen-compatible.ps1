param(
    [string]$Model = "qwen3-coder-next",
    [string]$BaseUrl = "https://dashscope.aliyuncs.com/compatible-mode/v1",
    [switch]$Release,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CliArgs
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$apiKey = $env:OPENAI_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKey = $env:DASHSCOPE_API_KEY
}
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKey = $env:BAILIAN_API_KEY
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw "Set OPENAI_API_KEY, DASHSCOPE_API_KEY, or BAILIAN_API_KEY before running start-qwen-compatible.ps1."
}

$env:OPENAI_API_KEY = $apiKey
$env:OPENAI_BASE_URL = $BaseUrl
$env:OPENAI_MODEL = $Model

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
