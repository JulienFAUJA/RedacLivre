<#
.SYNOPSIS
  Helper d'orchestration BookForge : inspecte l'état d'un livre et liste les
  chapitres à traiter. Le lancement réel des agents se fait via l'outil Agent
  de Claude Code (voir runbook ci-dessous).
.DESCRIPTION
  Le PARALLÉLISME réel est assuré par Claude Code : l'orchestrateur (toi, dans
  une session Claude Code) lit livre.json, puis lance UN sous-agent Rédacteur
  par chapitre `a_rediger` en parallèle (Agent run_in_background), chacun avec
  le prompt construit depuis chapitre.json + style-guide + termes + intros
  voisines. Ce script ne lance pas les agents : il donne l'état pour piloter.

  RUNBOOK :
    1. Architecte (séquentiel)  -> remplit livre.json + intros + plans.
    2. Fan-out (parallèle)      -> 1 Rédacteur par chapitre `a_rediger`.
    3. Fan-in -> Éditeur (séq.) -> cohérence + lint global.
    4. build.ps1                -> PDF.
    5. (option) Traducteur (parallèle par chapitre) -> livre-<langue>.
.EXAMPLE
  ./orchestrate.ps1 -Livre monlivre -Action status
  ./orchestrate.ps1 -Livre monlivre -Action a-rediger
#>
[CmdletBinding()]
param(
  [string]$Livre = "demo",
  [ValidateSet("status","a-rediger","rediges")]
  [string]$Action = "status"
)

$racine    = Split-Path -Parent $PSScriptRoot
$dossier   = Join-Path $racine "livres/$Livre"
$manifeste = Join-Path $dossier "livre.json"

if (-not (Test-Path $manifeste)) {
  Write-Host "[!] Pas de livre.json pour '$Livre'." -ForegroundColor Yellow
  Write-Host "    Lance d'abord l'agent Architecte (voir agents/architecte.md)."
  exit 1
}

$data = Get-Content $manifeste -Raw -Encoding utf8 | ConvertFrom-Json
$chapitres = $data.chapitres

switch ($Action) {
  "status" {
    Write-Host "Livre : $($data.titre)  [$($data.langue)]"
    Write-Host ("Chapitres : {0}" -f $chapitres.Count)
    $chapitres | ForEach-Object {
      $dep = if ($_.depend_de) { " (depend: $($_.depend_de -join ','))" } else { "" }
      "{0,-4} {1,-12} {2}{3}" -f $_.id, $_.statut, $_.titre, $dep
    }
  }
  "a-rediger" {
    ($chapitres | Where-Object statut -eq "a_rediger").id -join "`n"
  }
  "rediges" {
    ($chapitres | Where-Object statut -eq "redige").id -join "`n"
  }
}
