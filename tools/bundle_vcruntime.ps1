<#
bundle_vcruntime.ps1
Simple helper to copy the MSVC runtime DLLs next to your Windows EXE (app-local deployment).
Usage examples:
  PowerShell -ExecutionPolicy Bypass -File .\tools\bundle_vcruntime.ps1 -TargetFolder "build\windows\runner\Release\" -Arch x64
  PowerShell -ExecutionPolicy Bypass -File .\tools\bundle_vcruntime.ps1 -TargetFolder "C:\path\to\MyApp\" -Arch x86

Notes:
- This just copies VCRUNTIME140.dll, VCRUNTIME140_1.dll and MSVCP140.dll from the OS folder.
- Ensure you use the correct architecture (x64 vs x86) to avoid mismatches.
- Prefer bundling via the official redistributable installer for production; this is a simple workaround.
#>
param(
    [string]$TargetFolder = (Join-Path (Get-Location) 'build\windows\runner\Release\'),
    [ValidateSet('x64','x86')][string]$Arch = 'x64'
)

if (-not (Test-Path $TargetFolder)) {
    Write-Host "Target folder '$TargetFolder' does not exist. Attempting to auto-detect the build output..." -ForegroundColor Yellow

    # Try common Flutter windows build path relative to repo root
    $possible = @(
        Join-Path (Get-Location) 'build\windows\runner\Release\',
        Join-Path (Get-Location) 'build\windows\runner\Debug\',
        Join-Path (Get-Location) 'build\windows\x64\runner\Release\',
        Join-Path (Get-Location) 'build\windows\x64\runner\Debug\',
        Join-Path (Get-Location) 'build\windows\x86\runner\Release\',
        Join-Path (Get-Location) 'build\windows\x86\runner\Debug\'
    )

    $found = $null
    foreach ($p in $possible) {
        if (Test-Path $p) { $found = $p; break }
    }

    # If not found, search for an exe under build\windows recursively
    if (-not $found) {
        $exe = Get-ChildItem -Path (Get-Location) -Recurse -Filter '*.exe' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match '\\build\\windows\\runner\\' } | Select-Object -First 1
        if ($exe) { $found = $exe.DirectoryName }
    }

    if ($found) {
        Write-Host "Auto-detected target folder: $found" -ForegroundColor Green
        $TargetFolder = $found
    } else {
        Write-Host "Could not auto-detect build folder." -ForegroundColor Red
        Write-Host "Run this to locate built EXE(s):" -ForegroundColor Cyan
        Write-Host "  Get-ChildItem -Path . -Filter '*.exe' -Recurse | Select-Object FullName" -ForegroundColor White
        Write-Host "Then re-run this script with -TargetFolder pointing to the EXE folder." -ForegroundColor White
        exit 1
    }
}

$sourceDir = if ($Arch -eq 'x64') { Join-Path $env:windir 'System32' } else { Join-Path $env:windir 'SysWOW64' }
$files = @('VCRUNTIME140.dll','VCRUNTIME140_1.dll','MSVCP140.dll')

Write-Host "Using source directory: $sourceDir"
Write-Host "Copying runtime DLLs to: $TargetFolder`n"

foreach ($f in $files) {
    $src = Join-Path $sourceDir $f
    if (Test-Path $src) {
        try {
            Copy-Item -Path $src -Destination $TargetFolder -Force
            Write-Host "Copied $f" -ForegroundColor Green
        } catch {
            Write-Warning ("Failed to copy {0}: {1}" -f $f, $_)
        }
    } else {
        Write-Warning "$f not found in $sourceDir. Consider installing the Visual C++ Redistributable on your build machine or use the official redistributable installer to obtain these files."
    }
}

Write-Host "Done. Test your EXE from $TargetFolder on a clean machine to confirm it starts without redistributable installed." -ForegroundColor Cyan
