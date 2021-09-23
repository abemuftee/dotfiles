;;; init.el --- Description -*- lexical-binding: t; -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("234dbb732ef054b109a9e5ee5b499632c63cc24f7c2383a849815dacc1727cb6" "d268b67e0935b9ebc427cad88ded41e875abfcc27abd409726a92e55459e0d01" "f91395598d4cb3e2ae6a2db8527ceb83fed79dbaf007f435de3e91e5bda485fb" "1704976a1797342a1b4ea7a75bdbb3be1569f4619134341bd5a4c1cfb16abad4" default))
 '(ivy-mode t)
 '(package-selected-packages
   '(emacs-everywhere auto-package-update cdlatex auctex org-roam eshell-git-prompt vterm lsp-java lsp-mode mu4e ivy-rich all-the-icons evil-collection evil general helpful toc-org evil-org smex visual-fill-column org-bullets forge evil-commentary evil-commentrary evil-magit magit counsel-projectile projectile undo-fu which-key rainbow-delimiters counsel doom-modeline use-package ivy command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
