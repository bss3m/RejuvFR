# RejuvFR v1.0.1

Fix pour la mise a jour Rejuvenation 14.0.2. Fix for the Rejuvenation 14.0.2 update.

## Ce qui change / What changed

Le patch 14.0.2 a modifie l'ordre de chargement des scripts, ce qui faisait disparaitre l'entree Language du menu principal. Cette version reinjecte LANGUAGES juste avant la construction de l'ecran-titre.

The 14.0.2 patch changed the script loading order, which caused the Language entry to disappear from the main menu. This version reinjects LANGUAGES right before the title screen is built.

## Installation

1. Telecharger `RejuvenationFR-1.0.1.zip` ci dessous.
2. L'extraire a la racine du dossier du jeu.
3. Lancer `Rejuvenation.exe` puis choisir Language puis Francais dans le menu principal.

1. Download `RejuvenationFR-1.0.1.zip` below.
2. Extract at the root of your game folder.
3. Launch `Rejuvenation.exe` then pick Language then Francais in the main menu.

Si vous avez la v1.0, supprimez son `patch/Init/french_translation.rb` avant d'extraire, ou laissez le zip ecraser les fichiers.

If you have v1.0 installed, delete its `patch/Init/french_translation.rb` before extracting, or let the zip overwrite the files.
