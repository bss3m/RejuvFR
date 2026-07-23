# Verificateur + telechargeur de mise a jour pour RejuvFR.
#
# Au chargement d'une partie, on interroge l'API GitHub Releases. Si une
# version plus recente est disponible, on propose au joueur de la telecharger,
# on extrait dans un dossier temporaire .rejuvfr_update/, on spawn un script
# detache qui va deplacer les fichiers apres l'arret du jeu, puis on
# quitte proprement.
#
# Architecture cross-platform :
#   Windows : .bat + wrapper .vbs (WScript.Shell.Run cache), robocopy.
#   Linux / macOS : .sh + cp -Rf + nohup detache.
# Le staging dans un dossier temporaire evite les locks fichiers qui
# empechent d'ecraser messages_fr.dat pendant l'execution.

REJUVFR_VERSION = "1.1.22"
REJUVFR_REPO = "bss3m/RejuvFR"
REJUVFR_API = "https://api.github.com/repos/#{REJUVFR_REPO}/releases/latest"
REJUVFR_URL = "https://github.com/#{REJUVFR_REPO}/releases/latest"
REJUVFR_CACHE_PATH = "patch/.rejuvfr_update_check"
REJUVFR_LOG_PATH = "patch/.rejuvfr_updater.log"
REJUVFR_ZIP_TMP = "patch/.rejuvfr_download.zip"
REJUVFR_STAGING_DIR = ".rejuvfr_update"
REJUVFR_APPLY_BAT = ".rejuvfr_apply.bat"
REJUVFR_APPLY_VBS = ".rejuvfr_apply.vbs"
REJUVFR_APPLY_SH  = ".rejuvfr_apply.sh"

# Detection plateforme. mkxp-z tourne sur Windows / Linux / macOS.
# Sur Linux/macOS on utilise un .sh + cp -rf + fork detache. Sur Windows
# on garde le .bat + wrapper .vbs pour cacher la console.
REJUVFR_IS_WINDOWS = (RUBY_PLATFORM =~ /mswin|mingw|cygwin/) ? true : false
REJUVFR_IS_MACOS   = (RUBY_PLATFORM =~ /darwin/) ? true : false
REJUVFR_IS_LINUX   = (RUBY_PLATFORM =~ /linux/) ? true : false

$rejuvfr_update_info = nil

def rejuvfr_log(msg)
  File.open(REJUVFR_LOG_PATH, "a") { |f| f.puts "[RejuvFR #{Time.now}] #{msg}" }
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
#
# Auto-updater desactive sur JoiPlay / Kirin (mobile) : ces environnements
# n'ont pas net/http ni cmd.exe/robocopy pour appliquer le patch. Les
# utilisateurs mobiles doivent telecharger la mise a jour manuellement
# depuis GitHub Releases. Le hook Scene_Map plus bas reste actif mais ne
# fera rien tant que $rejuvfr_update_info reste nil (cas mobile).

REJUVFR_ON_MOBILE = (defined?($joiplay) && $joiplay) || (defined?($kirin) && $kirin)
if REJUVFR_ON_MOBILE
  rejuvfr_log("Auto-updater desactive (JoiPlay/Kirin)")
else

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

end  # fin du if !REJUVFR_ON_MOBILE (thread detection desactive sur mobile)

# --- Telechargement (redirections par recursion) ---

def rejuvfr_fetch(url, dest_path, redirects_left = 5)
  require 'net/http'
  require 'uri'
  uri = URI.parse(url)
  return false unless uri.host
  result = false
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.open_timeout = 10
    http.read_timeout = 180
    req = Net::HTTP::Get.new(uri.request_uri)
    req["User-Agent"] = "RejuvFR/#{REJUVFR_VERSION}"
    res = http.request(req)
    case res
    when Net::HTTPRedirection
      if redirects_left > 0
        loc = res['location']
        unless loc.nil? || loc.empty?
          new_url = loc.start_with?('http') ? loc : URI.join(url, loc).to_s
          # On sort du bloc puis on rappelle recursivement (evite les ennuis
          # de reutilisation de la session Net::HTTP inter-hosts).
          result = :redirect
          $rejuvfr_next_url = new_url
        end
      else
        rejuvfr_log("Too many redirects on #{url}")
      end
    when Net::HTTPSuccess
      File.open(dest_path, 'wb') { |f| f.write(res.body) }
      result = true
    else
      rejuvfr_log("HTTP #{res.code} on #{url}")
    end
  end
  if result == :redirect
    next_url = $rejuvfr_next_url
    $rejuvfr_next_url = nil
    return rejuvfr_fetch(next_url, dest_path, redirects_left - 1)
  end
  result == true
