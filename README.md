# RejuvFR

Traduction française non-officielle de **Pokémon Rejuvenation 14.0.6**.

## Téléchargement

Dernière version : [**RejuvFR_v1.1.14.zip**](https://github.com/bss3m/RejuvFR/releases/latest) (~6 Mo)

## Installation

1. Télécharge le zip depuis la [page des releases](https://github.com/bss3m/RejuvFR/releases/latest).
2. Extrais-le à la racine du dossier de jeu (celui qui contient `Rejuvenation.exe`). Le dossier `patch/` du zip fusionne avec le dossier `patch/` existant du jeu.
3. Lance `Rejuvenation.exe`. Une entrée **Language** apparaît dans le menu principal. Choisis **Français**.
4. Choisis le genre de ton personnage (masculin ou féminin). Ce choix est mémorisé pour les prochains lancements et sert à résoudre les accords dans les dialogues.

Tu peux revenir à l'anglais à tout moment depuis le même menu. Les sauvegardes ne sont pas affectées.

## Contenu traduit

Scénario, Pokédex, attaques, objets, talents, interface, combats. Terminologie officielle française des Pokémon et canon Rejuvenation.

## Mise à jour automatique

Le mod vérifie discrètement si une nouvelle version est disponible au chargement d'une partie. Si c'est le cas, il propose de la télécharger et de l'installer directement depuis le jeu, puis relance automatiquement.

## Compatibilité

* Testé sur **Rejuvenation 14.0.6 (Windows)**.
* Compatible **JoiPlay et Kirin** (Android). L'auto-updater est désactivé sur ces environnements, les mises à jour doivent être installées manuellement.
* Incompatible avec 13.5 (format interne différent).
* Entièrement conforme au système de mods officiel décrit dans `Modding.txt` et `Scripts/.translation.txt` du jeu : aucun fichier de base n'est modifié. Tout est dans `patch/`.
* Les sauvegardes ne sont pas affectées.

## Contenu du zip

Le zip contient un dossier `patch/` avec :

```
patch/
├── messages_fr.dat                  (~16 Mo, table de messages française)
├── Init/
│   ├── french_translation.rb        (ajoute "Français" à LANGUAGES)
│   └── french_updater.rb            (vérifie GitHub pour les nouvelles versions)
└── Mods/
    ├── french_bosstext.rb           (traduit les phrases hardcodées des boss)
    ├── french_battle_messages.rb    (traduit les messages de champ de combat)
    └── french_gender.rb             (choix du genre + accords automatiques)
```

## Désinstallation

Supprime le fichier `patch/messages_fr.dat`, les scripts `Init/french_*.rb` et les scripts `Mods/french_*.rb`. Rien d'autre n'a été modifié.

## Remerciements

Merci aux personnes qui ont contribué en signalant des erreurs, en proposant des corrections ou en fournissant du contenu :

* **Lavril** — retours détaillés sur de nombreuses lignes de dialogue, ponctuation, et cas de genre non résolus.
* **Tench** — signalement des descriptions d'items trop longues qui débordaient de la boîte d'affichage.
* **Justyne88** — traduction des images du jeu (à intégrer dans une prochaine version).

Tu veux apparaître ici ? Ouvre une issue ou une PR sur ce dépôt.

## Crédits

* Terminologie française officielle des Pokémon issue du wiki officiel FR.
* Canon Rejuvenation (noms de lieux, objets personnalisés, terminologie scénario) organisé manuellement.
* Grand merci à **Jan** et à toute l'équipe Rejuvenation pour ce jeu exceptionnel.

## Licence

Utilisation libre pour un usage personnel non commercial. Merci de ne pas revendre. Respectez le travail de Jan et de l'équipe Rejuvenation.

## Contribuer

Les sources de traduction sont dans `src/fr/` (un JSON par carte, plus un JSON par section du jeu). N'importe qui peut fork le dépôt, corriger une ligne, ouvrir une pull request. Les règles sont dans [CONTRIBUTING.md](CONTRIBUTING.md) (pas de modification de clés, préserver les codes du moteur, caractères interdits, etc.).

## Retours et bugs

Ouvre une issue sur ce dépôt.

---

## English

Unofficial French translation mod for **Pokémon Rejuvenation 14.0.6**.

Download the latest zip from the [Releases page](https://github.com/bss3m/RejuvFR/releases/latest), extract at the root of your game folder (the one with `Rejuvenation.exe`), launch the game and pick **Français** in the main menu, then select your character's gender. Save files are unaffected. Fully compliant with the official modding system (nothing overwrites base game files). The mod also ships an in-game auto-updater that pulls new releases from this repository. See [CONTRIBUTING.md](CONTRIBUTING.md) for translation contribution rules.
