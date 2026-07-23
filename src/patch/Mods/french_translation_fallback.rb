# Fallback global de traduction pour RejuvFR.
#
# Rejuvenation 14.0 route certains textes de dialogue via _INTL (qui cherche
# uniquement dans :ScriptTexts) alors que la traduction FR se trouve dans un
# fichier Map*.json ; d'autres textes sont stockes dans un mapid different de
# celui ou l'evenement se declenche. Dans ces cas, Messages#getFromHash /
# #getFromMapHash retournent la clef anglaise et le joueur voit de l'anglais
# malgre la presence de la traduction dans messages_fr.dat.
#
# On monkey-patch les deux methodes de lookup sur la classe Messages pour
# qu'en cas d'echec, elles scannent l'ensemble du hash @messages (tous les
# mapids + toutes les sections). Si le meme id apparait ailleurs avec une
# valeur non-identique a la clef, on renvoie cette valeur.
#
# Cout runtime : scan lineaire uniquement sur les strings non-trouves au
# premier passage. Overhead negligeable en pratique.

Thread.new do
  60.times do
    break if defined?(Messages) && Messages.method_defined?(:getFromMapHash)
    sleep 0.1
  end
  next unless defined?(Messages)

  s = $VERBOSE
  $VERBOSE = nil

  Messages.class_eval do
    # ---- fallback pour getFromMapHash ----
    unless method_defined?(:_orig_getFromMapHash_frfb)
      alias_method :_orig_getFromMapHash_frfb, :getFromMapHash
      define_method(:getFromMapHash) do |type, key|
        result = _orig_getFromMapHash_frfb(type, key)
        return result if result != key
        return result unless key.is_a?(String) && !key.empty?
        return result unless @messages
        id = Messages.stringToKey(key)
        # 1. Scan autres maps
        maps = @messages[0]
        if maps.respond_to?(:each_with_index)
          maps.each_with_index do |mapdata, mapid|
            next if mapid == type
            next unless mapdata
            begin
              v = mapdata[id]
              return v if v.is_a?(String) && !v.empty? && v != id && v != key
            rescue
              next
            end
          end
        end
        # 2. Scan sections non-map
        @messages.each do |section_key, section|
          next if section_key == 0
          next unless section
          begin
            v = section[id]
            return v if v.is_a?(String) && !v.empty? && v != id && v != key
          rescue
            next
          end
        end
        result
      end
    end

    # ---- fallback pour getFromHash ----
    unless method_defined?(:_orig_getFromHash_frfb)
      alias_method :_orig_getFromHash_frfb, :getFromHash
      define_method(:getFromHash) do |type, key|
        result = _orig_getFromHash_frfb(type, key)
        return result if result != key
        return result unless key.is_a?(String) && !key.empty?
        return result unless @messages
        id = Messages.stringToKey(key)
        # 1. Scan autres sections
        @messages.each do |section_key, section|
          next if section_key == 0
          next if section_key == type
          next unless section
          begin
            v = section[id]
            return v if v.is_a?(String) && !v.empty? && v != id && v != key
          rescue
            next
          end
        end
        # 2. Scan tous les maps
        maps = @messages[0]
        if maps.respond_to?(:each)
          maps.each do |mapdata|
            next unless mapdata
            begin
              v = mapdata[id]
              return v if v.is_a?(String) && !v.empty? && v != id && v != key
            rescue
              next
            end
          end
        end
        result
      end
    end
  end

  $VERBOSE = s
end
