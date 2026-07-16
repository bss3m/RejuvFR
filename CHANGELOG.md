# Changelog

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
