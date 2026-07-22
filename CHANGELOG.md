# Changelog

## v1.1.15 (2026-07-22)

* Fix Map418 (KARRINA + coffre du puzzle Méga-Pierres) : les noms Pokémon et Méga-Pierres étaient incorrects.
  * « une Banettite » → **« une Branettite »** (Banette = Branette en FR).
  * « une Scarhexite » → **« une Scarhinoïte »** (Heracross = Scarhino, avec tréma sur le i).
  * « une pour Branette et une pour Scarhex » → **« une pour Branette et une pour Scarhino »**.
  * Choix du coffre : « Banettite ! » → **« Branettite ! »** et « Scarhexite ! » → **« Scarhinoïte ! »**.

## v1.1.14 (2026-07-22)

* Fix : le caractère `ç` / `Ç` s'affichait comme un carré vide dans les 8 cartes utilisant la police rétro Gen 1 (`PKMN RBYGSC.ttf`) — la police ne contient pas ce glyphe, contrairement à ce que la v1.1.9 supposait. **107 cédilles remplacées** par leurs équivalents `c` / `C` dans les cartes `ATEBITMAPS` : Map293, 340, 366, 379, 394, 460, 521, 673. Exemple : « Ça veut dire qu'ALICE est un Zarbi ? » → « Ca veut dire qu'ALICE est un Zarbi ? » (Map293).
* Note : la casse est préservée (majuscule en début de phrase reste majuscule).

## v1.1.13 (2026-07-22)

**Fix critique de crash + refonte des Emblèmes de type + support Linux/macOS.**

### Bugs bloquants

* Fix : dans Map293, deux lignes du dialogue d'Amber (ex-ALICE) crashaient le jeu en français avec `Errno::ENOENT: File Audio/SE/402cry not found`. Le fichier réel s'appelle `402Cry.wav` (C majuscule) — le lookup était strict sur la casse. La référence FR `\se[402cry]` devient `\se[402Cry]`. Le dialogue est à nouveau franchissable.

### Traductions Pokémon / attaques

* Fix Map234 (VENAM) et Map249 (KANON) : « Salamence » traduit en « Salamèche » (Charmander !) est corrigé en **Drattak** (nom FR officiel de Salamence).
* Fix Map250 : « Tangrowth's Power Whip » traduit en « Fouet Lianes d'un Tissenbulle » est corrigé en **Mégafouet d'un Bouldeneu** (deux lignes du réveil d'Anathea).
* Fix Map097 + Map217 : 16 occurrences de « Poliwag » restées en anglais sont remplacées par **Ptitard**, y compris les cris `POLIWAG: Poliwag !` → `PTITARD: Ptitard !` et les speaker labels.

### Refonte « Crête » → « Emblème »