rescue => e
  rejuvfr_log("Fetch failed: #{e.class}: #{e.message}")
  false
end

# --- Extraction dans un dossier de staging ---

def rejuvfr_extract_to_staging(zip_path, staging_dir)
  require 'zip'
  require 'fileutils'
  FileUtils.rm_rf(staging_dir) if File.exist?(staging_dir)
  FileUtils.mkdir_p(staging_dir)
  Zip::File.open(zip_path) do |zf|
    zf.each do |entry|
      name = entry.name.to_s
      next if name.empty?
      next if name.start_with?('__MACOSX', '.git')
      next unless name.start_with?('patch/', 'patch\\')
      target = File.join(staging_dir, name.tr('\\', '/'))
      if entry.directory?
        FileUtils.mkdir_p(target)
        next
      end
      dir = File.dirname(target)
      FileUtils.mkdir_p(dir) if dir && dir != '.'
      begin
        zf.extract(entry, target) { true }
      rescue => e
        rejuvfr_log("Extract failed on #{name}: #{e.class}: #{e.message}")
        return false
      end
    end
  end
  true
rescue => e
  rejuvfr_log("Extract to staging failed: #{e.class}: #{e.message}")
  false
end

# --- Script batch detache ---
# Ce script attend que le jeu se ferme, deplace les fichiers du staging vers
# patch/, puis se supprime. Sur Windows uniquement.

def rejuvfr_write_apply_bat(staging_dir, bat_path)
  # Absolutiser les chemins pour ne pas dependre du CWD au moment de
  # l'execution du bat (Ruby et le bat detache ne partagent pas le meme).
  game_dir = File.expand_path(".")
  staging_abs = File.expand_path(staging_dir)
  zip_abs = File.expand_path(REJUVFR_ZIP_TMP)
  patch_abs = File.expand_path("patch")
  vbs_abs = File.expand_path(REJUVFR_APPLY_VBS)

  content = <<~BAT
    @echo off
    setlocal

    cd /d "#{game_dir}"

    rem Attendre que le jeu se ferme pour liberer les locks sur patch/
    timeout /t 3 /nobreak >nul 2>&1

    if not exist "#{staging_abs}\\patch" goto :end

    rem Copier les fichiers du staging vers patch/ (ecrase les existants)
    robocopy "#{staging_abs}\\patch" "#{patch_abs}" /E /R:5 /W:2 /NFL /NDL /NJH /NJS >nul 2>&1

    rem Nettoyer le dossier de staging
    rmdir /S /Q "#{staging_abs}" 2>nul

    rem Supprimer le zip temporaire
    if exist "#{zip_abs}" del /Q "#{zip_abs}" 2>nul

    :end
    rem Relancer Rejuvenation
    if exist "#{game_dir}\\Rejuvenation.exe" (
      start "" "#{game_dir}\\Rejuvenation.exe"
    )
    rem Supprimer le vbs wrapper puis se supprimer soi-meme
    if exist "#{vbs_abs}" del /Q "#{vbs_abs}" 2>nul
    del "%~f0"
  BAT
  File.write(bat_path, content)
  true
rescue => e
  rejuvfr_log("Write bat failed: #{e.class}: #{e.message}")
  false
end

# --- Wrapper VBScript pour lancer le .bat en mode masqu\xC3\xA9 (pas de fenetre CMD) ---
# On genere un .vbs de 3 lignes qui invoque le .bat via WScript.Shell.Run
# avec le flag intWindowStyle = 0 (fenetre invisible). Le .bat lui-meme fait
# tout le travail (attente 3s, robocopy, cleanup) sans jamais afficher de
# console. Compatible Windows XP a Windows 11.

def rejuvfr_write_apply_vbs(bat_path, vbs_path)
  bat_abs = File.expand_path(bat_path)
  # WScript.Shell.Run(command, intWindowStyle, bWaitOnReturn)
  # intWindowStyle = 0 -> fenetre cachee
  # bWaitOnReturn = False -> ne pas attendre la fin
  content = <<~VBS
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run """#{bat_abs}""", 0, False
    Set objShell = Nothing
  VBS
  File.write(vbs_path, content)
  true
rescue => e
  rejuvfr_log("Write vbs failed: #{e.class}: #{e.message}")
  false
end

