(define-module (laszlo systems common)
  #:use-module (laszlo home-services desktop)
  #:use-module (laszlo home-services udiskie)
  #:use-module (gnu services)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services mcron)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services desktop)
  #:use-module (guix gexp))

(define-public common-home-services
  (list
   ;; Set environment variables for every session
   (simple-service 'profile-env-vars-service
                   home-environment-variables-service-type
                   '( ;; Sort hidden (dot) files first in `ls` listings
                     ("LC_COLLATE" . "C")

                     ;; Emacs is our editor
                     ("VISUAL" . "emacsclient")
                     ("EDITOR" . "emacsclient")

                     ;; Add some things to $PATH (maybe integrate into other services?)
                     ("PATH" . "$HOME/.bin:$HOME/.npm-global/bin:$PATH")

                     ;; Make sure Flatpak apps are visible
                     ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")

                     ;; Make sure JAVA_HOME is set
                     ;; TODO:  Move this to a different service
                     ;; ("JAVA_HOME" . "$(dirname $(dirname $(readlink $(which java))))")

                     ;; Fix issues with Qutebrowser
                     ;; TODO: Move this to Qutebrowser service
                     ("QTWEBENGINE_CHROMIUM_FLAGS" . "--disable-seccomp-filter-sandbox")

                     ;; Set the SSH authentication socket
                     ;; TODO: Move to a gpg service
                     ("SSH_AUTH_SOCK" . "$(gpgconf --list-dirs agent-ssh-socket)")

                     ;; Set Wayland-specific environment variables (taken from RDE)
                     ("XDG_CURRENT_DESKTOP" . "sway")
                     ("XDG_SESSION_TYPE" . "wayland")
                     ("RTC_USE_PIPEWIRE" . "true")
                     ("SDL_VIDEODRIVER" . "wayland")
                     ("MOZ_ENABLE_WAYLAND" . "1")
                     ("CLUTTER_BACKEND" . "wayland")
                     ("ELM_ENGINE" . "wayland_egl")
                     ("ECORE_EVAS_ENGINE" . "wayland-egl")
                     ("QT_QPA_PLATFORM" . "wayland-egl")))

   ;; Set up the shell environment
   (service home-bash-service-type
            (home-bash-configuration
             (bash-profile
              `(,(plain-file "bash-profile-extras"
                             (string-append
                              ;; Load the Nix profile
                              "if [ -f /run/current-system/profile/etc/profile.d/nix.sh ]; then\n"
                              "  . /run/current-system/profile/etc/profile.d/nix.sh\n"
                              "fi\n"))))))

   ;; Run user dbus session
   (service home-dbus-service-type)

   ;; Set up desktop environment
   (service home-desktop-service-type)

   ;; Start background jobs
   (service home-mcron-service-type
            (home-mcron-configuration
             (jobs
              (list
               #~(job
                  '(next-hour (range 0 24 4))
                  "~/.dotfiles/.bin/sync-passwords")))))

   ;; Udiskie for auto-mounting devices
   (service home-udiskie-service-type)))