* Uniformisation des 108 items Crest de Rejuvenation : tous les `Crête X` deviennent `Emblème X` (cohérence avec `Emblème Migalos` fixé en v1.1.7). Fichiers touchés : `Items.json` (64), `ItemPlurals.json` (44), `07_Items.json` (45).
* Fix des références dans les dialogues : Map347 (Crête Morphéo → Emblème Morphéo), Map422 (Cette Crête Kaorine, une Crête Torterra, cette Crête), Map516 (plus de Crêtes → plus d'Emblèmes), Map603 (une Crête Spiritomb → un Emblème Spiritomb). Accord de genre corrigé (Emblème est masculin).

### Autres corrections

* Fix Map333 : « Y a un espèce de bizarre » (grammaire cassée, `espèce` est féminin) → **« Y a un mec bizarre »** (2 lignes AMBER + TESLA).
* Fix Map413 (TESLA) : « Il n'y a rien à apologi- » (fragment d'anglais) → **« Il n'y a pas à t'excus- »**.
* Fix Map415 : « That must really suck » traduit en « Ça doit vraiment sucer » (littéral erroné) → **« Ça doit vraiment être de la merde »**.
* Fix Map415 : ligne « Waouh t'es courageux(se), \PN. Pas du tout fou(folle) ou quoi que ce soit ! » reformulée pour éviter le marqueur `fou(folle)` qui ne se résolvait pas.
* Fix Map234 : « Je ne deviens pas fou(folle), hein ? » (locuteur féminin) → **« Je ne deviens pas folle, hein ? »** (résolution directe puisque le locuteur n'est pas le joueur).
* Fix Map270 : « Pool Party mais avec du fun » → **« Pool Party, mais amusante »**.
* Fix Map516 (ARCHÉOLOGUE) : « plus de Crêtes quelque part » → « plus d'Emblèmes quelque part » (cohérence avec la refonte).

### Cross-platform

* **Support Linux et macOS** : l'auto-updater détecte désormais la plateforme via `RUBY_PLATFORM` et génère un `.sh` POSIX (`sleep 3` → `cp -Rf` → cleanup → relance via `mkxp-z` / `mkxp-z.app`) au lieu du `.bat`+`.vbs`+`robocopy`+`wscript.exe` réservés à Windows. Le `.sh` est écrit en LF pur via `File.binwrite` et lancé en détaché via `nohup sh` + `Process.detach`.
* Audit de casse des références audio (`\se[...]`, `\me[...]`, `\bgm[...]`, `\bgs[...]`) contre 3576 fichiers indexés : aucun autre mismatch après le fix `402Cry`. Rejuvenation FR est compatible Linux (mkxp-z Linux) sans autre modification.

### Remerciements

* **Justyne88** est ajoutée à la section Remerciements du README pour son travail de traduction des images du jeu (à intégrer dans une prochaine version).

## v1.1.12 (2026-07-20)

* Fix : 4 phrases utilisaient le conditionnel présent (`-rais`) alors que la version anglaise est au futur (`will` / `won't`). Corrigées en futur simple (`-rai`) :
  * Map392 : « Je ne reculerais pas ! » → « Je ne reculerai pas ! » (`I won't back down`)
  * Map400 : « Je ne raterais ça pour rien au monde ! » → « Je ne raterai ça pour rien au monde ! » (`I won't miss this`)
  * Map209 : « Tu ne penses pas que je serais un bon candidat » → « je serai un bon candidat » (`I'll be a good fit`)
  * BattleTowerIntroSpeech : « je gagnerais aujourd'hui » → « je gagnerai aujourd'hui » (`I will win today`)

## v1.1.11 (2026-07-20)

Support **JoiPlay et Kirin (Android)** :

* Le mod fonctionne désormais sur JoiPlay / Kirin sans planter. L'auto-updater est automatiquement désactivé sur ces environnements (ils n'ont ni `Net::HTTP` ni `cmd.exe`/`robocopy` pour appliquer un patch en tâche de fond).
* Sur mobile, les utilisateurs doivent télécharger manuellement chaque nouvelle version depuis GitHub Releases.
* Toutes les autres fonctionnalités sont préservées : traductions, sélection du genre, résolution automatique des accords, hooks des messages de combat, etc.

## v1.1.10 (2026-07-20)

* Fix : « j'arriverai plus vite qu'un **Bidoof** peut dire **Bidoof~** ! » → « j'arriverai plus vite qu'un **Keunotor** peut dire **Neutor~** ! » (Map298). Les noms de Pokémon FR officiels avaient été laissés en anglais dans cette ligne.

Merci à **Lavril** pour le signalement.

## v1.1.9 (2026-07-19)

* Fix : dans les 9 cartes du jeu utilisant la police rétro Gen 1 (`PKMN RBYGSC.ttf`), les caractères `è`, `à`, `ê`, `î`, `ô`, `ù`, `û` et `œ` s'affichaient comme des carrés vides car la police ne contient pas ces glyphes. **720 caractères remplacés** par leurs équivalents supportés (`è` → `é`, `à` → `a`, `ê` → `e`, etc.) dans les cartes concernées : Map293, 340, 366, 379, 394, 460, 521, 642, 673.
* Le texte « as les pièces pour te les payer » devient « as les piéces pour te les payer » (le `é` est visuellement acceptable, contrairement au carré).

