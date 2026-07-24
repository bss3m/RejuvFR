# Selection du genre pour la traduction FR.
#
# Quand l'utilisateur choisit "Francais" dans le menu Langue, un second menu
# M/F apparait. Le choix est stocke dans un fichier separe french_gender.dat
# dans le dossier de save et persiste entre les redemarrages.
#
# Expose $genre_fr = :M ou :F pour la resolution des accords (e) dans
# les dialogues qui s'adressent au joueur.

FR_GENDER_FILE = "french_gender.dat" unless defined?(FR_GENDER_FILE)

def rejuvfr_gender_path
  RTP.getSaveFileName(FR_GENDER_FILE)
rescue
  nil
end

def rejuvfr_load_gender
  path = rejuvfr_gender_path
  return nil unless path && File.exist?(path)
  data = File.read(path).strip
  case data
  when "M", "F" then data.to_sym
  else nil
  end
rescue
  nil
end

def rejuvfr_save_gender(sym)
  path = rejuvfr_gender_path
  return unless path
  File.write(path, sym.to_s)
rescue
end

def rejuvfr_prompt_gender
  # Message affiche en dur en FR : _INTL ne serait pas encore disponible
  # lors du tout premier choix, avant pbLoadLanguage.
  current = $genre_fr
  if current
    label = current == :F ? "féminin" : "masculin"
    msg = "Traduction française activée.\nActuellement en #{label}.\nQuel est le genre de ton personnage ?"
  else
    msg = "Bienvenue dans la traduction française !\nQuel est le genre de ton personnage ?"
  end
  default = current == :F ? 1 : 0
  # pbMessage signature : (message, commands, cmdIfCancel, skin, defaultCmd)
  # cmdIfCancel = -1 pour detecter B-press / cancel et ne PAS ecraser la
  # preference existante (bug : sans ca, un cancel silencieux basculait
  # les joueurs Feminin vers Masculin).
  choice = Kernel.pbMessage(msg, ["Masculin", "Féminin"], -1, nil, default)
  return if choice < 0  # cancel : preserve current
  sym = choice == 1 ? :F : :M
  rejuvfr_save_gender(sym)
  $genre_fr = sym
end

# Charger le genre existant au demarrage.
$genre_fr = rejuvfr_load_gender

# Liste blanche des suffixes que l'on considere comme des marqueurs de genre.
# On evite ainsi de manger des balises fonctionnelles comme (SOIN), (Nord),
# (Kakori), (COPY), (PgUp)... ou des choix d'options entre parentheses.
#
# NOTE : le 's' bare a ete RETIRE. En francais '(s)' est utilise comme
# marqueur de pluriel optionnel ('cran(s)', 'point(s)', 'seconde(s)').
# S'il etait dans la whitelist, un joueur Masculin verrait '(s)' supprime
# et donc du singulier casse partout.
unless defined?(GENDER_SUFFIXES)
  GENDER_SUFFIXES = %w[
    e se ne le ve te
    nne lle tte ère ète ïne
    euse rice trice ière elle
  ].freeze
end
GENDER_MARKER_RE = /\(([a-zà-ÿA-ZÀ-Ÿ]{1,6})\)/ unless defined?(GENDER_MARKER_RE)

# Alternation mot-plein pour les cas ou le suffixe seul ne suffit pas
# (nouveau/nouvelle, vieil/vieille, dresseur/dresseuse, celui/celle...).
# Syntaxe : {M:masc|F:fem} -> resolu vers 'masc' ou 'fem' selon le joueur.
# Compatible avec les balises normales : {M:il|F:elle} etc.
FULL_ALT_RE = /\{M:([^|}]*)\|F:([^}]*)\}/ unless defined?(FULL_ALT_RE)

