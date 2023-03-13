(define-module (laszlo home-services desktop)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:export (home-desktop-service-type))

(define (home-desktop-profile-service config)
  (map specification->package+output
       '(;; Sway setup
         "sway"
         "swayidle"
         "waybar"
         "fuzzel"
         "dunst"
         "gammastep"
         "flameshot"
         "qtwayland"                    ; For flameshot
	       "dbus"
	       "feh"
         ;; "glib:bin"                     ; For gsettings

         "flatpak"
         "xdg-desktop-portal"
         "xdg-desktop-portal-gtk"
         "xdg-desktop-portal-wlr"
         "xdg-utils"      ;; For xdg-open, etc
         "xdg-dbus-proxy"

         ;; TODO: Remove when Emacs service is working
         "emacs-next-pgtk"

         ;; Appearance
         "matcha-theme"
         "papirus-icon-theme"
         "breeze-icons" ;; For KDE apps

         ;; Fonts
         "font-jost"
         "font-iosevka-aile"
         "font-jetbrains-mono"
         "font-google-noto"
         "font-liberation"
         "font-mononoki"
         "font-awesome"
         "gucharmap"
         "fontmanager"

         "mcron"

         "qutebrowser"

         "password-store"

         "alsa-utils"
         "pavucontrol"

         "mpv"
         "mpv-mpris"
         "youtube-dl"
         "playerctl"
         "gimp"

         "zathura"
         "zathura-pdf-mupdf"

         "syncthing"
         "syncthing-gtk"

         "system-config-printer"
         "gtk+:bin"       ;; For gtk-launch
         "shared-mime-info"

         "curl"
         "wget"
         "virt-manager"
         "openssh"
         "zip"
         "unzip"
         "trash-cli")))

(define (home-desktop-shepherd-services config)
  (list
   ;; TODO: Use built-in syncthing service
   (shepherd-service
    (provision '(syncthing))
    (documentation "Run and control syncthing.")
    (start #~(make-forkexec-constructor '("syncthing" "-no-browser")))
    (stop #~(make-kill-destructor)))
   ;; TODO: Make this a separate service or reuse from RDE
   (shepherd-service
    (provision '(gpg-agent))
    (documentation "Run and control gpg-agent.")
    (start #~(make-system-constructor "gpg-connect-agent /bye"))
    (stop #~(make-system-destructor "gpgconf --kill gpg-agent")))))

(define home-desktop-service-type
  (service-type (name 'home-desktop)
                (description "My desktop environment service.")
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-desktop-profile-service)
                       (service-extension
                        home-shepherd-service-type
                        home-desktop-shepherd-services)))
                (default-value #f)))