# --- Script shell pour Linux / macOS ---
# Ecrit un .sh qui attend la fermeture du jeu (sleep 3), copie le staging
# dans patch/, nettoie, puis se supprime. binwrite pour ecrire en LF pur
# meme si on genere le fichier depuis Windows (utile pour tests).

def rejuvfr_write_apply_sh(staging_dir, sh_path)
  game_dir    = File.expand_path(".")
  staging_abs = File.expand_path(staging_dir)
  zip_abs     = File.expand_path(REJUVFR_ZIP_TMP)
  patch_abs   = File.expand_path("patch")
  # Nom du binaire de relance : Rejuvenation.exe sur mkxp-z Windows,
  # mkxp-z (ou "Rejuvenation") sur Linux, mkxp-z.app/Contents/MacOS/mkxp-z
  # sur macOS. On tente plusieurs candidats.
  relaunch_cmd = if REJUVFR_IS_MACOS
    %Q{if [ -d "#{game_dir}/mkxp-z.app" ]; then open "#{game_dir}/mkxp-z.app"; elif [ -x "#{game_dir}/mkxp-z" ]; then "#{game_dir}/mkxp-z" & fi}
  else
    # Linux : mkxp-z ou Rejuvenation (selon le packaging)
    %Q{if [ -x "#{game_dir}/mkxp-z" ]; then "#{game_dir}/mkxp-z" & elif [ -x "#{game_dir}/Rejuvenation" ]; then "#{game_dir}/Rejuvenation" & fi}
  end
  content = <<~SH
    #!/bin/sh
    # Auto-generated by RejuvFR updater. Applies staged patch and relaunches.
    cd "#{game_dir}" || exit 1
    sleep 3
    if [ -d "#{staging_abs}/patch" ]; then
      cp -Rf "#{staging_abs}/patch/." "#{patch_abs}/" 2>/dev/null
    fi
    rm -rf "#{staging_abs}" 2>/dev/null
    [ -f "#{zip_abs}" ] && rm -f "#{zip_abs}" 2>/dev/null
    #{relaunch_cmd}
    rm -f "$0"
  SH
  # binwrite en LF pur (empeche CRLF si le fichier est genere depuis
  # Windows par erreur). chmod +x pour rendre executable.
  File.binwrite(sh_path, content.gsub(/\r\n?/, "\n"))
  begin
    File.chmod(0o755, sh_path)
  rescue
    # File.chmod peut echouer sur certains FS (NTFS via mkxp-z), on ignore :
    # on lancera de toute facon via "sh script.sh" (pas via ./script.sh).
  end
  true
rescue => e
  rejuvfr_log("Write sh failed: #{e.class}: #{e.message}")
  false
end

# --- Message helper (fallback si Kernel.pbMessage indisponible) ---

