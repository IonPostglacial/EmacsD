;;; init.el --- Some summary -*- lexical-binding: t -*-
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs
;;; Code:
(menu-bar-mode -1)
(tool-bar-mode -1)
(global-display-line-numbers-mode 1)
(show-paren-mode 1)
(save-place-mode 1)
(prefer-coding-system 'utf-8)
(setq tab-width 4)
(setq-default cursor-type 'bar)
(load-theme 'wombat)
(global-hl-line-mode t)
(set-face-attribute 'hl-line nil :inherit nil :background "gray6")
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-z") 'zap-up-to-char)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(setq-default indent-tabs-mode nil)
(savehist-mode 1)
(setq save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t
      require-final-newline t
      visible-bell t
      load-prefer-newer t
      backup-by-copying t
      frame-inhibit-implied-resize t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t
      ediff-window-setup-function 'ediff-setup-windows-plain
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless backup-directory-alist
  (setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                                 "backups")))))

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
	ivy-count-format "%d/%d "))

(use-package swiper :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package projectile
  :ensure t
    :init
    (setq projectile-project-search-path '("~/Workspace/" "~/Documents/Code"))
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package flycheck
  :ensure t
  :config (global-flycheck-mode))

;;; Treesitter Config:

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (rust "https://github.com/tree-sitter/tree-sitter-rust")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (vue "https://github.com/ikatyang/tree-sitter-vue")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
(setq auto-mode-alist
  (append
   ;; File name (within directory) starts with a dot.
   '(("\\.ts\\'" . typescript-ts-mode)
     ("\\.go\\'" . go-ts-mode))
   auto-mode-alist))
(setq major-mode-remap-alist
 '((yaml-mode . yaml-ts-mode)
   (bash-mode . bash-ts-mode)
   (js2-mode . js-ts-mode)
   (json-mode . json-ts-mode)
   (css-mode . css-ts-mode)
   (python-mode . python-ts-mode)))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  :init
  (global-corfu-mode))

(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)
 
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

;;; Vue Config:
(add-to-list 'load-path (concat user-emacs-directory "vue-ts-mode"))
(use-package vue-ts-mode)
(defun vue-eglot-init-options ()
  (let ((tsdk-path (expand-file-name
                    "lib"
                    (getenv "TYPESCRIPT_PATH"))))
    `(:typescript (:tsdk ,tsdk-path)
                    :vue (:hybridMode :json-false)
                    :languageFeatures (:completion
                                       (:defaultTagNameCase "both"
                                                            :defaultAttrNameCase "kebabCase"
                                                            :getDocumentNameCasesRequest nil
                                                            :getDocumentSelectionRequest nil)
                                       :diagnostics
                                       (:getDocumentVersionRequest nil))
                    :documentFeatures (:documentFormatting
                                       (:defaultPrintWidth 100
                                                           :getDocumentPrintWidthRequest nil)
                                       :documentSymbol t
                                       :documentColor t))))

;;; LSP Config:
(use-package eglot
  :hook
  (python-base-mode-hook . eglot-ensure)
  (go-ts-mode-hook . eglot-ensure)
  (js-ts-mode . eglot-ensure)
  (tsx-ts-mode . eglot-ensure)
  (typescript-ts-mode . eglot-ensure)
  (vue-ts-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               `(vue-ts-mode . ("vue-language-server" "--stdio" :initializationOptions ,(vue-eglot-init-options))))
  )

(provide 'init)
;;; init.el ends here
