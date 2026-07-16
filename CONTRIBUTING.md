# Contribuer a la traduction / Contributing

Merci de vouloir aider ! / Thanks for helping!

## Comment proposer une correction / How to submit a fix

1. **Fork** ce depot.
2. Trouve la ligne fautive :
   * Pour un dialogue de carte : `src/fr/maps/MapNNN.json`
   * Pour un texte systeme, description, etc. : `src/fr/sections/NomDeSection.json`
3. Modifie **uniquement la valeur** (jamais la cle).
4. Commit + push + Pull Request.

Une fois la PR fusionnee, une nouvelle release sera generee.

Fork this repo, edit the offending line in `src/fr/`, commit + push + PR.
Only change **values**, never keys. Once merged, a new release is built.

## Regles / Rules

* **Ne pas modifier les cles JSON**. Les cles sont le texte anglais utilise par le moteur du jeu comme identifiant. Si tu changes une cle, le jeu ne trouvera plus la traduction.
* **Preserver a l'identique tous les codes de formatage** : `\PN` (nom du joueur), `{1}`, `{2}` (variables), `\c[N]`, `\v[N]`, `\|`, `\.`, `\!`, `\^`, `\wt[N]`, `\m`, `\n`, `\r`, le caractere U+0001, et les balises HTML comme `<ac>...</ac>`, `<i>...</i>`, `<c2=...>`, `<icon=...>`. En nombre et a l'identique dans la traduction.
* **Ne jamais introduire les caracteres suivants** (absents des polices Pokemon du jeu, ils s'affichent comme des carres) :
  * `oe` au lieu de la ligature oe
  * `Oe` au lieu de la ligature Oe majuscule
  * `...` au lieu du signe de suite trois points typographique
  * apostrophe droite `'` au lieu de l'apostrophe courbe
  * `-` au lieu du tiret cadratin et demi-cadratin
  * guillemets droits `"` au lieu des chevrons francais
  * espace normale au lieu de l'espace insecable
* **Terminologie officielle** : les noms d'especes, attaques, objets, talents, types suivent la terminologie officielle FR. Voir `src/glossaire_noms.json` pour la table complete.
* **Canon Rejuvenation** : Rift = Faille, Interceptor = Intercepteur, Team Xen invariant, Aevium invariant, GDC invariant, personnages nommes (Melia, Aelita, Ren, Venam...) invariants.
* **Style** : ton du personnage respecte (voir `src/glossaire.md` pour les indications). Tutoiement entre amis/rivaux/jeunes. Vouvoiement des inconnus adultes. Genre du joueur reste inclusif ou epicene.

## Comment le mod est construit / How the mod is built

Le contenu de `src/fr/` est compile en un fichier binaire `messages_fr.dat` place dans `patch/` a chaque release. Le fichier `patch/Init/french_translation.rb` declare Francais comme langue selectionnable dans le menu du jeu.

The `src/fr/` content is compiled into a binary `messages_fr.dat` shipped inside `patch/` for each release. `patch/Init/french_translation.rb` registers French as a selectable language.

## Signaler un probleme sans coder / Report without coding

Ouvre une issue avec :
* La version de RejuvFR (visible dans le CHANGELOG).
* Le texte anglais original si tu le connais.
* La traduction actuelle.
* Ce qu'elle devrait dire selon toi.

Open an issue with: RejuvFR version, original English text if known, current translation, expected translation.
