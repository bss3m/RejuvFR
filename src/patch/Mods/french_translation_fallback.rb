# Fallback global de traduction pour RejuvFR.
#
# Deux problemes distincts corriges :
#
# 1. Le hash @messages contient parfois la traduction dans un mapid /
#    section different(e) de celui/celle passe(e) au lookup.
#
# 2. Le RUNTIME (Ruby scripts _INTL) utilise parfois des string avec
#    "\n\n" (paragraph break) mais notre extraction JSON a normalise en "\n"
#    simple. stringToKey collapse \n\n en un espace mais laisse \n intact ->
#    id_runtime != id_dat_key -> lookup echoue.
#
# On monkey-patche Messages#getFromHash et #getFromMapHash. En cas d'echec
# direct, on cherche dans un index canonique (whitespace toutes formes
# collapsees en un espace simple). L'index est bati LAZY a la premiere miss
# puis cache pour toute la session (rebuild sur reload de messages).

Thread.new do
  60.times do
    break if defined?(Messages) && Messages.method_defined?(:getFromMapHash)
    sleep 0.1
  end
  next unless defined?(Messages)

  s = $VERBOSE
  $VERBOSE = nil

  Messages.class_eval do
    # Canonicalisation : minuscule + tout whitespace (dont \n \r \t) en un
    # espace simple + trim. Rend la comparaison tolerante au \n vs \n\n vs
    # espaces multiples que stringToKey ne collapse pas totalement.
    def _rejuvfr_canon(s)
      return nil unless s.is_a?(String)
      s.gsub(/\s+/, ' ').strip
    end

    # Index paresseux : canonical_key -> value.
    def _rejuvfr_ensure_index
      return @_rejuvfr_index if @_rejuvfr_index && @_rejuvfr_msgs_id == @messages.object_id
      idx = {}
      if @messages
        # scan maps
        maps = @messages[0]
        if maps.respond_to?(:each)
          maps.each do |mapdata|
            next unless mapdata
            begin
              mapdata.each do |k, v|
                next unless k.is_a?(String) && v.is_a?(String) && !v.empty? && v != k
                c = _rejuvfr_canon(k)
                next if c.nil? || c.empty?
                idx[c] ||= v
              end
            rescue
              next
            end
          end
        end
        # scan sections
        @messages.each do |section_key, section|
          next if section_key == 0
          next unless section
          begin
            section.each do |k, v|
              next unless k.is_a?(String) && v.is_a?(String) && !v.empty? && v != k
              c = _rejuvfr_canon(k)
              next if c.nil? || c.empty?
              idx[c] ||= v
            end
          rescue
            next
          end
        end
      end
      @_rejuvfr_index = idx
      @_rejuvfr_msgs_id = @messages.object_id
      idx
    end

    # Helper : applique la resolution de genre si le module gender est charge.
    # Idempotent sur strings sans marqueur, safe a appeler partout.
    def _rejuvfr_gender_wrap(v)
      return v unless v.is_a?(String)
      if Object.private_method_defined?(:rejuvfr_apply_gender) ||
         Object.method_defined?(:rejuvfr_apply_gender)
        begin
          return rejuvfr_apply_gender(v)
        rescue
          return v
        end
      end
      v
    end

    # ---- fallback pour getFromMapHash ----
    #
    # IMPORTANT : pbGetMessageFromHash et autres callers non-_INTL passent
    # DIRECTEMENT par ces methodes et bypassent le hook _INTL de
    # french_gender.rb. On applique donc rejuvfr_apply_gender sur les
    # resultats pour eviter que des (e) ou {M:|F:} bruts s'affichent dans
    # les messages de combat / quete.
    unless method_defined?(:_orig_getFromMapHash_frfb)
      alias_method :_orig_getFromMapHash_frfb, :getFromMapHash
      def getFromMapHash(type, key)
        result = _orig_getFromMapHash_frfb(type, key)
        if result != key
          return _rejuvfr_gender_wrap(result)
        end
        return result unless key.is_a?(String) && !key.empty?
        return result unless @messages
        c = _rejuvfr_canon(key)
        return result if c.nil? || c.empty?
        idx = _rejuvfr_ensure_index
        v = idx[c]
        if v.is_a?(String) && !v.empty? && v != key
          return _rejuvfr_gender_wrap(v)
        end
        result
      end
    end

    # ---- fallback pour getFromHash ----
    unless method_defined?(:_orig_getFromHash_frfb)
      alias_method :_orig_getFromHash_frfb, :getFromHash
      def getFromHash(type, key)
        result = _orig_getFromHash_frfb(type, key)
        if result != key
          return _rejuvfr_gender_wrap(result)
        end
        return result unless key.is_a?(String) && !key.empty?
        return result unless @messages
        c = _rejuvfr_canon(key)
        return result if c.nil? || c.empty?
        idx = _rejuvfr_ensure_index
        v = idx[c]
        if v.is_a?(String) && !v.empty? && v != key
          return _rejuvfr_gender_wrap(v)
        end
        result
      end
    end
  end

  $VERBOSE = s
end
