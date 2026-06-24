# Guide de style BookForge — « Claude Code en pratique »

> Ce fichier est le **contrat éditorial partagé**. L'Architecte le pré-remplit
> pour chaque livre ; chaque sous-agent Rédacteur le reçoit en entier. C'est
> lui qui garantit la cohérence du ton et du vocabulaire malgré la rédaction
> parallèle (les sous-agents ne communiquent pas entre eux).

## Ton et registre
- **Pédagogique, concret, direct, sans bla-bla.** On enseigne par l'exemple
  réel et le cas vécu, pas par la théorie abstraite ni la doc reformulée.
- Phrases courtes, voix active. Éviter le jargon non défini.
- Une idée par paragraphe.
- **Angle différenciant à tenir** : montrer comment déléguer de vraies tâches,
  vérifier le travail de l'agent, poser des garde-fous, surveiller les coûts,
  éviter les pièges. On bat les guides génériques « promptez mieux » par du
  concret. Privilégier les exemples vécus (succès ET ratés assumés).
- Pas de promesse magique : l'agent se trompe, on l'assume et on outille la
  vérification.

## Personne et adresse au lecteur
- **Tutoiement** (« tu »), du début à la fin. Jamais de « vous ».
- Présent de l'indicatif, ton de pair à pair (un dev qui parle à un dev).
- Le lecteur **sait coder** : ne jamais réexpliquer la programmation de base.
  Il est **débutant en agents**, pas en développement.

## Datation du contenu (IMPORTANT pour ce livre)
- Le livre est positionné **édition 2026**, centré sur **Claude Code**.
- Les chapitres dont les détails changent vite (commandes exactes, versions,
  tarifs, écosystème d'outils) sont : **02 (installation), 08 (coûts),
  09 (commandes/hooks), 10 (MCP)**. Y signaler explicitement, via un encadré
  `note` ou `avertissement`, que ces détails peuvent dater et indiquer le
  réflexe pour vérifier la version courante.
- Les autres chapitres visent des **principes durables** (penser, déléguer,
  vérifier, encadrer, orchestrer) : y éviter de citer des numéros de version ou
  des prix précis qui périmeraient le propos.

## Conventions typographiques (RAPPEL — via commandes sémantiques uniquement)
- Premier emploi d'un terme du glossaire → `\terme{...}`.
- Insistance forte → `\important{...}` (gras coloré, avec parcimonie).
- Emphase douce (italique) → `\emphase{...}`. **Ne JAMAIS utiliser `\emph{}`** (commande brute interdite).
- Mot en langue étrangère → `\etranger{...}`.
- Nom de commande, drapeau, bout de code en ligne → `\code{...}`.
- Bloc de code → `\begin{extraitcode}{Langage} ... \end{extraitcode}`
  Suivi de `\legendecode{Légende}` en italique sous le bloc (optionnel mais recommandé).
  (langages utiles ici : `bash`, `json`, `text`, plus le langage du dépôt-exemple).
- **Jamais** de `\textbf`, `\textit`, `\emph`, `\section*`, `\chapter` bruts.

## Structure attendue d'un chapitre
1. `\chapitre{Titre}` (fourni par l'Architecte, ne pas le changer).
2. `\introChapitre{...}` (fournie par l'Architecte ; le Rédacteur peut l'affiner légèrement).
3. 3 à 6 `\section{...}` suivant le plan fourni (un point du plan ≈ une section).
4. Encadrés `note`/`astuce`/`avertissement` là où c'est utile (pas de remplissage).
   - `astuce` : raccourci, bonne pratique de délégation/vérification.
   - `avertissement` : piège, opération risquée, détail susceptible de dater.
5. Extraits de code via `\begin{extraitcode}{Langage}` quand pertinent
   (transcriptions de session, exemples de configuration, diffs commentés).
   Toujours ajouter `\legendecode{Légende courte}` juste après `\end{extraitcode}`
   (ex. `\legendecode{Installation de Claude Code}`).

## Cohérence inter-chapitres
- Ne pas redéfinir un terme déjà introduit dans un chapitre précédent : se fier
  à `termes.json` et à la colonne « première occurrence ».
- Pour une transition, s'appuyer sur les **intros des chapitres voisins**
  fournies dans le prompt (ne pas inventer le contenu des autres chapitres).
- Respecter les `depend_de` : un chapitre peut supposer acquis ce qui précède.
- Vocabulaire verrouillé : on dit **agent**, **subagent**, **Claude Code**,
  **contexte**, **garde-fou**, **orchestration** (voir `termes.json`).

## Longueur cible
- **Court et dense : 1300 à 1600 mots de corps par chapitre.** Le style « sans
  bla-bla » est un parti pris assumé : on préfère concis et actionnable au
  remplissage. Ne PAS diluer pour atteindre un quota. Mieux vaut 1400 mots
  utiles que 2400 mots dont 1000 de délayage.
- Le champ `longueur_cible` des `chapitre.json` est indicatif ; la densité prime
  sur le nombre de mots.
