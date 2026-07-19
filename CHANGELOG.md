# Changelog

## v1.1.0 (2026-07-19)

Cible : **Rejuvenation 14.0.6**.

### Nouveautes / New features

* **Selection du genre du personnage** au moment de choisir "Francais". Le choix (masculin / feminin) est sauvegarde dans `Saved Games/Rejuv/french_gender.dat` et persiste entre redemarrages. Les 2849 marqueurs d'accord `(e)`, `(euse)`, `(trice)`, `(elle)`, `(ere)`... sont resolus automatiquement dans tous les dialogues qui s'adressent au joueur.
* **Mise a jour in-game** : au chargement d'une partie, le mod verifie s'il existe une nouvelle version sur GitHub Releases. Si oui, il propose de la telecharger et de l'installer directement (comme le fait le systeme officiel Updater de Rejuvenation), puis relance le jeu.

### Corrections critiques

* **Mots de passe story preserves en anglais**. `PASSWORD: UNBOUND` et `PASSWORD: SOUL` avaient ete traduits (`DECHAINE` / `AME`), rendant les enigmes impossibles a resoudre. Les mots de passe cheat de `passwordtext.rb` (mintyfresh, casspack, easymode, etc.) sont egalement verifies.
* **La langue francaise est desormais conservee au redemarrage**. Avant, `pbLoadLanguage` etait appele au boot avec `LANGUAGES = {}`, ce qui reinitialisait le jeu en anglais. Un hook sur `pbLoadLanguage` reinjecte la constante avant chaque resolution.

### Fixes

* **1188 nouvelles traductions** injectees pour la mise a jour 14.0.6 (680 noms de dresseurs, 333 noms Battle Tower, ~175 dialogues et scripts).
* **Timburr = Charpenti** (etait errone en "Trompignon", qui est Foongus).
* **Jeu de mot "Sea you"** refait proprement en francais : `On se voit MERcredi. Tu piges ? MER - credi`.
* **Allongement moqueur "a litttleeee paranoid"** rendu en `un touuut ptiiit peu parano` (etait `uuuun tiiiiout peu parano`, cassait la moquerie).
* **7 residus "PERDUe"** (majuscules) fixes en "PERDU".
* **155 occurrences de "POKeMON"** corrigees en "POKEMON".
* **"sur(e) scene"** -> **"sur scene"** (Alexandra, Map638).
* **Idiomes "on fire"** re-traduits en francais familier : 10 lignes, "je vois que t'es chaud", "T'es chaud !", etc.
* **"practice round"** -> "echauffement" (etait "juste un repetition").
* **Erreurs de traduction diverses** ("coupable" -> "coupe" pour l'arbre a couper, etc.).
* **`_MAPINTL` hook** ajoute pour couvrir les dialogues d'events RPG Maker XP (qui ne passaient pas par le hook `_INTL`).
* **`french_battle_messages.rb` etendu** : fallback vers `:FieldMessages`, `:AceSpeech`, `:EndSpeechLose` en plus de `:ScriptTexts` pour recuperer les traductions stockees dans le mauvais bucket.

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
