param(
    [string]$GodotPath = 'godot'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$testOutput = @(& $GodotPath --headless --path $projectRoot --fixed-fps 60 --script res://tests/gameplay_test.gd 2>&1)
$testExitCode = $LASTEXITCODE
$testText = ($testOutput | ForEach-Object { $_.ToString() }) -join "`n"
Write-Output $testText

# Godot can return zero after a runtime script error, so inspect diagnostics too.
if ($testExitCode -ne 0 -or $testText -match '(?m)^(SCRIPT ERROR:|ERROR:|FAIL )') {
    throw 'Godot gameplay validation failed. See the diagnostics above.'
}
if ($testText -notmatch 'RESULT (\d+)/(\d+) passed' -or $Matches[1] -ne $Matches[2]) {
    throw 'Godot did not report a complete passing test run.'
}