def rejuvfr_safe_message(text, commands = nil, default = 0)
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
    rejuvfr_safe_message("Aucun fichier ZIP disponible.\nRendez-vous sur :\n#{REJUVFR_URL}")
    rejuvfr_mark_notified(latest)
    return
  end
  # Message auto-dismiss (\wtnp[N] = attente N*2 frames sans pression de
  # touche). Le message informe qu'un telechargement se prepare, se ferme
  # tout seul, puis fetch/extract commencent (le jeu freeze ~2-3s en
  # silence, comportement standard).
  rejuvfr_safe_message("Téléchargement de la mise à jour...\\wtnp[45]")
  unless rejuvfr_fetch(info[:zip_url], REJUVFR_ZIP_TMP)
    rejuvfr_safe_message("Le téléchargement a échoué.\nRendez-vous sur :\n#{REJUVFR_URL}")
    return
  end
  unless rejuvfr_extract_to_staging(REJUVFR_ZIP_TMP, REJUVFR_STAGING_DIR)
    rejuvfr_safe_message("L'extraction a échoué.\nRendez-vous sur :\n#{REJUVFR_URL}")
    return
  end
  # Dispatch selon la plateforme : Windows -> .bat + wrapper .vbs cache,
  # Linux/macOS -> .sh detache via fork/spawn.
  if REJUVFR_IS_WINDOWS
    unless rejuvfr_write_apply_bat(REJUVFR_STAGING_DIR, REJUVFR_APPLY_BAT)
      rejuvfr_safe_message("Impossible de préparer l'installation.\nRendez-vous sur :\n#{REJUVFR_URL}")
      return
    end
    unless rejuvfr_write_apply_vbs(REJUVFR_APPLY_BAT, REJUVFR_APPLY_VBS)
      rejuvfr_safe_message("Impossible de préparer l'installation.\nRendez-vous sur :\n#{REJUVFR_URL}")
      return
    end
  else
    # Linux / macOS
    unless rejuvfr_write_apply_sh(REJUVFR_STAGING_DIR, REJUVFR_APPLY_SH)
      rejuvfr_safe_message("Impossible de préparer l'installation.\nRendez-vous sur :\n#{REJUVFR_URL}")
      return
    end
  end
  # Spawn detache du script d'application. Sur Windows on lance le wrapper
  # VBScript (aucune fenetre CMD visible). Sur Linux/macOS on lance le .sh
  # directement via "sh script.sh" (evite les problemes de chmod sur NTFS).
  begin
    if REJUVFR_IS_WINDOWS
      vbs_abs = File.expand_path(REJUVFR_APPLY_VBS)
      if defined?(spawn) && Process.respond_to?(:detach)
        pid = spawn("wscript.exe", vbs_abs, [:out, :err] => [REJUVFR_LOG_PATH, "a"])
        Process.detach(pid)
      else
        # Fallback : system + start (bloque brievement mais fonctionne)
        system("wscript.exe \"#{vbs_abs}\"")
      end
    else
      sh_abs = File.expand_path(REJUVFR_APPLY_SH)
      if defined?(spawn) && Process.respond_to?(:detach)
        # nohup pour survivre a la fermeture du process pere ; sh au lieu
        # de bash (POSIX-only, dispo partout).
        pid = spawn("nohup", "sh", sh_abs, [:out, :err] => [REJUVFR_LOG_PATH, "a"], :pgroup => true)
        Process.detach(pid)
      else
        # Fallback : system + & (detachement shell)
        system("nohup sh \"#{sh_abs}\" >/dev/null 2>&1 &")
      end
    end
    rejuvfr_mark_notified(latest)
    rejuvfr_safe_message("Mise à jour prête !\nLe jeu va se fermer.\nIl se relancera automatiquement dans quelques secondes.")
    begin
      exit!
    rescue
      exit
    end
  rescue => e
    rejuvfr_log("Spawn failed: #{e.class}: #{e.message}")
    rejuvfr_safe_message("Impossible de lancer l'installation.\nRendez-vous sur :\n#{REJUVFR_URL}")
  end
rescue => e
  rejuvfr_log("Prompt failed: #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
end

# --- Hook : proposer la mise a jour au chargement d'une partie ---
#
# On hooke Scene_Map#update (pas #main). En hookant #main, on affichait le
# prompt AVANT createSpritesets/Graphics.transition/Input.update -> l'input
# n'etait pas actif et le message etait non-quittable.
#
# On attend en plus quelques frames pour que la scene soit stabilisee et
# que l'utilisateur voie bien qu'il est en jeu.

$rejuvfr_frames_before_prompt = 60  # ~1 seconde a 60 fps

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
      unless method_defined?(:_orig_update_rejuvfr_updater)
        alias_method :_orig_update_rejuvfr_updater, :update
        define_method(:update) do
          _orig_update_rejuvfr_updater
          begin
            if $rejuvfr_update_info && defined?($Trainer) && $Trainer && !@_rejuvfr_notified
              # Ne pas afficher pendant qu'un autre message est deja en cours,
              # ni pendant une transition/transfer, ni pendant un event.
              busy = false
              begin
                busy ||= $game_temp && $game_temp.message_window_showing
                busy ||= $game_temp && $game_temp.player_transferring
                busy ||= $game_temp && $game_temp.transition_processing
                busy ||= $game_system && $game_system.map_interpreter && $game_system.map_interpreter.running?
              rescue
              end
              unless busy
                @_rejuvfr_wait_frames ||= $rejuvfr_frames_before_prompt
                if @_rejuvfr_wait_frames > 0
                  @_rejuvfr_wait_frames -= 1
                else
                  @_rejuvfr_notified = true
                  info = $rejuvfr_update_info
                  $rejuvfr_update_info = nil
                  rejuvfr_prompt_and_apply(info)
                end
              end
            end
          rescue => e
            rejuvfr_log("Scene_Map update hook failed: #{e.class}: #{e.message}")
            @_rejuvfr_notified = true  # eviter boucle infinie sur erreur
          end
        end
      end
    end
  rescue => e
    rejuvfr_log("Hook install failed: #{e.class}: #{e.message}")
  end
  $VERBOSE = s
end
