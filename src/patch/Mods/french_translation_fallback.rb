# Fallback global de traduction pour RejuvFR.
#
# Rejuvenation 14.0 route certains textes de dialogue via _INTL (qui cherche
# uniquement dans :ScriptTexts) alors que la traduction FR se trouve dans un
# fichier Map*.json ; d'autres textes sont stockes dans un mapid different de
# celui ou l'evenement se declenche. Dans ces cas, MessageTypes.getFromHash /
# getFromMapHash retournent la clef anglaise et le joueur voit de l'anglais
# malgre la presence de la traduction dans messages_fr.dat.
#
# On monkey-patch les deux methodes de lookup pour qu'en cas d'echec, elles
# scannent l'ensemble du hash @messages (tous les mapids + toutes les
# sections). Si le meme id apparait ailleurs avec une valeur non-identique
# a la clef, on renvoie cette valeur.
#
# Cout runtime : scan lineaire uniquement sur les strings non-trouves au
# premier passage. Vu la taille du hash (~150 000 entrees) et le nombre
# d'appels par frame, l'overhead est negligeable.

Thread.new do
  60.times do
    break if defined?(MessageTypes) && MessageTypes.respond_to?(:getFromHash)
    sleep 0.1
  end
  next unless defined?(MessageTypes)

  s = $VERBOSE
  $VERBOSE = nil

  MessageTypes.singleton_class.class_eval do
    unless method_defined?(:_orig_getFromMapHash_frfb)
      alias_method :_orig_getFromMapHash_frfb, :getFromMapHash
      define_method(:getFromMapHash) do |type, key|
        result = _orig_getFromMapHash_frfb(type, key)
        return result if result != key
        return result unless key.is_a?(String) && !key.empty?
        # Scan tous les autres maps
        msgs = instance_variable_get(:@messages)
        return result unless msgs && msgs[0]
        id = Messages.stringToKey(key)
        maps = msgs[0]
        if maps.respond_to?(:each_with_index)
          maps.each_with_index do |mapdata, mapid|
            next if mapid == type
            next unless mapdata.is_a?(Hash) || mapdata.respond_to?(:[])
            begin
              v = mapdata[id]
              return v if v.is_a?(String) && !v.empty? && v != id && v != key
            rescue
              next
            end
          end
        end
        # Scan aussi toutes les sections non-map
        msgs.each do |section_key, section|
          next if section_key == 0
          next unless section.is_a?(Hash) || section.respond_to?(:[])
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

    unless method_defined?(:_orig_getFromHash_frfb)
      alias_method :_orig_getFromHash_frfb, :getFromHash
      define_method(:getFromHash) do |type, key|
        result = _orig_getFromHash_frfb(type, key)
        return result if result != key
        return result unless key.is_a?(String) && !key.empty?
        msgs = instance_variable_get(:@messages)
        return result unless msgs
        id = Messages.stringToKey(key)
        # Scan sections autres que 'type'
        msgs.each do |section_key, section|
          next if section_key == 0
          next if section_key == type
          next unless section.is_a?(Hash) || section.respond_to?(:[])
          begin
            v = section[id]
            return v if v.is_a?(String) && !v.empty? && v != id && v != key
          rescue
            next
          end
        end
        # Scan tous les maps
        if msgs[0]
          maps = msgs[0]
          if maps.respond_to?(:each)
            maps.each do |mapdata|
              next unless mapdata.is_a?(Hash) || (mapdata.respond_to?(:[]) rescue false)
              begin
                v = mapdata[id]
                return v if v.is_a?(String) && !v.empty? && v != id && v != key
              rescue
                next
              end
            end
          end
        end
        result
      end
    end
  end

  $VERBOSE = s
end
