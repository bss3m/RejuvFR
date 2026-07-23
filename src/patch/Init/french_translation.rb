# =============================================================================
# Traduction francaise non-officielle de Pokemon Rejuvenation 14.0
# =============================================================================
# Note technique : Rejuvenation charge Scripts/Rejuv/Settings.rb DEUX fois
# (une fois dans INIT, une fois dans SCRIPTS). Definir LANGUAGES directement
# au chargement de ce script (comme documente dans .translation.txt) ne
# suffit donc pas : le second chargement de Settings.rb reinitialise
# LANGUAGES a {} apres notre code.
#
# On installe deux hooks :
# 1. pbLoadLanguage : recharge LANGUAGES avant que le systeme ne resolve
#    $Settings.language (appele au boot). Corrige la perte de langue apres
#    un redemarrage : sans ce hook, LANGUAGES est encore {} lors du premier
#    pbLoadLanguage et le FR n'est pas applique.
# 2. PokemonLoad#pbStartLoadScreen : sur le second chargement de Settings.rb,
#    LANGUAGES est ecrase - on le remet en place juste avant la construction
#    du menu principal.
# =============================================================================

# Guard contre redefinition (constant warning si reload)
unless defined?(FR_LANGUAGES)
  FR_LANGUAGES = {
    "English"  => nil,
    "Francais" => "patch/messages_fr.dat",
  }.freeze
end

def rejuvfr_inject_languages
  return if Object.const_defined?(:LANGUAGES) && LANGUAGES == FR_LANGUAGES
  s = $VERBOSE
  $VERBOSE = nil
  Object.send(:remove_const, :LANGUAGES) if Object.const_defined?(:LANGUAGES)
  Object.const_set(:LANGUAGES, FR_LANGUAGES.dup)
  $VERBOSE = s
end

# Injection immediate. Si Settings.rb est charge ensuite, il ecrasera, mais
# les hooks ci-dessous reinjecteront avant chaque point critique.
rejuvfr_inject_languages

# Hook 1 : pbLoadLanguage (appele au boot depuis pbSetUpSystem, ET quand on
# change de langue depuis le menu). On reinjecte LANGUAGES avant l'appel
# original afin que $Settings.language (deja sauvegarde) soit resolu contre
# notre hash FR.
Thread.new do
  60.times do
    break if defined?(pbLoadLanguage)
    sleep 0.1
  end
  next unless defined?(pbLoadLanguage)
  s = $VERBOSE
  $VERBOSE = nil
  Object.class_eval do
    unless private_method_defined?(:_orig_pbLoadLanguage_fr) || method_defined?(:_orig_pbLoadLanguage_fr)
      alias_method :_orig_pbLoadLanguage_fr, :pbLoadLanguage
      define_method(:pbLoadLanguage) do
        rejuvfr_inject_languages
        _orig_pbLoadLanguage_fr
      end
    end
  end
  $VERBOSE = s

  # Si pbLoadLanguage a deja ete appele avant que notre hook soit installe
  # (typique du 1er boot ou Settings.rb est reload apres notre injection),
  # on force un rechargement des messages FR maintenant.
  begin
    rejuvfr_inject_languages
    pbLoadLanguage if defined?($Settings) && $Settings && $Settings.language
  rescue
    # Silencieux : si $Settings pas encore construit, le hook s'appliquera
    # au prochain appel de pbLoadLanguage lui-meme.
  end
end

# Hook 2 : pbStartLoadScreen (juste avant l'affichage du menu principal).
# Filet de securite au cas ou Settings.rb aurait re-ecrase LANGUAGES apres
# le premier hook.
Thread.new do
  60.times do
    # instance_methods(true) inclut les methodes heritees d'une superclasse
    # (sinon pbStartLoadScreen defini plus haut dans la hierarchie serait rate)
    break if defined?(PokemonLoad) && PokemonLoad.instance_methods.include?(:pbStartLoadScreen)
    sleep 0.1
  end
  next unless defined?(PokemonLoad) && PokemonLoad.instance_methods.include?(:pbStartLoadScreen)
  s = $VERBOSE
  $VERBOSE = nil
  PokemonLoad.class_eval do
    unless instance_methods(false).include?(:_original_pbStartLoadScreen_fr)
      alias_method :_original_pbStartLoadScreen_fr, :pbStartLoadScreen
      define_method(:pbStartLoadScreen) do
        rejuvfr_inject_languages
        _original_pbStartLoadScreen_fr
      end
    end
  end
  $VERBOSE = s
end
