# Contribuer à la traduction

Merci de vouloir aider !

## Comment proposer une correction

1. **Fork** ce dépôt.
2. Trouve la ligne fautive :
   * Pour un dialogue de carte : `src/fr/maps/MapNNN.json`
   * Pour un texte système, une description, etc. : `src/fr/sections/NomDeSection.json`
3. Modifie **uniquement la valeur** (jamais la clé).
4. Commit + push + Pull Request.

Une fois la PR fusionnée, une nouvelle release sera générée.

## Règles

* **Ne pas modifier les clés JSON**. Les clés sont le texte anglais utilisé par le moteur du jeu comme identifiant. Si tu changes une clé, le jeu ne trouvera plus la traduction.
* **Préserver à l'identique tous les codes de formatage** : `\PN` (nom du joueur), `{1}`, `{2}` (variables), `\c[N]`, `\v[N]`, `\|`, `\.`, `\!`, `\^`, `\wt[N]`, `\m`, `\n`, `\r`, le caractère U+0001, et les balises HTML comme `<ac>...</ac>`, `<i>...</i>`, `<c2=...>`, `<icon=...>`. En nombre et à l'identique dans la traduction.
* **Ne jamais introduire les caractères suivants** (absents des polices Pokémon du jeu, ils s'affichent comme des carrés) :
  * `œ` (ligature oe) et `Œ`
  * `…` (points de suspension typographiques, utiliser `...`)
  * `'` (apostrophe courbe, utiliser `'`)
  * `—` (tiret cadratin) et `–` (tiret demi-cadratin) : à remplacer par `...` ou virgules
  * `«` et `»` : utiliser les guillemets droits `"`
  * Espace insécable : utiliser une espace normale
* **Terminologie officielle** : les noms d'espèces, attaques, objets, talents, types suivent la terminologie officielle FR. Voir `src/glossaire_noms.json` pour la table complète.
* **Canon Rejuvenation** : Rift = Faille, Interceptor = Intercepteur, Team Xen invariant, Aevium invariant, GDC invariant, personnages nommés (Melia, Aelita, Ren, Venam...) invariants.
* **Style** : ton du personnage respecté (voir `src/glossaire.md` pour les indications). Tutoiement entre amis / rivaux / jeunes. Vouvoiement des inconnus adultes.
* **Accords de genre** : pour les dialogues qui s'adressent au joueur, utilise les marqueurs `(e)`, `(euse)`, `(trice)`, `(elle)`, `(ère)`, etc. Ils sont résolus automatiquement selon le genre choisi au démarrage. Exemples : `prêt(e)`, `un(e) Dresseur(euse)`, `nouveau(elle)`.

## Comment le mod est construit

Le contenu de `src/fr/` est compilé en un fichier binaire `messages_fr.dat` placé dans `patch/` à chaque release. Le fichier `patch/Init/french_translation.rb` déclare "Français" comme langue sélectionnable dans le menu du jeu.

## Signaler un problème sans coder

Ouvre une issue avec :
* La version de RejuvFR (visible dans le CHANGELOG).
* Le texte anglais original si tu le connais.
* La traduction actuelle.
* Ce qu'elle devrait dire selon toi.
* Éventuellement une capture d'écran.

## English

Fork this repo, edit the offending line in `src/fr/`, commit + push + PR.
Only change **values**, never keys. Once merged, a new release is built.

See rules above for formatting codes to preserve, banned characters, and terminology guidelines. Report issues with: RejuvFR version, original English text, current translation, expected translation.
