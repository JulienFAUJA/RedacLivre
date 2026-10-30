<# Prépare un Python local RedacLivre avec le SDK SoftHUB voisin. #>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$softHubRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot '../SoftHUB'))
$sdkRoot = Join-Path $softHubRoot 'sdk'
$venvPython = Join-Path $projectRoot '.venv/Scripts/python.exe'
$hostPython = (Get-Command python -ErrorAction Stop).Source

& $hostPython (Join-Path $sdkRoot 'build_release.py')
if ($LASTEXITCODE -ne 0) { throw 'Construction du SDK SoftHUB impossible.' }

$versionLine = Select-String -LiteralPath (Join-Path $sdkRoot 'pyproject.toml') `
  -Pattern '^version = "([^"]+)"' | Select-Object -First 1
if (-not $versionLine) { throw 'Version SDK introuvable.' }
$version = $versionLine.Matches[0].Groups[1].Value
$wheel = Join-Path $sdkRoot "dist/softhub_sdk-$version-py3-none-any.whl"
if (-not (Test-Path -LiteralPath $wheel)) { throw 'Roue SDK introuvable.' }

if (-not (Test-Path -LiteralPath $venvPython)) {
  & $hostPython -m venv --system-site-packages (Join-Path $projectRoot '.venv')
  if ($LASTEXITCODE -ne 0) { throw 'Création du Python local impossible.' }
}
& $venvPython -m pip install --no-index --no-deps --force-reinstall $wheel
if ($LASTEXITCODE -ne 0) { throw 'Installation du SDK impossible.' }
& $venvPython -c 'from softhub_sdk.job_state import RetryScheduler; print(RetryScheduler.__module__)'
if ($LASTEXITCODE -ne 0) { throw 'Contrat de reprise SDK indisponible.' }
Write-Host "RedacLivre : SDK $version installé dans .venv." -ForegroundColor Green
