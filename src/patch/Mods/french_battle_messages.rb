# Route certains messages de combat hardcodes via _INTL pour recuperer la
# traduction FR stockee dans messages_fr.dat.
#
# Concerne :
# - fieldChangeMessage / overlayMessage : passes en dur a setField (Battle_Field.rb)
# - ArchetypeMessage : affiches via pbDisplayAutoPaused sans _INTL
# - trainereffect[:message] (bosstext/trainertext) : affiches via pbDisplayAutoPaused
# - pbDisplayTrainerMessage : substitue \PN AVANT l'appel, donc doit etre
#   traduit sur le template brut (avant substitution)
#
# _INTL cherche uniquement dans :ScriptTexts, mais beaucoup de messages sont stockes
# dans :FieldMessages. On ajoute donc un fallback : si _INTL n'a rien change,
# on essaie :FieldMessages puis AceSpeech, EndSpeechLose...
#
# IMPORTANT : le hook _INTL de french_gender.rb applique rejuvfr_apply_gender
# sur le retour. Nos fallbacks passent par MessageTypes.getFromHash direct,
# donc ils bypassent le resolveur de genre. On applique rejuvfr_apply_gender
# manuellement sur le retour de fallback.

def _INTL_fr_lookup(msg)
  return msg unless msg.is_a?(String) && !msg.empty?
  translated = _INTL(msg)
  return translated if translated != msg
  [:FieldMessages, :AceSpeech, :EndSpeechLose, :EndSpeechWin,
   :BeginSpeech, :OpeningSpeech].each do |type|
    begin
      alt = MessageTypes.getFromHash(type, msg)
      if alt.is_a?(String) && !alt.empty? && alt != msg
        # Applique la resolution de genre car les fallbacks bypassent
        # le hook _INTL qui l'aurait fait normalement.
        alt = rejuvfr_apply_gender(alt) if defined?(rejuvfr_apply_gender)
        return alt
      end
    rescue
      next
    end
  end
  msg
end

# Hook PokeBattle_Battle avec guard contre double-alias : si le mod est
# reevalue (hot-reload ou double load), on skip pour eviter d'aliaser une
# version deja hookee (recursion infinie sinon).

Thread.new do
  60.times do
    break if defined?(PokeBattle_Battle) &&
             PokeBattle_Battle.method_defined?(:setField) &&
             PokeBattle_Battle.method_defined?(:pbDisplayAutoPaused)
    sleep 0.1
  end
  next unless defined?(PokeBattle_Battle)
  s = $VERBOSE
  $VERBOSE = nil
  PokeBattle_Battle.class_eval do
    unless method_defined?(:_orig_setField_fr)
      alias_method :_orig_setField_fr, :setField
      define_method(:setField) do |fieldeffect, temp, message, **kwargs|
        message = _INTL_fr_lookup(message)
        _orig_setField_fr(fieldeffect, temp, message, **kwargs)
      end
    end
    unless method_defined?(:_orig_pbDisplayAutoPaused_fr)
      alias_method :_orig_pbDisplayAutoPaused_fr, :pbDisplayAutoPaused
      define_method(:pbDisplayAutoPaused) do |msg|
        msg = _INTL_fr_lookup(msg)
        _orig_pbDisplayAutoPaused_fr(msg)
      end
    end
    # pbDisplayTrainerMessage substitue \PN par le nom du joueur AVANT
    # d'appeler pbDisplayAutoPaused. Donc si on ne traduit qu'a partir de
    # pbDisplayAutoPaused, on voit "You beat me Alice!" au lieu du
    # template "You beat me \PN!" et le lookup rate. On hook aussi ici
    # pour traduire le template brut.
    if method_defined?(:pbDisplayTrainerMessage) &&
       !method_defined?(:_orig_pbDisplayTrainerMessage_fr)
      alias_method :_orig_pbDisplayTrainerMessage_fr, :pbDisplayTrainerMessage
      define_method(:pbDisplayTrainerMessage) do |msg, index|
        msg = _INTL_fr_lookup(msg) if msg.is_a?(String)
        _orig_pbDisplayTrainerMessage_fr(msg, index)
      end
    end
  end
  $VERBOSE = s
end