Merci à **Lavril** pour le signalement.

## v1.1.8 (2026-07-19)

* Fix : ~40 descriptions d'attaques (moves) trop longues raccourcies, dont **CT94 Éclate-Roc** (signalé par Tench) : « Le lanceur attaque d'un coup de poing. Peut baisser la Défense de la cible. Permet aussi de briser des rochers sur le terrain. » → « Le lanceur frappe d'un poing. Peut baisser la Défense. Brise aussi les rochers sur le terrain. »
* Cibles corrigées : Rock Smash, Bind, Gear Grind, Wave Crash, Aura Wheel, Jungle Healing, Meteor Assault, Snipe Shot, Behemoth Blade/Bash, Fishious Rend, Terrain Pulse, Sandstorm Wall, Snow Wall, Moongeist Beam, Electro Shot, Blood Moon, Cross Poison, et une trentaine d'autres.

Merci à **Tench** pour le signalement.

## v1.1.7 (2026-07-19)

* Fix : ~40 descriptions d'items débordaient encore la boîte d'affichage. Raccourcies sans perdre le sens : Miel, Sombre Ball, canne à pêche high-tech, lunettes Choix, ROM Élektrik, Étiquette Spectre, Danse Attaque/Défense, Reliques d'ancienne civilisation, engrais, Théière fêlée, cassette d'audition de Melia, etc.
* Fix : description de la capacité **Poison Croix** raccourcie (« Une taillade avec des lames pouvant laisser la cible empoisonnée » — on retire le premier « empoisonnées » qui faisait doublon).
* Fix : **Ariados Crest** est désormais traduit en **« Emblème Migalos »** (pas « Crête Migalos »).

Merci à **Tench** pour les signalements.

## v1.1.6 (2026-07-19)

* **Descriptions officielles Poképédia** pour les 18 Joyaux de type (Feu, Eau, Électrik, Plante, Glace, Combat, Poison, Sol, Vol, Psy, Insecte, Roche, Spectre, Dragon, Ténèbres, Acier, Normal, Fée) : « Objet à tenir. Joyau augmentant une fois la puissance des capacités de type X. » (~80 caractères, canon FR).
* **Feuille Copieuse** (Mirror Herb) : description officielle Poképédia.
* **Fix : la fenêtre CMD ne s'affiche plus** pendant l'installation de la mise à jour. L'updater passe désormais par un wrapper VBScript (`.rejuvfr_apply.vbs`) qui invoque le `.bat` via `WScript.Shell.Run(cmd, 0, false)` — le processus tourne en arrière-plan totalement invisible. Compatible Windows XP à Windows 11.
* **Fix : le message « Téléchargement en cours... » ne bloque plus l'utilisateur**. Il utilise maintenant le code de contrôle `\wtnp[45]` (auto-dismiss après ~1.5 s, standard Rejuvenation) au lieu d'un `pbMessage` bloquant qui attendait une pression de touche. Les utilisateurs de v1.1.5 étaient piégés sur ce message.

## v1.1.5 (2026-07-19)

Descriptions d'objets raccourcies pour tenir en 3 lignes maximum :

* Environ **95 descriptions d'items** qui débordaient de la boîte d'affichage sont raccourcies sans perdre le sens : Clé USB mystérieuse, Brindille-Miroir, Ceinture Poké Balls, tous les Joyaux de type (Feu, Eau, Électrik...), toutes les Méga-Gemmes, et une trentaine d'autres.
* Cible : `ItemDescriptions.json` et `08_ItemDescriptions.json` — les deux fichiers utilisés par le jeu pour l'affichage des objets. La règle de longueur est ≤ 130 caractères (validée en jeu).

Merci à **Tench** pour le signalement.

## v1.1.4 (2026-07-19)

Correctif critique sur l'updater in-game :

