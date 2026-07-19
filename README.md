# RejuvFR

French translation mod for **Pokémon Rejuvenation 14.0.6**.

Traduction française pour **Pokémon Rejuvenation 14.0.6**.

## Download

Latest release: [**RejuvFR_v1.1.0.zip**](https://github.com/bss3m/RejuvFR/releases/latest) (~6 MB)

## Installation

1. Download the zip from the [Releases page](https://github.com/bss3m/RejuvFR/releases/latest).
2. Extract it at the root of your game folder (the one containing `Rejuvenation.exe`). The `patch` folder from the zip merges with the existing `patch` folder of the game.
3. Launch `Rejuvenation.exe`. A **Language** entry appears in the main menu. Pick **Français**.

You can switch back to English at any time from the same menu. Saves are not affected.

## Coverage

Story, Pokédex, moves, items, abilities, UI, battles. Official French Pokémon terminology and Rejuvenation canon.

## Compatibility

* Tested on **Rejuvenation 14.0.6 (Windows)**.
* Not compatible with 13.5 (different internal format).
* Fully compliant with the official modding system described in the game's `Modding.txt` and `Scripts/.translation.txt`: no base game file is modified. Everything lives in `patch/`.
* Save files are unaffected.

## What is included

The zip contains a `patch/` folder with:

```
patch/
├── messages_fr.dat                  (~16 MB, French message table)
├── Init/
│   ├── french_translation.rb        (adds "Français" to LANGUAGES)
│   └── french_updater.rb            (checks GitHub for new versions)
└── Mods/
    ├── french_bosstext.rb           (translates hardcoded boss lines)
    ├── french_battle_messages.rb    (translates battle field messages)
    └── french_gender.rb             (character gender selection + agreement in dialogues)
```

## Uninstalling

Delete the `patch/messages_fr.dat` file, the `Init/french_*.rb` scripts and the `Mods/french_*.rb` scripts. Nothing else was touched.

## Remerciements / Acknowledgements

Merci aux personnes qui ont contribué en signalant des erreurs, en proposant des corrections ou en fournissant du contenu :

* **Lavril** — retours détaillés sur de nombreuses lignes de dialogue, ponctuation, et cas de genre non résolus.

Vous voulez apparaître ici ? Ouvrez une issue ou une PR sur ce dépôt.

## Credits

* Official French Pokémon terminology sourced from the official Pokémon FR wiki.
* Rejuvenation canon (place names, custom items, story terminology) manually curated.
* Big thanks to **Jan** and the whole Rejuvenation team for this outstanding fan game.

## License

Free for personal, non commercial use. Please do not resell. Respect the work of Jan and the Rejuvenation team.

## Contributing

The translation sources live in `src/fr/` (one JSON per map, plus one JSON per game section). Anyone can fork the repo, fix a line, open a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for the rules (no key changes, preserve engine codes, banned characters, etc.).

Les sources de traduction sont dans `src/fr/`. N'importe qui peut fork le depot, corriger une ligne, ouvrir une pull request. Regles dans [CONTRIBUTING.md](CONTRIBUTING.md).

## Feedback

Open an issue on this repository. / Ouvre une issue sur ce depot.