def rejuvfr_apply_gender(text)
  return text unless text.is_a?(String)
  # Pas de resolution si aucun marqueur present -> early return pour perf
  return text unless text.include?("(") || text.include?("{M:")
  case $genre_fr
  when :F
    text = text.gsub(FULL_ALT_RE, '\2')
    text.gsub(GENDER_MARKER_RE) do |m|
      suf = $1
      GENDER_SUFFIXES.include?(suf.downcase) ? suf : m
    end
  when :M, nil
    text = text.gsub(FULL_ALT_RE, '\1')
    text.gsub(GENDER_MARKER_RE) do |m|
      GENDER_SUFFIXES.include?($1.downcase) ? "" : m
    end
  else
    text
  end
end

# Hook sur _INTL et _MAPINTL : applique la resolution genre sur tout le texte
# final. _MAPINTL est utilise pour tous les dialogues d'events RPG Maker XP
# (donc la grande majorite des textes affiches en jeu).
Thread.new do
  60.times do
    break if defined?(_INTL) && defined?(_MAPINTL)
    sleep 0.1
  end
  s = $VERBOSE
  $VERBOSE = nil
  Object.class_eval do
    unless private_method_defined?(:_orig_INTL_fr_gender) || method_defined?(:_orig_INTL_fr_gender)
      alias_method :_orig_INTL_fr_gender, :_INTL
      define_method(:_INTL) do |*args|
        rejuvfr_apply_gender(_orig_INTL_fr_gender(*args))
      end
    end
    unless private_method_defined?(:_orig_MAPINTL_fr_gender) || method_defined?(:_orig_MAPINTL_fr_gender)
      alias_method :_orig_MAPINTL_fr_gender, :_MAPINTL
      define_method(:_MAPINTL) do |*args|
        rejuvfr_apply_gender(_orig_MAPINTL_fr_gender(*args))
      end
    end
  end
  $VERBOSE = s
end

# Hook sur pbChooseLanguage : apres selection, si Francais, prompt M/F.
Thread.new do
  60.times do
    break if defined?(pbChooseLanguage)
    sleep 0.1
  end
  next unless defined?(pbChooseLanguage)
  s = $VERBOSE
  $VERBOSE = nil
  Object.class_eval do
    unless private_method_defined?(:_orig_pbChooseLanguage_fr) || method_defined?(:_orig_pbChooseLanguage_fr)
      alias_method :_orig_pbChooseLanguage_fr, :pbChooseLanguage
      define_method(:pbChooseLanguage) do
        idx = _orig_pbChooseLanguage_fr
        begin
          langname = LANGUAGES.keys[idx]
          if langname && langname.downcase.start_with?("franc")
            rejuvfr_prompt_gender
          end
        rescue
        end
        idx
      end
    end
  end
  $VERBOSE = s
end

# Boot-time prompt : si FR est deja selectionne mais aucune preference genre
# n'existe encore (nouvelle install, upgrade depuis version pre-genre), on
# affiche le prompt une seule fois au 1er rendu du menu titre. Sinon le
# joueur Feminin joue toute la partie en Masculin sans indication qu'un
# toggle existe.

Thread.new do
  # Attente que LANGUAGES + $Settings + pbMessage soient prets
  120.times do
    ready = defined?(LANGUAGES) && LANGUAGES.is_a?(Hash) && !LANGUAGES.empty? &&
            defined?($Settings) && $Settings &&
            $Settings.respond_to?(:language) &&
            Kernel.respond_to?(:pbMessage)
    break if ready
    sleep 0.1
  end
  begin
    return unless defined?(LANGUAGES) && LANGUAGES.is_a?(Hash) &&
                  defined?($Settings) && $Settings && $Settings.respond_to?(:language)
    langname = LANGUAGES.keys[$Settings.language]
    if langname && langname.to_s.downcase.start_with?("franc") && $genre_fr.nil?
      # Delai supplementaire pour laisser Graphics/Scene demarrer
      sleep 1.5
      rejuvfr_prompt_gender rescue nil
    end
  rescue
    # silent : mieux vaut pas de prompt qu'un crash au boot
  end
end
