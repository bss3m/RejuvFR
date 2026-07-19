# Traduction des textes d'entree de boss.
# Les entryText sont definis en dur dans Scripts/Rejuv/Definitions/bosstext*.rb
# et affiches directement sans passer par _INTL. On surcharge bossEntryText
# pour que le texte anglais soit route via _INTL avant l'affichage :
# le moteur trouvera alors la traduction stockee dans messages_fr.dat.

def bossEntryText(boss)
  entrytext = boss.entryText
  bossPartyIndex = @battle.pbGetOwnerIndex(boss.index)

  return if entrytext.nil? || entrytext == "" || @entry_message_handled[bossPartyIndex][boss.pokemonIndex] == true
  # Route via _INTL pour recuperer la traduction si disponible.
  entrytext = _INTL(entrytext)
  entrytext = entrytext.gsub(/\\PN/, $Trainer.name)
  karma = $cache.pkmn[boss.pokemon.species, boss.pokemon.form].checkFlag?(:Karma)
  if karma
    pbSEPlay("SFX - Blip", 80, 140)
    pbDisplayPaused(entrytext, color: :karma)
    @entry_message_handled[bossPartyIndex][boss.pokemonIndex] = true
  else
    pbDisplayPaused(entrytext)
    @entry_message_handled[bossPartyIndex][boss.pokemonIndex] = true
  end
end
