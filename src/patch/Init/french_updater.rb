# Verificateur + telechargeur de mise a jour pour RejuvFR.
#
# Au chargement d'une partie, on interroge l'API GitHub Releases. Si une
# version plus recente est disponible, on propose au joueur de la telecharger
# et de l'appliquer directement en jeu (comme le fait le mecanisme officiel
# Updater de Rejuvenation), puis on redemarre.
#
# Aucune ecriture n'est faite tant que l'utilisateur n'a pas accepte.

REJUVFR_VERSION = "1.1.0"
REJUVFR_REPO = "bss3m/RejuvFR"
REJUVFR_API = "https://api.github.com/repos/#{REJUVFR_REPO}/releases/latest"
REJUVFR_URL = "https://github.com/#{REJUVFR_REPO}/releases/latest"
REJUVFR_CACHE_PATH = "patch/.rejuvfr_update_check"
REJUVFR_ZIP_TMP = "patch/.rejuvfr_download.zip"

$rejuvfr_update_info = nil  # {version: "x.y.z", zip_url: "..."}

def rejuvfr_already_notified?(latest)
  return false unless File.exist?(REJUVFR_CACHE_PATH)
  File.read(REJUVFR_CACHE_PATH).strip == latest
rescue
  false
end

def rejuvfr_mark_notified(latest)
  File.write(REJUVFR_CACHE_PATH, latest)
rescue
end

def rejuvfr_version_gt?(a, b)
  aa = a.gsub(/^v/, '').split('.').map(&:to_i)
  bb = b.gsub(/^v/, '').split('.').map(&:to_i)
  (aa <=> bb) > 0
end

# --- Detection ---

Thread.new do
  begin
    require 'net/http'
    require 'uri'
    require 'json'
    uri = URI.parse(REJUVFR_API)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 4
    http.read_timeout = 4
    req = Net::HTTP::Get.new(uri.request_uri)
    req["User-Agent"] = "RejuvFR/#{REJUVFR_VERSION}"
    res = http.request(req)
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body)
      latest = (data["tag_name"] || "").gsub(/^v/, '')
      return if latest.empty?
      return unless rejuvfr_version_gt?(latest, REJUVFR_VERSION)
      return if rejuvfr_already_notified?(latest)
      # Chercher l'asset zip .zip
      zip_asset = (data["assets"] || []).find { |a| a["name"] =~ /\.zip$/i }
      $rejuvfr_update_info = {
        version: latest,
        zip_url: zip_asset ? zip_asset["browser_download_url"] : nil,
      }
    end
  rescue
    # silencieux : hors ligne, timeout, DNS, etc.
  end
end

# --- Telechargement + application ---

def rejuvfr_download_zip(url, dest_path)
  require 'net/http'
  require 'uri'
  msgwindow = Kernel.pbCreateMessageWindow
  Kernel.pbMessageDisplay(msgwindow, _INTL("Téléchargement de la mise à jour...\\wtnp[0]"))
  ok = false
  begin
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 10
      http.read_timeout = 60
      # GitHub redirige vers un CDN. Suivre les redirections manuellement.
      redirects = 0
      loop do
        req = Net::HTTP::Get.new(uri.request_uri)
        req["User-Agent"] = "RejuvFR/#{REJUVFR_VERSION}"
        res = http.request(req)
        case res
        when Net::HTTPRedirection
          redirects += 1
          break if redirects > 5
          new_uri = URI.parse(res['location'])
          if new_uri.host && new_uri.host != uri.host
            http.finish
            http = Net::HTTP.new(new_uri.host, new_uri.port)
            http.use_ssl = new_uri.scheme == 'https'
            http.start
          end
          uri = new_uri
          next
        when Net::HTTPSuccess
          File.open(dest_path, 'wb') { |f| f.write(res.body) }
          ok = true
          break
        else
          break
        end
      end
    end
  rescue => e
    ok = false
  ensure
    Kernel.pbDisposeMessageWindow(msgwindow) if msgwindow
  end
  ok
end

def rejuvfr_apply_zip(zip_path)
  require 'zip'
  require 'fileutils'
  # On extrait par-dessus le dossier courant. Le zip contient patch/*.
  Zip::File.open(zip_path) do |zf|
    zf.each do |entry|
      # Skip metadata files
      next if entry.name.start_with?('__MACOSX', '.git')
      # Cible : racine du jeu
      target = entry.name
      # Skip fichiers hors patch/ (INSTALLATION.txt, LICENSE)
      next unless target.start_with?('patch/', 'patch\\')
      FileUtils.mkdir_p(File.dirname(target))
      # Supprimer avant d'ecrire pour eviter le lock (si le jeu utilise le fichier)
      File.unlink(target) rescue nil if File.exist?(target)
      zf.extract(entry, target) { true }
    end
  end
  true
rescue => e
  false
end

def rejuvfr_prompt_and_apply(info)
  latest = info[:version]
  msg = _INTL("Nouvelle version de RejuvFR disponible : v{1}\n(actuelle : v{2})\n\nTélécharger et installer maintenant ?", latest, REJUVFR_VERSION)
  choice = Kernel.pbMessage(msg, [_INTL("Oui"), _INTL("Non")], 1)
  if choice != 0
    rejuvfr_mark_notified(latest)
    return
  end
  unless info[:zip_url]
    Kernel.pbMessage(_INTL("Aucun fichier ZIP disponible pour cette release.\nRendez-vous sur :\n{1}", REJUVFR_URL))
    rejuvfr_mark_notified(latest)
    return
  end
  if rejuvfr_download_zip(info[:zip_url], REJUVFR_ZIP_TMP)
    if rejuvfr_apply_zip(REJUVFR_ZIP_TMP)
      begin; File.delete(REJUVFR_ZIP_TMP); rescue; end
      rejuvfr_mark_notified(latest)
      Kernel.pbMessage(_INTL("Mise à jour installée !\nLe jeu va se fermer pour appliquer les changements."))
      exit!
    else
      Kernel.pbMessage(_INTL("L'installation a échoué.\nRendez-vous sur :\n{1}", REJUVFR_URL))
    end
  else
    Kernel.pbMessage(_INTL("Le téléchargement a échoué.\nRendez-vous sur :\n{1}", REJUVFR_URL))
  end
end

# --- Hook : proposer la mise a jour au chargement d'une partie ---

Thread.new do
  60.times do
    break if defined?(Scene_Map)
    sleep 0.1
  end
  next unless defined?(Scene_Map)
  s = $VERBOSE
  $VERBOSE = nil
  Scene_Map.class_eval do
    unless method_defined?(:_orig_main_rejuvfr_updater)
      alias_method :_orig_main_rejuvfr_updater, :main
      define_method(:main) do
        if $rejuvfr_update_info && $Trainer && !@_rejuvfr_notified
          @_rejuvfr_notified = true
          rejuvfr_prompt_and_apply($rejuvfr_update_info)
          $rejuvfr_update_info = nil
        end
        _orig_main_rejuvfr_updater
      end
    end
  end
  $VERBOSE = s
end
