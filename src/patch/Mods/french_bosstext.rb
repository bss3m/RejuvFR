# Traduction des textes d'entree de boss.
# Les entryText sont definis en dur dans Scripts/Rejuv/Definitions/bosstext*.rb
# et affiches directement sans passer par _INTL. On alias bossEntryText pour
# router le texte anglais via _INTL avant l'affichage : le moteur trouvera
# alors la traduction stockee dans messages_fr.dat.
#
# On utilise alias_method (pas def bare) pour :
# - preserver l'implementation originale (accessible via _orig_bossEntryText_fr)
# - eviter les conflits avec des mises a jour du jeu de base qui modifieraient
#   bossEntryText
# - permettre un pattern de cleanup si RejuvFR est retire

Thread.new do
  60.times do
    # bossEntryText est defini au top-level (methode Object)
    break if defined?(bossEntryText) || Object.method_defined?(:bossEntryText)
    sleep 0.1
  end
  target_class = if Object.method_defined?(:bossEntryText)
                   Object
                 elsif defined?(bossEntryText)
                   Object
                 else
                   nil
                 end
  next unless target_class
  s = $VERBOSE
  $VERBOSE = nil
  target_class.class_eval do
    unless method_defined?(:_orig_bossEntryText_fr) ||
           private_method_defined?(:_orig_bossEntryText_fr)
      alias_method :_orig_bossEntryText_fr, :bossEntryText
      define_method(:bossEntryText) do |boss|
        entrytext = boss.entryText
        bossPartyIndex = @battle.pbGetOwnerIndex(boss.index)

        return if entrytext.nil? || entrytext == "" ||
                  @entry_message_handled[bossPartyIndex][boss.pokemonIndex] == true
        # Route via _INTL pour recuperer la traduction si disponible.
        entrytext = _INTL(entrytext)
        entrytext = entrytext.gsub(/\\PN/, $Trainer.name)
        karma = $cache.pkmn[boss.pokemon.species, boss.pokemon.form].checkFlag?(:Karma)
        if karma
          pbSEPlay("SFX - Blip", 80, 140)
          pbDisplayPaused(entrytext, color: :karma)
        else
          pbDisplayPaused(entrytext)
        end
        @entry_message_handled[bossPartyIndex][boss.pokemonIndex] = true
      end
    end
  end
  $VERBOSE = s
end
