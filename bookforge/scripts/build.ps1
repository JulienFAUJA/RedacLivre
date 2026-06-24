<#
.SYNOPSIS
  Compile un livre BookForge en PDF avec latexmk.
.DESCRIPTION
  Configure TEXINPUTS pour trouver les styles partagés (../styles), puis lance
  latexmk. Si aucune distribution LaTeX n'est installée, affiche les
  instructions d'installation et s'arrête proprement.
.EXAMPLE
  ./build.ps1 -Livre demo
  ./build.ps1 -Livre demo -Moteur xelatex
#>
[CmdletBinding()]
param(
  [string]$Livre = "demo",
  # lualatex par défaut : UTF-8 natif (accents dans le code sans bricolage
  # listings/literate), polices modernes. pdflatex reste possible mais exige
  # une table d'accents exhaustive dans les extraits de code.
  [ValidateSet("lualatex","xelatex","pdflatex")]
  [string]$Moteur = "lualatex"
)

$ErrorActionPreference = "Stop"
$racine   = Split-Path -Parent $PSScriptRoot          # .../bookforge
$styles   = Join-Path $racine "styles"
$dossier  = Join-Path $racine "livres/$Livre"
$main     = Join-Path $dossier "main.tex"

if (-not (Test-Path $main)) {
  Write-Error "Livre introuvable : $main"
  exit 1
}

# --- Mettre MiKTeX dans le PATH s'il est installe mais absent du PATH -------
# (installation winget --scope user : bin pas toujours dans le PATH du shell)
if (-not (Get-Command $Moteur -ErrorAction SilentlyContinue)) {
  $miktexBins = @(
    "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64",
    "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin",
    "C:\Program Files\MiKTeX\miktex\bin\x64"
  ) | Where-Object { Test-Path $_ }
  if ($miktexBins) { $env:PATH = ($miktexBins -join ';') + ';' + $env:PATH }
}

# --- Vérifier la présence d'une distribution LaTeX -------------------------
$latexmk = Get-Command latexmk -ErrorAction SilentlyContinue
$moteurBin = Get-Command $Moteur -ErrorAction SilentlyContinue
if (-not $moteurBin) {
  Write-Host "[!] LaTeX n'est pas installe (binaire '$Moteur' introuvable)." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "    Installe une distribution, par exemple :"
  Write-Host "      winget install MiKTeX.MiKTeX        # leger, telechargement a la demande"
  Write-Host "      winget install TeXLive.TeXLive      # complet"
  Write-Host ""
  Write-Host "    Puis relance :  ./build.ps1 -Livre $Livre"
  exit 2
}

# --- TEXINPUTS : ajouter le dossier des styles -----------------------------
# Le ';' final preserve le chemin de recherche par defaut de la distribution.
$env:TEXINPUTS = "$styles;" + $env:TEXINPUTS

# latexmk est un script Perl : ne l'utiliser que si Perl est present, sinon il
# echoue ("could not find the script engine 'perl'"). On privilegie donc une
# boucle pdflatex maison, fiable sans dependance supplementaire.
$perl = Get-Command perl -ErrorAction SilentlyContinue

Push-Location $dossier
try {
  New-Item -ItemType Directory -Force build | Out-Null
  $pdf = "build/main.pdf"

  if ($latexmk -and $perl) {
    $flag = switch ($Moteur) {
      "pdflatex" { "-pdf" }
      "xelatex"  { "-xelatex" }
      "lualatex" { "-lualatex" }
    }
    & latexmk $flag -interaction=nonstopmode -output-directory=build main.tex
  } else {
    # Passe 1 : genere le .idx (index brut) et le .aux initial
    Write-Host "[build] passe 1/4 ($Moteur)..." -ForegroundColor Cyan
    & $Moteur -interaction=nonstopmode -output-directory=build main.tex | Out-Null

    # makeindex : trie et formate l'index (.idx -> .ind)
    if (Test-Path "build/main.idx") {
      Write-Host "[build] makeindex..." -ForegroundColor Cyan
      $miktexBin = ($env:PATH -split ';' | Where-Object { $_ -match 'MiKTeX' } | Select-Object -First 1)
      $makeindexExe = if ($miktexBin) { Join-Path $miktexBin "makeindex.exe" } else { "makeindex" }
      $oldErrorActionPreference = $ErrorActionPreference
      try {
        # makeindex can write harmless banner text to stderr; do not let that
        # become a fatal PowerShell error while $ErrorActionPreference is Stop.
        $ErrorActionPreference = "Continue"
        & $makeindexExe "build/main.idx" -o "build/main.ind" *> $null
        $makeindexExit = $LASTEXITCODE
      }
      finally {
        $ErrorActionPreference = $oldErrorActionPreference
      }
      if ($makeindexExit -ne 0) {
        Write-Warning "makeindex a retourne le code $makeindexExit ; voir build/main.ilg"
      }
    }

    # Passes 2-4 : stabilise TOC, references croisees et index pagine
    for ($i = 2; $i -le 4; $i++) {
      Write-Host "[build] passe $i/4 ($Moteur)..." -ForegroundColor Cyan
      & $Moteur -interaction=nonstopmode -output-directory=build main.tex | Out-Null
    }
  }

  # On ne se fie PAS au seul code retour (MiKTeX le pollue avec des
  # avertissements) : on verifie que le PDF existe et vient d'etre ecrit.
  if (-not (Test-Path $pdf)) {
    Write-Error "Echec : aucun PDF produit. Voir build/main.log"
    exit 3
  }
  $age = (Get-Date) - (Get-Item $pdf).LastWriteTime
  if ($age.TotalMinutes -gt 5) {
    Write-Warning "Le PDF semble ancien ($([int]$age.TotalMinutes) min). La compilation a peut-etre echoue ; voir build/main.log"
  }
  Write-Host "[OK] PDF genere : $dossier/build/main.pdf" -ForegroundColor Green
}
finally {
  Pop-Location
}
# Le PDF a ete verifie ci-dessus : on impose un code retour propre (MiKTeX
# pollue $LASTEXITCODE avec ses avertissements non bloquants).
exit 0