* Fix : la boîte de dialogue de proposition de mise à jour apparaissait **avant** l'initialisation de la scène de jeu (`Scene_Map#main` était hooké au tout début, avant `createSpritesets`, `Graphics.transition` et `Input.update`). Résultat : la boîte s'affichait mais **ne pouvait pas être fermée** car l'input n'était pas encore actif.
* Le hook est déplacé sur `Scene_Map#update` avec une attente d'environ 60 frames (une seconde) après l'entrée dans la scène. Le prompt ne s'affiche plus que si aucun autre message n'est en cours, aucune transition n'est en train de se jouer, et aucun event Ruby n'est en exécution.
* Ajout d'un `rescue` protecteur qui marque la notification comme traitée en cas d'erreur, pour éviter une boucle infinie de crash.

## v1.1.3 (2026-07-19)

Réécriture complète de l'updater pour qu'il fonctionne réellement.

* Fix : l'updater v1.1.2 pouvait télécharger et extraire, mais n'écrasait pas `messages_fr.dat` à cause du lock Windows tenu par mkxp-z sur ce fichier pendant l'exécution.
* Solution : extraction dans un dossier de staging temporaire `.rejuvfr_update/`, puis spawn d'un script `.rejuvfr_apply.bat` détaché qui attend 3 secondes que le jeu se ferme, déplace les fichiers via `robocopy` (comme le fait l'Updater officiel de Rejuvenation pour la mise à jour du moteur), puis se supprime.
* Fix : le spawn détaché utilise maintenant `cmd.exe /c` avec chemins absolus pour ne pas dépendre du répertoire de travail.
* Ce flow a été testé en local en simulant le lock Windows et fonctionne bout à bout : détection, download avec redirection HTTPS → CDN, extraction, application, redémarrage automatique via `exit!`.

## v1.1.2 (2026-07-19)

Correctifs sur l'updater in-game :

* Fix : le téléchargement automatique plantait avec `NoMethodError` chez certains utilisateurs. La gestion des redirections HTTP a été réécrite (récursion au lieu de manipuler `http.start` / `http.finish` en cours de bloc, qui causait des états invalides quand GitHub redirigeait le zip vers son CDN).
* Fix : ajout d'un wrapper `rejuvfr_safe_message` qui teste plusieurs alternatives pour `Kernel.pbMessage`. Aucun `NoMethodError` même si l'API varie légèrement selon la version du moteur.
* Fix : tous les textes du prompt sont maintenant en dur en français au lieu de passer par `_INTL`, qui n'est parfois pas encore chargé quand la notification est déclenchée.
* Ajout d'un log de debug dans `patch/.rejuvfr_updater.log` pour tracer les éventuelles erreurs de détection / téléchargement / extraction.

## v1.1.1 (2026-07-19)

Correctifs de terminologie officielle FR :

