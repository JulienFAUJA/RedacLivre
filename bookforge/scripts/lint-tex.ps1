<#
.SYNOPSIS
  Garde-fou : refuse les commandes LaTeX brutes dans les fichiers de contenu.
.DESCRIPTION
  Les agents rédacteurs ne doivent utiliser QUE les commandes sémantiques de
  bookforge. Ce lint scanne les .tex de contenu (frontmatter/ et chapitres/)
  et signale toute commande de mise en page interdite. C'est ce qui garantit
  que la traduction restera triviale et la cohérence visuelle inviolable.

  Code de sortie 0 = propre, 1 = violations détectées.
.EXAMPLE
  ./lint-tex.ps1 -Livre demo
#>
[CmdletBinding()]
param(
  [string]$Livre = "demo"
)

$racine  = Split-Path -Parent $PSScriptRoot
$dossier = Join-Path $racine "livres/$Livre"

# Commandes/environnements LaTeX bruts interdits dans le CONTENU.
# (Autorisés uniquement dans styles/*.sty et dans main.tex.)
$interdits = @(
  '\\chapter\b',        '\\section\*',        '\\subsection\b(?![a-z])',
  '\\textbf\b',         '\\textit\b',         '\\emph\b',
  '\\vspace\b',         '\\hspace\b',         '\\newpage\b',
  '\\begin\{lstlisting\}', '\\begin\{verbatim\}', '\\begin\{quote\}',
  '\\begin\{itemize\}', '\\begin\{enumerate\}', '\\begin\{figure\}',
  '\\includegraphics\b', '\\color\b',         '\\fontsize\b',
  '\\titleformat\b',    '\\definecolor\b'
)
$pattern = ($interdits -join '|')

$fichiers = Get-ChildItem -Path $dossier -Recurse -Filter *.tex |
  Where-Object { $_.FullName -notlike "*\build\*" -and $_.Name -ne "main.tex" }

$violations = 0
foreach ($f in $fichiers) {
  $n = 0
  foreach ($ligne in Get-Content $f.FullName) {
    $n++
    # On ignore les lignes de commentaire pur.
    if ($ligne -match '^\s*%') { continue }
    if ($ligne -match $pattern) {
      $rel = $f.FullName.Substring($dossier.Length + 1)
      Write-Host ("{0}:{1}: " -f $rel, $n) -ForegroundColor Red -NoNewline
      Write-Host $ligne.Trim()
      $violations++
    }
  }
}

if ($violations -gt 0) {
  Write-Host ""
  Write-Host "[LINT] $violations violation(s) : commandes LaTeX brutes interdites." -ForegroundColor Red
  Write-Host "       Remplace-les par les commandes semantiques bookforge." -ForegroundColor Red
  exit 1
} else {
  Write-Host "[LINT] OK - uniquement des commandes semantiques." -ForegroundColor Green
  exit 0
}
