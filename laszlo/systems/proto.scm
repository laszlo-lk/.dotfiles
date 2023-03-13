(define-module (laszlo systems proto)
  #:use-module (laszlo systems base)
  #:use-module (laszlo systems common)
  #:use-module (gnu home)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu services)
  #:use-module (gnu system)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (nongnu packages linux))

(define home
  (home-environment
   (packages (gather-manifest-packages '(emacs)))
   (services common-home-services)))

(define system
  (operating-system
   (inherit base-operating-system)
   (host-name "proto")

   (mapped-devices
    (list (mapped-device
           (source (uuid "eaba53d9-d7e5-4129-82c8-df28bfe6527e"))
           (target "system-root")
           (type luks-device-mapping))))

   (file-systems (cons*
                  (file-system
                   (device (file-system-label "system-root"))
                   (mount-point "/")
                   (type "ext4")
                   (dependencies mapped-devices))
                  (file-system
                   (device "/dev/nvme0n1p2")
                   (mount-point "/boot/efi")
                   (type "vfat"))
                  %base-file-systems))))

;; Return home or system config based on environment variable
(if (getenv "RUNNING_GUIX_HOME") home system)
