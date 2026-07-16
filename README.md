# RejuvFR

French translation mod for **Pokémon Rejuvenation 14.0**.

Traduction française pour **Pokémon Rejuvenation 14.0**.

## Download

Latest release: [**RejuvenationFR-1.0.zip**](https://github.com/bss3m/RejuvFR/releases/latest) (6 MB)

## Installation

1. Download the zip from the [Releases page](https://github.com/bss3m/RejuvFR/releases/latest).
2. Extract it at the root of your game folder (the one containing `Rejuvenation.exe`). The `patch` folder from the zip merges with the existing `patch` folder of the game.
3. Launch `Rejuvenation.exe`. A **Language** entry appears in the main menu. Pick **Français**.

You can switch back to English at any time from the same menu. Saves are not affected.

## Coverage

Story, Pokédex, moves, items, abilities, UI, battles. Official French Pokémon terminology and Rejuvenation canon.

## Compatibility

* Tested on **Rejuvenation 14.0 (Windows)** only.
* Not compatible with 13.5 (different internal format).
* Fully compliant with the official modding system described in the game's `Modding.txt` and `Scripts/.translation.txt`: no base game file is modified. Everything lives in `patch/`.
* Save files are unaffected.

## What is included

The zip contains only two files, both inside a `patch/` folder:

```
patch/
├── messages_fr.dat            (~16 MB uncompressed, French message table)
└── Init/
    └── french_translation.rb  (adds "Français" to the LANGUAGES hash)
```

## Uninstalling

Delete `patch/messages_fr.dat` and `patch/Init/french_translation.rb`. Nothing else was touched.

## Credits

* Official French Pokémon terminology sourced from PokéAPI.
* Rejuvenation canon (place names, custom items, story terminology) manually curated.
* Big thanks to **Jan** and the whole Rejuvenation team for this outstanding fan game.

## License

Free for personal, non commercial use. Please do not resell. Respect the work of Jan and the Rejuvenation team.

## Feedback

Open an issue on this repository.
