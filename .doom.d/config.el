;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Ibrahim Muftee"
      user-mail-address "ibrahim@ibrahimmuftee.xyz")

(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil) ; default is 7200 (2h)

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…"                ; Unicode ellispis are nicer than "...", and also save /precious/ space
      password-cache-expiry nil                   ; I can trust my computers ... can't I?
      scroll-margin 2)                            ; It's nice to maintain a little margin

(display-time-mode 1)                             ; Enable time in the mode-line

(unless (string-match-p "^Power N/A" (battery))   ; On laptops...
  (display-battery-mode 1))                       ; it's nice to know how much power you have

(global-subword-mode 1)                           ; Iterate through CamelCase words

;; Better default buffer names
(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")

(setq doom-font (font-spec :family "Iosevka" :size 13 :weight 'regular)
      doom-big-font (font-spec :family "Iosevka" :size 24 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Iosevka Aile" :size 13))

(setq doom-theme 'doom-nord)

(setq display-line-numbers-type 'relative)

(add-hook 'dired-mode-hook 'auto-revert-mode)

(use-package! emacs-everywhere
  :if (daemonp)
  :config
  (require 'spell-fu)
  (setq emacs-everywhere-major-mode-function 'org-mode
        emacs-everywhere-frame-name-format "Edit ∷ %s — %s")
  (defadvice! emacs-everywhere-raise-frame ()
    :after 'emacs-everywhere-set-frame-name
    (setq emacs-everywhere-frame-name (format emacs-everywhere-frame-name-format
                                (emacs-everywhere-app-class emacs-everywhere-current-app)
                                (truncate-string-to-width
                                 (emacs-everywhere-app-title emacs-everywhere-current-app)
                                 45 nil nil "…")))
    ;; need to wait till frame refresh happen before really set
    (run-with-timer 0.1 nil 'emacs-everywhere-raise-frame-1))
  (defun emacs-everywhere-raise-frame-1 ()
    (call-process "wmctrl" nil nil nil "-a" emacs-everywhere-frame-name)))

(use-package! elfeed-goodies)
(elfeed-goodies/setup)
(setq elfeed-goodies/entry-pane-size 0.5)
(add-hook 'elfeed-show-mode-hook 'visual-line-mode)
(add-hook! 'elfeed-search-mode-hook 'elfeed-update)
(evil-define-key 'normal elfeed-show-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(evil-define-key 'normal elfeed-search-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)

(emms-all)
(emms-default-players)
(emms-mode-line 1)
(emms-playing-time 1)
(setq emms-source-file-default-directory "~/music/"
      emms-playlist-buffer-name "*Music*"
      emms-info-asynchronously t
      emms-source-file-directory-tree-function 'emms-source-file-directory-tree-find)
(map! :leader
      (:prefix ("a" . "EMMS audio player")
       :desc "Go to emms playlist" "a" #'emms-playlist-mode-go
       :desc "Emms pause track" "x" #'emms-pause
       :desc "Emms stop track" "s" #'emms-stop
       :desc "Emms play previous track" "p" #'emms-previous
       :desc "Emms play next track" "n" #'emms-next))

(setq flycheck-disabled-checkers
      '(c/c++-gcc))

(use-package! mu4e
  :config
  (setq mu4e-change-filenames-when-moving t) ;; This is set to 't' to avoid mail syncing issues when using mbsync

  (setq mu4e-update-interval (* 10 60)) ;; Refresh mail using isync every 10 minutes
  (setq mu4e-get-mail-command "mbsync -a")
  ;; (setq mu4e-maildir "~/.mail")
  (setq user-mail-address "ibrahim@ibrahimmuftee.xyz")

  (setq mu4e-contexts
        (list
         ;; Personal account
         (make-mu4e-context
          :name "Personal"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/Personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "ibrahim@ibrahimmuftee.xyz")
                  (user-full-name    . "Ibrahim Muftee")
                  (smtpmail-smtp-server . "mail.ibrahimmuftee.xyz")
                  (smtpmail-smtp-service . 587)
                  (mu4e-drafts-folder  . "/Personal/Drafts")
                  (mu4e-sent-folder  . "/Personal/Sent")
                  (mu4e-refile-folder  . "/Personal/Archive")
                  (mu4e-trash-folder  . "/Personal/Trash")))))

  (setq mu4e-maildir-shortcuts
      '(("/Personal/Inbox"             . ?i)
        ("/Personal/Sent"              . ?s)
        ("/Personal/Trash"             . ?t)
        ("/Personal/Drafts"            . ?d)
        ("/Personal/Archive"           . ?a))))

(setq message-send-mail-function 'smtpmail-send-it) ;; Configure the function to use for sending mail

(setq mu4e-compose-format-flowed t) ;; Make sure plain text mails flow correctly for recipients

(setq mu4e-compose-signature ;; My email signature
 (concat
  "Ibrahim Muftee\n"
  "http://ibrahimmuftee.xyz"))

(add-hook 'message-send-hook 'mml-secure-message-sign-pgpmime) ;; Automatically sign every email

(setq mml-secure-openpgp-signers '("0xA31B5819437230ED"));; Use a specific key for signing by referencing its thumbprint.

;; Add option to open email in browser
(add-to-list 'mu4e-view-actions
  '("View in Browser" . mu4e-action-view-in-browser) t)

(setq browse-url-browser-function 'browse-url-generic)
(setq browse-url-generic-program "google-chrome-stable")

(setq org-directory "~/dox/org/")

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(defun di/org-mode-setup ()
  (org-indent-mode)
  (visual-line-mode 1))

(defun di/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be doom-font in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'doom-font)
  (set-face-attribute 'org-code nil   :inherit '(shadow doom-font))
  (set-face-attribute 'org-table nil   :inherit '(shadow doom-font))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow doom-font))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face doom-font))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face doom-font))
  (set-face-attribute 'org-checkbox nil :inherit 'doom-font))

(use-package! org
  :hook (org-mode . di/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (di/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun di/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package! visual-fill-column
  :hook (org-mode . di/org-mode-visual-fill))

(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-heigth t)
  (set-face-attribute 'variable-pitch nil :height 1.3))

(use-package! quickrun
  :config
  (map! :leader
        :desc "Run current buffer"
        "q r" #'quickrun))
