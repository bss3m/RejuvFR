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

class PokeBattle_Battle
  alias_method :_orig_setField_fr, :setField
  def setField(fieldeffect, temp, message, **kwargs)
    message = _INTL_fr_lookup(message)
    _orig_setField_fr(fieldeffect, temp, message, **kwargs)
  end

  alias_method :_orig_pbDisplayAutoPaused_fr, :pbDisplayAutoPaused
  def pbDisplayAutoPaused(msg)
    msg = _INTL_fr_lookup(msg)
    _orig_pbDisplayAutoPaused_fr(msg)
  end
end