* **Talent "Flash Fire"** : "Flash Feu" corrigé en **"Torche"** (nom officiel depuis la Gen 6).
* **Capacité "Cut"** : "Couper" corrigé en **"Coupe"** (nom officiel de la CS).
* **Capacité "Flash"** : "Lumière" corrigé en **"Flash"** (nom officiel de la CS et de l'attaque).
* Environ 20 occurrences corrigées à travers les descriptions, notes de terrain et dialogues NPC (`utilise Lumière` → `utilise Flash`, etc.).

## v1.1.0 (2026-07-19)

Cible : **Rejuvenation 14.0.6**.

### Nouveautés

* **Sélection du genre du personnage** au moment de choisir "Français". Le choix (masculin / féminin) est sauvegardé dans `Saved Games/Rejuv/french_gender.dat` et persiste entre redémarrages. Les 2849 marqueurs d'accord `(e)`, `(euse)`, `(trice)`, `(elle)`, `(ère)`... sont résolus automatiquement dans tous les dialogues qui s'adressent au joueur.
* **Mise à jour in-game** : au chargement d'une partie, le mod vérifie s'il existe une nouvelle version sur GitHub Releases. Si oui, il propose de la télécharger et de l'installer directement (comme le fait le système officiel Updater de Rejuvenation), puis relance le jeu.

### Corrections critiques

* **Mots de passe story préservés en anglais**. `PASSWORD: UNBOUND` et `PASSWORD: SOUL` avaient été traduits (`DECHAINE` / `AME`), rendant les énigmes impossibles à résoudre. Les mots de passe cheat de `passwordtext.rb` (mintyfresh, casspack, easymode, etc.) sont également vérifiés.
* **La langue française est désormais conservée au redémarrage**. Avant, `pbLoadLanguage` était appelé au boot avec `LANGUAGES = {}`, ce qui réinitialisait le jeu en anglais. Un hook sur `pbLoadLanguage` réinjecte la constante avant chaque résolution.

### Fixes

* **1188 nouvelles traductions** injectées pour la mise à jour 14.0.6 (680 noms de dresseurs, 333 noms Battle Tower, ~175 dialogues et scripts).
* **Timburr = Charpenti** (était erroné en "Trompignon", qui est Foongus).
* **Jeu de mot "Sea you"** refait proprement en français : `On se voit MERcredi. Tu piges ? MER - credi`.
* **Allongement moqueur "a litttleeee paranoid"** rendu en `un touuut ptiiit peu parano` (était `uuuun tiiiiout peu parano`, cassait la moquerie).
* **7 résidus "PERDUé"** (majuscules) corrigés en "PERDU".
* **155 occurrences de "POKéMON"** corrigées en "POKÉMON".
* **"sûr(e) scène"** → **"sur scène"** (Alexandra, Map638).
* **Idiomes "on fire"** re-traduits en français familier : 10 lignes, "je vois que t'es chaud", "T'es chaud !", etc.
* **"practice round"** → "échauffement" (était "juste un répétition").
* **Erreurs de traduction diverses** ("coupable" → "coupé" pour l'arbre à couper, etc.).
* **`_MAPINTL` hook** ajouté pour couvrir les dialogues d'events RPG Maker XP (qui ne passaient pas par le hook `_INTL`).
* **`french_battle_messages.rb` étendu** : fallback vers `:FieldMessages`, `:AceSpeech`, `:EndSpeechLose` en plus de `:ScriptTexts` pour récupérer les traductions stockées dans le mauvais bucket.

## v1.0.12 (2026-07-17)

* Fix: 7880 dialogues avaient un point d'interrogation ou d'exclamation directement suivi d'une lettre, sans espace ("Vraiment ?Tu es..." au lieu de "Vraiment ? Tu es..."). Meme mecanisme de correction que v1.0.11 mais applique a `?` et `!`.

## v1.0.11 (2026-07-17)

* Fix: 858 dialogues avaient un point non suivi d'un espace ("phrase.Autre" au lieu de "phrase. Autre"). Corrige automatiquement, en preservant les abreviations legitimes (Sp., Def.Spe, Att., N.5, etc.) et les balises engine (\PN., \v[X]).

## v1.0.10 (2026-07-17)

* Fix: 760 dialogues supplementaires (bosstext, trainertext, story trainers, meta) sont maintenant traduits. Ils venaient de `Scripts/Rejuv/Definitions/*.rb` et passaient par `pbGetMessageFromHash` ou par le hook `french_battle_messages.rb`, donc pas besoin d'un nouveau patch Ruby : ajouter les entrees a `messages_fr.dat` suffit.
* Fix: le typo "perdue" (au lieu de "perdu") apparaissait 290 fois dans les dialogues (bug residuel du script d'accentuation qui traitait le verbe "perdre" comme un verbe -er). Tout est corrige.
* Types de textes touches : Ace speeches (20), Defeat speeches (238), Field/Boss messages (314), Script texts divers (188).

## v1.0.9 (2026-07-16)

* Fix: **6864 dialogues re-espacés** — la ponctuation `.?!` collée à une majuscule sans espace (par exemple « atterri?À l'intérieur ») a été corrigée dans tous les dialogues. C'était un artefact du pipeline de traduction qui concaténait deux commandes de texte sans conserver l'espace attendu. Le jeu affiche maintenant proprement les blocs de dialogue construits sur plusieurs commandes.

## v1.0.8 (2026-07-16)

* Fix: Mewtwo boss battle messages "Mewtwo is charging its attack...", "Shadow Mewtwo's power grows!" and "Mewtwo's Mega power was exhausted..." are now translated. These are hardcoded in `bosstext*.rb` under `chargingMessage` / `fieldChangeMessage` keys.
* Fix: a new mod script `patch/Mods/french_battle_messages.rb` overrides `setField` and `pbDisplayAutoPaused` to route hardcoded battle messages through `_INTL`, so future untranslated boss break messages (Archetype messages, field change texts) will also pick up their FR variants.

## v1.0.7 (2026-07-16)

* Fix: two variants of the dramatic Nymiera line "Defeat is not an option. Bathe yourself in our light." are now translated. They were skipped by the automated pass because of dense engine formatting codes.

## v1.0.6 (2026-07-16)

* Fix: three more hardcoded quest messages are now translated: "Quest completed!", "Quest failed!", "New task added!". Same mechanism as v1.0.4 (New quest discovered!): the strings are hardcoded in `Scripts/Rejuv/Quest/Quest.rb` and routed through `_INTL`, so adding the FR variants to `messages_fr.dat` is enough.

## v1.0.5 (2026-07-16)

* Fix: boss battle entry messages ("Rift Galvantula attacked!", "Joltik swarm the egg...", "Meowth's long body fills the room!", etc.) are now translated. These were hardcoded in `Scripts/Rejuv/Definitions/bosstext*.rb` and displayed directly, bypassing the engine's `_INTL` mechanism. The mod now ships a small script `patch/Mods/french_bosstext.rb` that overrides `bossEntryText` to route the text through `_INTL`, and 136 boss entry lines are added to `messages_fr.dat`.
* Uses the official French Pokemon terminology for species mentioned in these lines (Galvantula = Mygavolt, Joltik = Statitik, Meowth = Miaouss, Volcanion, Azelf = Crehelf, Musharna = Somniardo, etc.).

## v1.0.4 (2026-07-16)

* Fix: "assise(e)" is now "assis(e)" (bogus participle form fabricated by an earlier pass, "assis" is an irregular past participle).
* Fix: "New quest discovered!" is now translated ("Nouvelle quete decouverte !"). This string is hardcoded in Scripts/Rejuv/Quest/Quest.rb and was never routed through messages.dat; the mod now adds it to ScriptTexts so the engine's _INTL picks it up.
* Fix: gender agreement is now correctly resolved in sentences that mix "Vous" (addressing the player) and "je" (about the speaker). Around 60 such lines were fixed.

## v1.0.3 (2026-07-16)

* Fix: gender agreement resolved for NPC dialogues that had no speaker prefix. Sprite images are now cross referenced with the map data to know each speaker's gender, and the "je suis alle(e)" and "pas sur(e)" patterns are collapsed to the right form (fem or masc) for around 350 previously ambiguous lines.
* The remaining (e) inclusive forms are the ones that address the player (unknown gender), which is intentional.

## v1.0.2 (2026-07-16)

* Fix: participles after auxiliaries etre/avoir get their accent back ("je suis alle" becomes "je suis alle(e)", "j'ai trouve" becomes "j'ai trouve", "je suis devenu" becomes "je suis devenu(e)"). About 570 lines were touched.
* Fix: "bien sur" becomes "bien sur" (adverb), "pas sur" at the end of a sentence becomes "pas sur(e)" (adjective needing agreement).
* Fix: "hesiter" and its variants ("hesite", "hesitons"...) get their accent.

## v1.0.1 (2026-07-16)

* Compatible with Rejuvenation 14.0.2.
* Fix: the Language entry no longer disappears from the main menu after the game reloads its scripts. LANGUAGES is now injected right before the title screen is built.

## v1.0 (2026-07-16)

First public release.

* Target: **Pokémon Rejuvenation 14.0**.
* Coverage: story, Pokédex, moves, items, abilities, UI, battles.
* Official French Pokémon terminology and Rejuvenation canon.
* Fully compliant with the official mod system (patch folder only, no base file overwrite).
