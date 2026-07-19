# Changelog

## v1.1.6 (2026-07-19)

* **Descriptions officielles Poképédia** pour les 18 Joyaux de type (Feu, Eau, Électrik, Plante, Glace, Combat, Poison, Sol, Vol, Psy, Insecte, Roche, Spectre, Dragon, Ténèbres, Acier, Normal, Fée) : « Objet à tenir. Joyau augmentant une fois la puissance des capacités de type X. » (~80 caractères, canon FR).
* **Feuille Copieuse** (Mirror Herb) : description officielle Poképédia.
* **Fix : la fenêtre CMD ne s'affiche plus** pendant l'installation de la mise à jour. L'updater passe désormais par un wrapper VBScript (`.rejuvfr_apply.vbs`) qui invoque le `.bat` via `WScript.Shell.Run(cmd, 0, false)` — le processus tourne en arrière-plan totalement invisible. Compatible Windows XP à Windows 11.

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
