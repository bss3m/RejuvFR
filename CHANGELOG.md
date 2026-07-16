# Changelog

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
