# Verificateur + telechargeur de mise a jour pour RejuvFR.
#
# Au chargement d'une partie, on interroge l'API GitHub Releases. Si une
# version plus recente est disponible, on propose au joueur de la telecharger
# et de l'appliquer directement, puis on redemarre.
#
# Aucune ecriture n'est faite tant que l'utilisateur n'a pas accepte. Toute
# erreur reseau ou API est silencieuse : le mod se contente de ne rien
# afficher. Une trace debug peut etre laissee dans patch/.rejuvfr_updater.log.

REJUVFR_VERSION = "1.1.2"
REJUVFR_REPO = "bss3m/RejuvFR"
REJUVFR_API = "https://api.github.com/repos/#{REJUVFR_REPO}/releases/latest"
REJUVFR_URL = "https://github.com/#{REJUVFR_REPO}/releases/latest"
REJUVFR_CACHE_PATH = "patch/.rejuvfr_update_check"
REJUVFR_LOG_PATH = "patch/.rejuvfr_updater.log"
REJUVFR_ZIP_TMP = "patch/.rejuvfr_download.zip"

$rejuvfr_update_info = nil

def rejuvfr_log(msg)
  File.open(REJUVFR_LOG_PATH, "a") { |f| f.puts "[RejuvFR] #{msg}" }
rescue
end

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
rescue
  false
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
      unless latest.empty?
        if rejuvfr_version_gt?(latest, REJUVFR_VERSION) && !rejuvfr_already_notified?(latest)
          zip_asset = (data["assets"] || []).find { |a| a["name"].to_s =~ /\.zip$/i }
          $rejuvfr_update_info = {
            version: latest,
            zip_url: zip_asset ? zip_asset["browser_download_url"] : nil,
          }
          rejuvfr_log("Detected update v#{latest}")
        end
      end
    end
  rescue => e
    rejuvfr_log("Detection failed: #{e.class}: #{e.message}")
  end
end

# --- Telechargement ---
# Reimplemente en pilotant Net::HTTP.start / redirections manuellement, sans
# reutiliser une connexion inter-hosts (source du NoMethodError en v1.1.1).

def rejuvfr_fetch(url, dest_path, redirects_left = 5)
  require 'net/http'
  require 'uri'
  uri = URI.parse(url)
  return false unless uri.host
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.open_timeout = 10
    http.read_timeout = 120
    req = Net::HTTP::Get.new(uri.request_uri)
    req["User-Agent"] = "RejuvFR/#{REJUVFR_VERSION}"
    res = http.request(req)
    case res
    when Net::HTTPRedirection
      return false if redirects_left <= 0
      loc = res['location']
      return false if loc.nil? || loc.empty?
      # Si location relative -> resoudre par rapport a l'uri courante
      new_url = loc.start_with?('http') ? loc : URI.join(url, loc).to_s
      return rejuvfr_fetch(new_url, dest_path, redirects_left - 1)
    when Net::HTTPSuccess
      File.open(dest_path, 'wb') { |f| f.write(res.body) }
      return true
    else
      rejuvfr_log("HTTP #{res.code} on #{url}")
      return false
    end
  end
rescue => e
  rejuvfr_log("Fetch failed: #{e.class}: #{e.message}")
  false
end

def rejuvfr_apply_zip(zip_path)
  require 'zip'
  require 'fileutils'
  Zip::File.open(zip_path) do |zf|
    zf.each do |entry|
      name = entry.name.to_s
      next if name.empty?
      next if name.start_with?('__MACOSX', '.git')
      # On extrait uniquement les entrees dans patch/
      next unless name.start_with?('patch/', 'patch\\')
      target = name.tr('\\', '/')
      dir = File.dirname(target)
      FileUtils.mkdir_p(dir) if dir && dir != '.'
      begin
        File.unlink(target) if File.exist?(target)
      rescue
      end
      begin
        zf.extract(entry, target) { true }
      rescue => e
        rejuvfr_log("Extract failed on #{name}: #{e.class}: #{e.message}")
      end
    end
  end
  true
rescue => e
  rejuvfr_log("Apply zip failed: #{e.class}: #{e.message}")
  false
end

def rejuvfr_safe_message(text, commands = nil, default = 0)
  # Kernel.pbMessage est l'API standard mais son nom a legerement varie selon
  # les versions. On tente les alternatives.
  if commands
    return Kernel.pbMessage(text, commands, default) if Kernel.respond_to?(:pbMessage)
    return pbMessage(text, commands, default) if defined?(pbMessage)
    puts "[RejuvFR] #{text}"
    return default
  else
    return Kernel.pbMessage(text) if Kernel.respond_to?(:pbMessage)
    return pbMessage(text) if defined?(pbMessage)
    puts "[RejuvFR] #{text}"
    return nil
  end
end

def rejuvfr_prompt_and_apply(info)
  latest = info[:version]
  msg = "Nouvelle version de RejuvFR disponible : v#{latest}\n(actuelle : v#{REJUVFR_VERSION})\n\nTélécharger et installer maintenant ?"
  choice = rejuvfr_safe_message(msg, ["Oui", "Non"], 1)
  if choice != 0
    rejuvfr_mark_notified(latest)
    return
  end
  unless info[:zip_url]
    rejuvfr_safe_message("Aucun fichier ZIP disponible pour cette version.\nRendez-vous sur :\n#{REJUVFR_URL}")
    rejuvfr_mark_notified(latest)
    return
  end
  rejuvfr_safe_message("Téléchargement en cours...\nCela peut prendre quelques secondes.")
  if rejuvfr_fetch(info[:zip_url], REJUVFR_ZIP_TMP)
    if rejuvfr_apply_zip(REJUVFR_ZIP_TMP)
      begin; File.delete(REJUVFR_ZIP_TMP); rescue; end
      rejuvfr_mark_notified(latest)
      rejuvfr_safe_message("Mise à jour installée !\nLe jeu va se fermer pour appliquer les changements.")
      begin
        exit!
      rescue
        exit
      end
    else
      rejuvfr_safe_message("L'installation a échoué.\nRendez-vous sur :\n#{REJUVFR_URL}")
    end
  else
    rejuvfr_safe_message("Le téléchargement a échoué.\nRendez-vous sur :\n#{REJUVFR_URL}")
  end
rescue => e
  rejuvfr_log("Prompt failed: #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
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
  begin
    Scene_Map.class_eval do
      unless method_defined?(:_orig_main_rejuvfr_updater)
        alias_method :_orig_main_rejuvfr_updater, :main
        define_method(:main) do
          begin
            if $rejuvfr_update_info && defined?($Trainer) && $Trainer && !@_rejuvfr_notified
              @_rejuvfr_notified = true
              info = $rejuvfr_update_info
              $rejuvfr_update_info = nil
              rejuvfr_prompt_and_apply(info)
            end
          rescue => e
            rejuvfr_log("Scene_Map hook failed: #{e.class}: #{e.message}")
          end
          _orig_main_rejuvfr_updater
        end
      end
    end
  rescue => e
    rejuvfr_log("Hook install failed: #{e.class}: #{e.message}")
  end
  $VERBOSE = s
end
