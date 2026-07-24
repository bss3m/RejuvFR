# Re-traduction du RiftDex apres chargement de messages_fr.dat.
#
# PROBLEME
# Scripts/Rejuv/RiftDex.rb definit RIFTDATA = { :RIFTFERROTHORN => {
#   :name => _INTL("Code: Drifio"),
#   :desc => _INTL("In its Suspended Form..."),
#   :notes => _INTL("Ferrothorn volunteered..."),
# }, ... } au chargement du script Ruby.
#
# A ce moment-la, Scripts/PBIntl.rb est deja charge mais @@messages est
# vide (aucun .dat charge). Les _INTL() renvoient donc leur input tel quel
# (anglais) et cette valeur anglaise est FIGEE dans le hash RIFTDATA.
#
# Plus tard, quand notre patch/Init/french_translation.rb declenche
# pbLoadLanguage qui charge messages_fr.dat, RIFTDATA est deja construit :
# le RiftDex affiche l'anglais meme en mode FR.
#
# SOLUTION
# Une fois messages_fr.dat charge, on parcourt RIFTDATA et on re-run
# _INTL sur chaque :name / :desc / :notes. Comme les valeurs actuelles
# sont les strings sources anglaises, _INTL trouve maintenant la
# traduction FR (via le fallback canonique v1.1.21 qui gere le mismatch
# \n\n vs \n).
#
# On snapshot les valeurs originales dans $_rejuvfr_riftdex_original
# pour pouvoir refaire l'operation proprement si le joueur change de
# langue (FR -> EN -> FR).

$_rejuvfr_riftdex_original = nil

def rejuvfr_retranslate_riftdex
  return unless defined?(RIFTDATA)
  return unless RIFTDATA.is_a?(Hash)

  # Snapshot des valeurs actuelles au 1er appel (elles sont en anglais
  # car _INTL au load-time n'a pas trouve la trad).
  if $_rejuvfr_riftdex_original.nil?
    snap = {}
    RIFTDATA.each do |k, entry|
      next unless entry.is_a?(Hash)
      s = {}
      [:name, :desc, :notes].each do |f|
        v = entry[f]
        s[f] = v.dup if v.is_a?(String) && !v.empty?
      end
      snap[k] = s unless s.empty?
    end
    $_rejuvfr_riftdex_original = snap
  end

  # Re-run _INTL sur chaque field a partir du snapshot anglais.
  # Si l'utilisateur repasse en EN, _INTL retourne la string inchangee
  # (fallback trouve rien -> retourne key) -> l'anglais est restore.
  $_rejuvfr_riftdex_original.each do |k, snap|
    entry = RIFTDATA[k]
    next unless entry.is_a?(Hash)
    snap.each do |field, original_en|
      begin
        translated = _INTL(original_en)
        entry[field] = translated if translated.is_a?(String) && !translated.empty?
      rescue
        # silent : garde la valeur precedente
      end
    end
  end
end

# ---- Trigger 1 : au boot, une fois messages_fr.dat charge ----
# On attend que @@messages soit populate (via check indirect : $Settings
# doit exister ET LANGUAGES doit avoir plus qu'une entree).

Thread.new do
  120.times do
    ready = defined?(RIFTDATA) &&
            defined?($Settings) && $Settings &&
            defined?(_INTL) &&
            defined?(LANGUAGES) && !LANGUAGES.empty?
    break if ready
    sleep 0.1
  end
  begin
    rejuvfr_retranslate_riftdex
  rescue => e
    # silent
  end
end

# ---- Trigger 2 : hook pbLoadLanguage pour re-translate au changement ----
# Quand l'utilisateur switch EN <-> FR depuis le menu, messages_fr.dat est
# rechargee (ou videe). On refait le pass sur RIFTDATA.

Thread.new do
  60.times do
    break if defined?(pbLoadLanguage)
    sleep 0.1
  end
  next unless defined?(pbLoadLanguage)
  s = $VERBOSE
  $VERBOSE = nil
  Object.class_eval do
    unless private_method_defined?(:_orig_pbLoadLanguage_fr_riftdex) ||
           method_defined?(:_orig_pbLoadLanguage_fr_riftdex)
      alias_method :_orig_pbLoadLanguage_fr_riftdex, :pbLoadLanguage
      define_method(:pbLoadLanguage) do
        result = _orig_pbLoadLanguage_fr_riftdex
        begin
          rejuvfr_retranslate_riftdex
        rescue
          # silent
        end
        result
      end
    end
  end
  $VERBOSE = s
end
