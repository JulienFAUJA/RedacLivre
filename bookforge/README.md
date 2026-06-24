# BookForge

Système de rédaction de livres en LaTeX par agents Claude Code parallèles.

## Principe directeur : séparation stricte **contenu ↔ style**

Les agents n'écrivent jamais de mise en page. Ils écrivent du **contenu
sémantique** (`\chapitre`, `\paragraphe`, `\important`, `\begin{extraitcode}`…).
Tout le « look » vit dans `styles/`. Conséquences :

- **Traduction triviale** : on remplace le texte *dans* les commandes, la mise
  en page suit toute seule.
- **Cohérence inviolable** : impossible pour un agent de diverger sur la forme.
- **Parallélisme sûr** : chaque agent écrit dans son propre dossier.

## Arborescence

| Dossier | Rôle |
|---|---|
| `styles/` | `bookforge.sty` (commandes sémantiques), `theme-technique.sty` (look), `code-listings.sty` (extraits de code). **Créés une fois.** |
| `livres/<slug>/` | Un livre : `livre.json` (manifeste), `main.tex` (assemblage), `frontmatter/`, `chapitres/<id>-<slug>/`. |
| `glossaire/` | `termes.json` + `style-guide.md` : le **contrat éditorial partagé**. |
| `agents/` | Définitions : architecte, redacteur-chapitre, editeur, traducteur. |
| `scripts/` | `build.ps1`, `lint-tex.ps1`, `orchestrate.ps1`. |

## Pipeline

```
grandes lignes
   -> ARCHITECTE (séquentiel)  : livre.json + intros + plans + glossaire
   -> fan-out : 1 RÉDACTEUR par chapitre EN PARALLÈLE  (run_in_background)
   -> fan-in  : ÉDITEUR (séquentiel) : cohérence + lint
   -> build.ps1 : PDF
   -> (option) TRADUCTEUR (parallèle par chapitre) : livre-<langue>
```

## Commandes

```powershell
# État d'un livre / chapitres à rédiger
scripts\orchestrate.ps1 -Livre demo -Action status

# Garde-fou : refuse toute commande LaTeX brute dans le contenu
scripts\lint-tex.ps1 -Livre demo

# Compilation PDF (nécessite MiKTeX ou TeX Live)
scripts\build.ps1 -Livre demo
```

## Installation de LaTeX

```powershell
winget install MiKTeX.MiKTeX      # léger, paquets à la demande
# ou
winget install TeXLive.TeXLive    # complet
```

## Commandes sémantiques disponibles (résumé)

- Structure : `\chapitre{}`, `\introChapitre{}`, `\section{}`, `\soussection{}`
- Texte : `\paragraphe{}`, `\important{}`, `\terme{}`, `\etranger{}`
- Encadrés : `note`, `astuce`, `avertissement`
- Citations/listes : `bloccitation[source]`, `liste`/`element`, `listeNumerotee`
- Figures : `\illustration{chemin}{légende}`
- Code : `\begin{extraitcode}{Langage} … \end{extraitcode}`, `\code{}` inline
- Livre : `\livreTitre{}`, `\livreSousTitre{}`, `\livreAuteur{}`, `\introLivre{}`,
  `\pageTitre`, `\tableMatieres`

Voir `livres/demo/` pour un exemple exerçant tous les styles.
