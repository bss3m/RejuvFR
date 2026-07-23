# Route certains messages de combat hardcodes via _INTL pour recuperer la
# traduction FR stockee dans messages_fr.dat.
#
# Concerne :
# - fieldChangeMessage / overlayMessage : passes en dur a setField (Battle_Field.rb)
# - ArchetypeMessage : affiches via pbDisplayAutoPaused sans _INTL
# - trainereffect[:message] (bosstext/trainertext) : affiches via pbDisplayAutoPaused
#
# _INTL cherche uniquement dans :ScriptTexts, mais beaucoup de messages sont stockes
# dans :FieldMessages. On ajoute donc un fallback : si _INTL n'a rien change,
# on essaie :FieldMessages puis AceSpeech, EndSpeechLose...

def _INTL_fr_lookup(msg)
  return msg unless msg.is_a?(String) && !msg.empty?
  translated = _INTL(msg)
  return translated if translated != msg
  [:FieldMessages, :AceSpeech, :EndSpeechLose, :BeginSpeech, :OpeningSpeech].each do |type|
    begin
      alt = MessageTypes.getFromHash(type, msg)
      return alt if alt.is_a?(String) && !alt.empty? && alt != msg
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
  end
  $VERBOSE = s
end
