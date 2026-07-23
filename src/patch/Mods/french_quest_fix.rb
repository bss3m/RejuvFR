# Fix pour un crash Rejuv 14.0 declenche par la traduction FR :
#
# Scripts/Rejuv/Quest/Quest.rb#getQuestReward fait
#   QuestModule.const_get(quest)[:RewardString]
# Certains chapitres (11, 12, 15) n'ont pas de champ :RewardString ->
# la clef retournee est nil.
#
# En anglais, pbGetMessageFromHash tombe sur la branche @getTextLocale.nil?
# qui tolere une clef nil (retourne key inchange).
#
# En francais, @getTextLocale est defini (FR), donc PBIntl.rb:692 execute
# `key.rstrip` sur nil -> NoMethodError -> cascade sur le menu Quete du
# chapitre concerne.
#
# On patch pbGetMessageFromHash pour garder nil AVANT d'appeler getFromHash.
# Aucune modif de fichier de base : simple wrapper defensif.

s = $VERBOSE
$VERBOSE = nil
Object.class_eval do
  unless private_method_defined?(:_orig_pbGetMessageFromHash_frfix) ||
         method_defined?(:_orig_pbGetMessageFromHash_frfix)
    alias_method :_orig_pbGetMessageFromHash_frfix, :pbGetMessageFromHash
    define_method(:pbGetMessageFromHash) do |type, id|
      return "" if id.nil?
      _orig_pbGetMessageFromHash_frfix(type, id)
    end
  end
end
$VERBOSE = s
