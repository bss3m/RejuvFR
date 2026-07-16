# Glossaire et règles — Traduction FR de Pokémon Rejuvenation

## Mission
Traduire du texte de jeu anglais vers un français naturel et vivant, dans le
style des jeux Pokémon officiels français. Le public connaît Pokémon : la
terminologie officielle française doit être respectée scrupuleusement.

## RÈGLES ABSOLUES (une violation casse le jeu)

1. **Ne jamais modifier les clés JSON** — traduire uniquement les valeurs.
2. **Préserver à l'identique** tous les codes de formatage :
   - `\PN` = nom du joueur (le garder tel quel, place naturelle dans la phrase)
   - `{1}`, `{2}`, `{1:s}`, `{1:3d}`… = variables insérées par le moteur
   - `\c[3]`, `\t`, `\s`, `\v[12]`, `\f`, `\G`, `\w`, `\m`, `\|`, `\.`, `\!`,
     `\^`, `\b`, `\r`, `\l` = codes moteur (couleur, pauses, vitesse…)
   - Balises : `<ac>…</ac>` (centré), `<i>…</i>` (italique), `<o=N>…</o>`,
     `<r>`, `<br>`, `<fs=N>…</fs>`, `<c2=…>`, `<icon=…>`
   - Le caractère U+0001 (`` en JSON) = saut de page de dialogue.
   - Les `\n` (sauts de ligne) : en conserver la logique (le moteur re-coupe
     les lignes, mais garder un `\n` là où il y en a un est plus sûr).
3. **Caractères interdits** (absents des polices du jeu) :
   - `œ Œ` → écrire `oe / Oe` (ex. « coeur », « voeu », « oeuf »)
   - `…` → `...`   |   `’` → `'`   |   `– —` → `-`
4. La sortie doit être un JSON valide, mêmes clés que l'entrée, uniquement
   les valeurs traduites.

## Terminologie officielle Pokémon (obligatoire)

Le fichier `glossaire_noms.json` contient la table EN→FR complète et
officielle des espèces, attaques, objets, talents et types. **Toute mention
d'un de ces noms dans un dialogue doit utiliser la version française de cette
table.** (ex. « Tackle » → « Charge », « Thunder Stone » → « Pierre Foudre »,
« Squirtle » → « Carapuce »).

Termes récurrents :
- Trainer → Dresseur / Dresseuse ; Gym Leader → Champion(ne) d'Arène
- Gym → Arène ; Badge → Badge ; Elite Four → Conseil 4 ; League → Ligue
- Pokémon Center → Centre Pokémon ; Poké Mart → Boutique Pokémon
- Nurse → Infirmière ; PC/Storage → PC / Système de Stockage
- Move → capacité (ou attaque) ; Ability → talent ; Item → objet
- Nature → nature ; IVs/EVs → IV/EV ; Shiny → chromatique
- HP → PV ; Level/Lv. → Niveau/N. ; Exp. → Exp.
- Egg → Oeuf (pas Œuf !) ; hatch → éclore
- Wild Pokémon → Pokémon sauvage ; faint → mettre K.O. / être K.O.
- Battle → combat ; Double Battle → combat duo
- Region → région ; Route 1 → Route 1
- Pokédex → Pokédex ; Trainer Card → Carte Dresseur

## Univers Rejuvenation (canon de cette traduction)

- **Ne pas traduire les noms propres** : Melia, Venam, Aelita, Ren, Amber,
  Erin, Alice, Allen, Narcissa, Crescent, Cera, Kanon, Nim, Saki, Adam,
  Valarie, Tesla, Texen, Huey, Zetta, Geara, Neved, Madelis, Madame X,
  Indriad, Anathea, Vivian, Maman, Spacea, Tiempa, Souta, Karrina, Keta,
  Taelia, Risa, Braixen (si nom d'espèce → FR), etc.
  Les préfixes de dialogue type `MELIA:` restent tels quels (majuscules,
  deux-points conservés).
- **Rift** → « la Faille » ; Rift Pokémon → « Pokémon de la Faille » ;
  les attaques/objets Rift utilisent « de Faille » (cf. glossaire_noms.json).
- **Interceptor** → « l'Intercepteur » ; **Team Xen** → « la Team Xen » ;
  **Xen** reste « Xen ».
- Région : **Aevium** (invariable). Villes/lieux : utiliser exactement les
  noms du glossaire_noms.json (section lieux) — ex. « Gearen City » →
  « Gearen », « Goldenwood Forest » → « Forêt de Goldenwood ».
- GDC / Grand Dream City → « Grand Dream City » (GDC conservé).

## Style

- Les personnages se **tutoient** entre amis/rivaux ; les adultes inconnus,
  commerçants et figures d'autorité **vouvoient** le joueur (et
  réciproquement, le joueur vouvoie les inconnus adultes).
- **Genre du joueur inconnu** : le héros peut être fille ou garçon. Préférer
  des tournures épicènes (« Te voilà enfin ! » plutôt que « Tu es arrivé ! »).
  En dernier recours : « prêt(e) ».
- Messages de combat : style officiel — « {1} utilise {2} ! »,
  « C'est super efficace ! », « Ce n'est pas très efficace... »,
  « {1} ennemi » pour "Foe {1}" / "The opposing {1}".
- Ponctuation française : espace avant `!` `?` `:` (ex. « Attention ! »).
  Guillemets droits `"` conservés (pas de « » pour rester sobre en largeur).
- Ton : naturel, oral pour les dialogues (contractions : « j'suis », « t'as »
  pour les personnages familiers comme Venam), soutenu pour les personnages
  formels. Garder l'humour et les jeux de mots (adapter, ne pas traduire
  littéralement).
- Longueur : rester proche de la longueur d'origine (les boîtes de dialogue
  re-coupent automatiquement, mais les textes d'interface courts — menus,
  boutons — ne doivent pas déborder : viser ≤ +20 %).
