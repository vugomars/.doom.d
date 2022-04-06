;;;###autoload
(defun dqv/edit-zsh-configuration ()
  (interactive)
  (find-file "~/.zshrc"))

;;;###autoload
(defun dqv/use-eslint-from-node-modules ()
    "Set local eslint if available."
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (eslint (and root
                        (expand-file-name "node_modules/eslint/bin/eslint.js"
                                          root))))
      (when (and eslint (file-executable-p eslint))
        (setq-local flycheck-javascript-eslint-executable eslint))))

;;;###autoload
(defun dqv/goto-match-paren (arg)
  "Go to the matching if on (){}[], similar to vi style of % ."
  (interactive "p")
  (cond ((looking-at "[\[\(\{]") (evil-jump-item))
        ((looking-back "[\]\)\}]" 1) (evil-jump-item))
        ((looking-at "[\]\)\}]") (forward-char) (evil-jump-item))
        ((looking-back "[\[\(\{]" 1) (backward-char) (evil-jump-item))
        (t nil)))

;;;###autoload
(defun dqv/string-inflection-cycle-auto ()
  "switching by major-mode"
  (interactive)
  (cond
   ;; for emacs-lisp-mode
   ((eq major-mode 'emacs-lisp-mode)
    (string-inflection-all-cycle))
   ;; for python
   ((eq major-mode 'python-mode)
    (string-inflection-python-style-cycle))
   ;; for java
   ((eq major-mode 'java-mode)
    (string-inflection-java-style-cycle))
   (t
    ;; default
    (string-inflection-all-cycle))))

;; Current time and date
(defvar current-date-time-format "%Y-%m-%d %H:%M:%S"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defvar current-time-format "%H:%M:%S"
  "Format of date to insert with `insert-current-time' func.
Note the weekly scope of the command's precision.")

;;;###autoload
(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-date-time-format (current-time)))
  )

;;;###autoload
(defun insert-current-time ()
  "insert the current time (1-week scope) into the current buffer."
  (interactive)
  (insert (format-time-string current-time-format (current-time)))
  )

;;;###autoload
(defun my/capitalize-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat (capitalize first-char) rest-str))))

;;;###autoload
(defun my/lowcase-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat first-char rest-str))))

;;;###autoload
(defun dqv/async-shell-command-silently (command)
  "async shell command silently."
  (interactive)
  (let
      ((display-buffer-alist
        (list
         (cons
          "\\*Async Shell Command\\*.*"
          (cons #'display-buffer-no-window nil)))))
    (async-shell-command
     command)))

;;;###autoload
(defun dqv/embrace-prog-mode-hook ()
  (dolist (lst '((?` "`" . "`")))
    (embrace-add-pair (car lst) (cadr lst) (cddr lst))))

;;;###autoload
(defun dqv/embrace-org-mode-hook ()
  (dolist (lst '((?c "@@html:<font color=\"red\">" . "</font>@@")))
    (embrace-add-pair (car lst) (cadr lst) (cddr lst))))

;;;###autoload
(defun dqv/indent-org-block-automatically ()
  (interactive)
  (when (org-in-src-block-p)
    (org-edit-special)
    (indent-region (point-min) (point-max))
    (org-edit-src-exit)))

;;;###autoload
(defun dqv/org-html-export-to-html
    (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let* ((extension (concat "." org-html-extension))
         (file (org-export-output-file-name extension subtreep "~/.my-blog/posts/"))
         (org-export-coding-system org-html-coding-system))
    (if async
        (org-export-async-start
            (lambda (f) (org-export-add-to-stack f 'html))
          (let ((org-export-coding-system org-html-coding-system))
            `(expand-file-name
              (org-export-to-file
                  'html ,file ,subtreep ,visible-only ,body-only ',ext-plist))))
      (let ((org-export-coding-system org-html-coding-system))
        (org-export-to-file
            'html file subtreep visible-only body-only ext-plist)))))

(defun dqv/org-pandoc-export (format a s v b e &optional buf-or-open)
  "General interface for Pandoc Export.
If BUF-OR-OPEN is nil, output to file.  0, then open the file.
t means output to buffer."
  (unless (derived-mode-p 'org-mode)
    (error "This command must be run on an org-mode buffer"))
  (unless (executable-find org-pandoc-command)
    (error "Pandoc (version 1.12.4 or later) can not be found"))
  (setq org-pandoc-format format)
  (org-export-to-file 'pandoc (concat "~/.my-blog/posts/rst/"
                                      (org-export-output-file-name
                                       (concat (make-temp-name ".tmp") ".org") s))
    a s v b e (lambda (f) (org-pandoc-run-to-buffer-or-file f format s buf-or-open))))

;;;###autoload
(defun dqv/org-pandoc-export-to-rst (&optional a s v b e)
  "Export to rst."
  (interactive) (dqv/org-pandoc-export 'rst a s v b e))

;;;###autoload
(defun dired-timesort (filename &optional wildcards)
  (let ((dired-listing-switches "-lhat"))
    (dired filename wildcards)))

;;;###autoload
(defmacro quick-find (key file &optional path find-args)
  `(bind-key
    ,key
    (cond
     ((stringp ,find-args)
      '(lambda (&optional arg)
         (interactive)
         (find-dired (expand-file-name ,file ,path) ,find-args)))
     ((and
       ;; (not (tramp-tramp-file-p (expand-file-name ,file ,path)))
       (or (file-directory-p (expand-file-name ,file ,path))
           (not (file-exists-p (expand-file-name ,file ,path)))))
      '(lambda (&optional arg)
         (interactive)
         (dired-timesort (expand-file-name ,file ,path))))
     (t
      '(lambda (&optional arg)
         (interactive)
         (find-file (expand-file-name ,file ,path)))))
    ))

(setq doom-font (font-spec :family "Fira Code Retina" :size 17 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Roboto Mono" :style "Regular" :size 14 :weight 'regular))
;; (setq doom-theme 'spacemacs-light)
(setq doom-theme 'doom-dracula)

(defun dqv/org-mode-visual-fill ()
  (setq visual-fill-column-width 120
        visual-fill-column-center-text t
        )
  (visual-fill-column-mode 1)
  )

(use-package! visual-fill
  :hook (org-mode . dqv/org-mode-visual-fill))

(delete-selection-mode t)
(setq
 ;; private information
 user-full-name "Dang Quang Vu"
 user-mail-address "vugomars@gmail.com"
 user-blog-url "https://www.buntech.io"
 user-dot-directory "~/.dqvrc/"

 warning-minimum-level :error
 ;; exit no confirm
 confirm-kill-emacs nil

 display-line-numbers-type nil
 org-directory "~/.dqvrc/org/"
 org-roam-directory "~/.dqvrc/org/roam/"

 ;; lsp
 lsp-ui-sideline-enable nil
 lsp-ui-doc-enable nil
 lsp-enable-symbol-highlighting nil
 +lsp-prompt-to-install-server 'quiet

 ;; export
 org-html-doctype "html5"
 )

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-hook 'org-mode-hook 'turn-on-auto-fill)

(setq emacs-everywhere-frame-name-format "emacs-anywhere")
(remove-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)

;; Semi-center it over the target window, rather than at the cursor position
;; (which could be anywhere).
(defadvice! center-emacs-everywhere-in-origin-window (frame window-info)
  :override #'emacs-everywhere-set-frame-position
  (cl-destructuring-bind (x y width height)
      (emacs-everywhere-window-geometry window-info)
    (set-frame-position frame
                        (+ x (/ width 2) (- (/ width 2)))
                        (+ y (/ height 2)))))

(global-set-key (kbd "<f1>") nil)        ; ns-print-buffer
(global-set-key (kbd "<f2>") nil)        ; ns-print-buffer
(define-key evil-normal-state-map (kbd ",") nil)
(define-key evil-visual-state-map (kbd ",") nil)

(global-set-key (kbd "<f1>") 'dqv-everything/body)
(global-set-key (kbd "<f2>") 'rgrep)
(global-set-key (kbd "<f5>") 'deadgrep)
(global-set-key (kbd "<M-f5>") 'deadgrep-kill-all-buffers)
;; (global-set-key (kbd "<f8>") 'quickrun)
(global-set-key (kbd "<f12>") 'smerge-vc-next-conflict)
(global-set-key (kbd "<S-f12>") '+vc/smerge-hydra/body)
(global-set-key (kbd "M-z") 'zzz-to-char)
;; (global-set-key (kbd "C-t") '+vterm/toggle)
;; (global-set-key (kbd "C-S-t") '+vterm/here)
;; (global-set-key (kbd "C-d") 'kill-current-buffer)
;; (avy-setup-default)
;; (global-set-key (kbd "C-c C-j") 'avy-resume)

(setq doom-localleader-key ",")
(map!
 ;; avy
 :nv    "F"     #'avy-goto-char-2
 :nv    "f"     #'avy-goto-char
 :nv    "w"     #'avy-goto-word-1
 :nv    "W"     #'avy-goto-word-0

 :nv    "-"     #'evil-window-decrease-width
 :nv    "+"     #'evil-window-increase-width
 :nv    "C--"   #'evil-window-decrease-height
 :nv    "C-+"   #'evil-window-increase-height

 :nv    ")"     #'sp-forward-sexp
 :nv    "("     #'sp-backward-up-sexp
 :nv    "s-)"   #'sp-down-sexp
 :nv    "s-("   #'sp-backward-sexp
 :nv    "gd"    #'xref-find-definitions
 :nv    "gD"    #'xref-find-references
 :nv    "gb"    #'xref-pop-marker-stack
 :nv    "gj"    #'switch-to-next-buffer
 :nv    "gk"    #'switch-to-prev-buffer

 :niv   "C-e"   #'evil-end-of-line
 :niv   "C-="   #'er/expand-region

 "C-;"          #'web-mode-navigate
 "C-a"          #'crux-move-beginning-of-line
 "C-s"          #'+default/search-buffer

 "C-c C-j"      #'avy-resume
 "C-c c x"      #'org-capture
 ;; "C-c c j"      #'avy-resume

 "C-c f r"      #'dqv/indent-org-block-automatically

 "C-c h h"      #'dqv/org-html-export-to-html

 "C-c i d"      #'insert-current-date-time
 "C-c i t"      #'insert-current-time
 ;; "C-c i d"      #'crux-insert-date
 "C-c i e"      #'emojify-inert-emoji
 "C-c i f"      #'js-doc-insert-function-doc
 "C-c i F"      #'js-doc-insert-file-doc

 "C-c o o"      #'crux-open-with
 "C-c o u"      #'crux-view-url
 "C-c o t"      #'crux-visit-term-buffer
 ;; org-roam
 "C-c o r o"    #'org-roam-ui-open

 "C-c r r"      #'vr/replace
 "C-c r q"      #'vr/query-replace

 "C-c y y"      #'youdao-dictionary-search-at-point+

 ;; Command/Window
 "s-k"          #'move-text-up
 "s-j"          #'move-text-down
 "s-i"          #'dqv/string-inflection-cycle-auto
 ;; "s--"          #'sp-splice-sexp
 ;; "s-_"          #'sp-rewrap-sexp

 "M-i"          #'parrot-rotate-next-word-at-point
 "M--"          #'dqv/goto-match-paren
 )

(map! :leader
      :n "SPC"  #'execute-extended-command
      (:prefix ("d" . "Dir&Deletion")
       :n    "d"    #'deft)

      (:prefix ("e" . "Edit&Errors")
       ;; :n    "l"     #'lsp-treemacs-errors-list
       )


      (:prefix ("m" . "Treemacs")
       :n     "t"           #'treemacs
       :n     "df"           #'treemacs-delete-file
       :n     "dp"           #'treemacs-remove-project-from-workspace
       :n     "cd"           #'treemacs-create-dir
       :n     "cf"           #'treemacs-create-file
       :n     "a"           #'treemacs-add-project-to-workspace
       :n     "wc"           #'treemacs-create-workspace
       :n     "ws"           #'treemacs-switch-workspace
       :n     "wd"           #'treemacs-remove-workspace
       :n     "wf"           #'treemacs-rename-workspace
       )

      :nv "w -" #'evil-window-split
      :nv "j" #'switch-to-buffer
      :nv "wo" #'delete-other-windows

      :nv "ls" #'+lsp/switch-client
      :nv "bR" #'rename-buffer

      )

(map! :map org-mode-map
      ;; t
      :nv "tt"          #'org-todo
      :nv "tT"          #'counsel-org-tag

      :nv "tcc"         #'org-toggle-checkbox
      :nv "tcu"         #'org-update-checkbox-count

      :nv "tpp"         #'org-priority
      :nv "tpu"         #'org-priority-up
      :nv "tpd"         #'org-priority-down


      ;; C-c
      "C-c a t" #'org-transclusion-add
      ;; #'org-transclusion-mode
      "C-c c i" #'org-clock-in
      "C-c c o" #'org-clock-out
      "C-c c h" #'counsel-org-clock-history
      "C-c c g" #'counsel-org-clock-goto
      "C-c c c" #'counsel-org-clock-context
      "C-c c r" #'counsel-org-clock-rebuild-history
      "C-c c p" #'org-preview-html-mode

      "C-c f r" #'dqv/indent-org-block-automatically

      "C-c e e" #'all-the-icons-insert
      "C-c e a" #'all-the-icons-insert-faicon
      "C-c e f" #'all-the-icons-insert-fileicon
      "C-c e w" #'all-the-icons-insert-wicon
      "C-c e o" #'all-the-icons-insert-octicon
      "C-c e m" #'all-the-icons-insert-material
      "C-c e i" #'all-the-icons-insert-alltheicon

      "C-c g l" #'org-mac-grab-link

      "C-c i u" #'org-mac-chrome-insert-frontmost-url
      "C-c i c" #'copyright
      "C-c i D" #'o-docs-insert

      ;; `C-c s' links & search-engine
      "C-c l l" #'org-super-links-link
      "C-c l L" #'org-super-links-insert-link
      "C-c l s" #'org-super-links-store-link
      "C-c l d" #'org-super-links-quick-insert-drawer-link
      "C-c l i" #'org-super-links-quick-insert-inline-link
      "C-c l D" #'org-super-links-delete-link
      "C-c l b" #'org-mark-ring-goto

      "C-c q s" #'org-ql-search
      "C-c q v" #'org-ql-view
      "C-c q b" #'org-ql-sidebar
      "C-c q r" #'org-ql-view-recent-items
      "C-c q t" #'org-ql-sparse-tree

      "C-c r f" #'org-refile-copy ;; copy current entry to another heading
      "C-c r F" #'org-refile ;; like `org-refile-copy' but moving

      "C-c w m" #'org-mind-map-write
      "C-c w M" #'org-mind-map-write-current-tree

      ;; org-roam, org-ref
      ;; "C-c n l" #'org-roam-buffer-toggle
      ;; "C-c n f" #'org-roam-node-find
      ;; "C-c n g" #'org-roam-graph
      ;; "C-c n i" #'org-roam-node-insert
      ;; "C-c n c" #'org-roam-capture
      ;; "C-c n j" #'org-roam-dailies-capture-today
      "C-c n r a" #'org-roam-ref-add
      "C-c n r f" #'org-roam-ref-find
      "C-c n r d" #'org-roam-ref-remove
      "C-c n r c" #'org-ref-insert-cite-link
      "C-c n r l" #'org-ref-insert-label-link
      "C-c n r i" #'org-ref-insert-link
      "C-c n b c" #'org-bibtex-check-all
      "C-c n b a" #'org-bibtex-create
      )

(quick-find "C-h C-x C-s" "~/.ssh/config")
(quick-find "C-h C-x C-z" "~/.zshrc")
(quick-find "C-h C-x C-c" "~/.doom.d/config.org")

;; (dolist (hook '(erc-mode-hook
 ;;                 emacs-lisp-mode-hook
 ;;                 text-mode-hook))
 ;;   (add-hook hook #'abbrev-mode))
(add-hook 'doom-first-buffer-hook
          (defun +abbrev-file-name ()
            (setq-default abbrev-mode t)
            (setq abbrev-file-name (expand-file-name "abbrev.el" doom-private-dir))))

(use-package! pdf-view
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :config
  (setq pdf-view-midnight-colors '("#ABB2BF" . "#282C35")))

(use-package! org-alert
  :ensure t
  :custom (alert-default-style 'notifications)
  :config
  (setq org-alert-interval 300
        org-alert-notification-title "Org Alert Reminder!")
  (org-alert-enable))

(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; select buffer when split window
;; (defadvice! prompt-for-buffer (&rest _)
;;   :after '(evil-window-split evil-window-vsplit)
;;   (consult-buffer))

(use-package! graphviz-dot-mode)

(add-hook 'after-init-hook #'global-prettier-mode)
(setenv "NODE_PATH" "/usr/local/lib/node_modules")

(add-hook 'typescript-mode-hook 'deno-fmt-mode)
(add-hook 'js2-mode-hook 'deno-fmt-mode)

(use-package! svg-lib
  :after org-mode)

(use-package! svg-tag-mode
  :after org-mode
  :config
  (setq svg-tag-tags
      '(
        (":TODO:" . ((lambda (tag) (svg-tag-make "TODO"))))
        ("\\(:[A-Z]+:\\)" . ((lambda (tag)
                               (svg-tag-make tag :beg 1 :end -1))))
        (":HELLO:" .  ((lambda (tag) (svg-tag-make "HELLO"))
                       (lambda () (interactive) (message "Hello world!"))
                       "Print a greeting message"))
        ("\\(:#[A-Za-z0-9]+\\)" . ((lambda (tag)
                                     (svg-tag-make tag :beg 2))))
        ("\\(:#[A-Za-z0-9]+:\\)$" . ((lambda (tag)
                                       (svg-tag-make tag :beg 2 :end -1))))
        )))

(use-package! devdocs
  :after lsp
  :config
  (add-hook! 'devdocs-mode-hook
    (face-remap-add-relative 'variable-pitch '(:family "Noto Sans"))))

(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-face 'variable-pitch))

(global-pangu-spacing-mode 1)
;; insert whitespace in some specific mode
(add-hook 'org-mode-hook
           #'(lambda ()
               (set (make-local-variable 'pangu-spacing-real-insert-separtor) t)))

(defhydra dqv-repl-hydra (:color blue :columns 3 :hint nil)
  "REPL "
  ("e" ielm " ELisp")
  ("h" httprepl " HTTP")
  ("j" jq-interactivly " JSON")
  ("l" +lua/open-repl " Lua")
  ("n" nodejs-repl " Node.js")
  ("p" +python/open-repl " Python")
  ("s" skewer-repl " Skewer"))

(defhydra dqv-roam-ui-hydra (:color green)
  "Org Roam UI."
  ("t" orui-sync-theme "Sync Theme"))
(defhydra dqv-launcher-hydra (:color blue :columns 3)
   "Launch"
   ("h" man "man")
   ("b" (browse-url "https://www.buntech.io") "my-blog")
   ("r" (browse-url "http://www.reddit.com/r/emacs/") "reddit")
   ("w" (browse-url "http://www.emacswiki.org/") "emacswiki")
   ("s" shell "shell")
   ("q" nil "cancel"))

(defhydra dqv-everything (:color blue :columns 3 :hint nil)
  "🗯 Do Everything~~~~ 👁👁👁👁👁👁👁👁👁
🌻"
  ("r" dqv-repl-hydra/body "REPL")
  ("l" dqv-launcher-hydra/body "Launch")
  ("1" dqv-roam-ui-hydra/body "Roam")
  ("i" org-ref-insert-link-hydra/body "Org Ref Link"))

(use-package! lsp-mode
  :commands lsp
  :config
  (setq lsp-idle-delay 0.2
        lsp-enable-file-watchers nil
        lsp-prefer-capf t
        lsp-eldoc-render-all t
        )
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)

  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)

  (add-to-list 'lsp-language-id-configuration '(js-jsx-mode . "javascriptreact"))
  )

(use-package! lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-headerline-breadcrumb-enable t ;
        lsp-lens-enable t                  ;
        )
  :bind (:map lsp-ui-mode-map
         ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
         ([remap xref-find-references] . lsp-ui-peek-find-references)
         ([remap xref-pop-marker-stack] . lsp-ui-peek-jump-backward)
         )
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil)
  )

;; lsp format use prettier
(add-hook! 'after-init-hook
           (progn
  (setq-hook! 'typescript-mode-hook +format-with :nil)
  (add-hook! 'typescript-mode-hook 'prettier-mode)
  (setq-hook! 'rjsx-mode-hook +format-with :nil)
  (add-hook! 'rjsx-mode-hook 'prettier-mode)
  (setq-hook! 'js2-mode-hook +format-with :nil)
  (add-hook! 'js2-mode-hook 'prettier-mode)
  (setq-hook! 'typescript-tsx-mode-hook +format-with :nil)
  (add-hook! 'typescript-tsx-mode-hook 'prettier-mode)
  ))

(use-package! lsp-volar)

(after! which-key
  (setq! which-key-idle-delay 0.1
         which-key-idle-secondary-delay 0.2))

;; dont display evilem-...
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))
   ))

(use-package! visual-fill-column)

(use-package! maple-iedit
   :commands (maple-iedit-match-all maple-iedit-match-next maple-iedit-match-previous)
   :config
   (delete-selection-mode t)
   (setq maple-iedit-ignore-case t)
   (defhydra maple/iedit ()
     ("n" maple-iedit-match-next "next")
     ("t" maple-iedit-skip-and-match-next "skip and next")
     ("T" maple-iedit-skip-and-match-previous "skip and previous")
     ("p" maple-iedit-match-previous "prev"))
   :bind (:map evil-visual-state-map
          ("n" . maple/iedit/body)
          ("C-n" . maple-iedit-match-next)
          ("C-p" . maple-iedit-match-previous)
          ("C-t" . map-iedit-skip-and-match-next)
          ("C-T" . map-iedit-skip-and-match-previous)))

;; (when (memq window-system '(mac ns x))
;; (exec-path-from-shell-initialize))

(use-package! color-rg
  :commands (color-rg-search-input
             color-rg-search-symbol
             color-rg-search-input-in-project)
  :bind
  (:map isearch-mode-map
   ("M-s M-s" . isearch-toggle-color-rg)))

(use-package! visual-regexp
  :commands (vr/select-replace vr/select-query-replace))

(use-package! visual-regexp-steriods
  :commands (vr/select-replace vr/select-query-replace))

(use-package! dash-at-point
  :bind
  (("C-c d d" . dash-at-point)
   ("C-c d D" . dash-at-point-with-docset)))

(after! company
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2)
  (add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; make aborting less annoying.

(use-package! counsel-osx-app
  :bind* ("S-M-SPC" . counsel-osx-app)
  :commands counsel-osx-app
  :config
  (setq counsel-osx-app-location
        (list "/Applications"
              "/Applications/Misc"
              "/Applications/Utilities"
              (expand-file-name "~/Applications")
              (expand-file-name "~/.nix-profile/Applications")
              "/Applications/Xcode.app/Contents/Applications")))

(use-package! cycle-quotes
  :bind
  ("C-'" . cycle-quotes))

(use-package! dotenv-mode
  :mode ("\\.env\\.?.*\\'" . dotenv-mode))

(use-package! emacs-everywhere
  :if (daemonp)
  :config
  (require 'spell-fu)
  (setq emacs-everywhere-major-mode-function #'org-mode
        emacs-everywhere-frame-name-format "Edit ∷ %s — %s")
  (defadvice! emacs-everywhere-raise-frame ()
    :after #'emacs-everywhere-set-frame-name
    (setq emacs-everywhere-frame-name (format emacs-everywhere-frame-name-format
                                (emacs-everywhere-app-class emacs-everywhere-current-app)
                                (truncate-string-to-width
                                 (emacs-everywhere-app-title emacs-everywhere-current-app)
                                 45 nil nil "…")))
    ;; need to wait till frame refresh happen before really set
    (run-with-timer 0.1 nil #'emacs-everywhere-raise-frame-1))
  (defun emacs-everywhere-raise-frame-1 ()
    (call-process "wmctrl" nil nil nil "-a" emacs-everywhere-frame-name)))

(use-package engine-mode
  :config
  (engine/set-keymap-prefix (kbd "C-c s"))
  (setq browse-url-browser-function 'browse-url-default-macosx-browser
        engine/browser-function 'browse-url-default-macosx-browser
        ;; browse-url-generic-program "google-chrome"
        )
  (defengine duckduckgo
    "https://duckduckgo.com/?q=%s"
    :keybinding "d")

  (defengine github
    "https://github.com/search?ref=simplesearch&q=%s"
    :keybinding "sh")

  (defengine gitlab
    "https://gitlab.com/search?search=%s&group_id=&project_id=&snippets=false&repository_ref=&nav_source=navbar"
    :keybinding "sl")

  (defengine stack-overflow
    "https://stackoverflow.com/search?q=%s"
    :keybinding "o")

  (defengine npm
    "https://www.npmjs.com/search?q=%s"
    :keybinding "n")

  (defengine crates
    "https://crates.io/search?q=%s"
    :keybinding "c")

  (defengine localhost
    "http://localhost:%s"
    :keybinding "l")

  (defengine translate
    "https://translate.google.com/?sl=en&tl=vi&text=%s&op=translate"
    :keybinding "t")

  (defengine youtube
    "http://www.youtube.com/results?aq=f&oq=&search_query=%s"
    :keybinding "y")

  (defengine google
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s"
    :keybinding "g")

  (engine-mode 1))

(use-package! flycheck
    :config
    (add-hook 'after-init-hook 'global-flycheck-mode)
    (add-hook 'flycheck-mode-hook 'dqv/use-eslint-from-node-modules))

(use-package! js-doc
  :bind (:map js2-mode-map
         ("@" . js-doc-insert-tag))
  :config
  (setq js-doc-mail-address user-mail-address
       js-doc-author (format "%s<%s>" user-full-name js-doc-mail-address)
       js-doc-url user-blog-url
       js-doc-license "MIT"))

(after! leetcode
  (setq leetcode-prefer-language "javascript"
        leetcode-prefer-sql "mysql"
        leetcode-save-solutions t
        leetcode-directory "~/github/mine/make-leetcode"))

(setq auto-insert 'other
      auto-insert-query nil
      auto-insert-directory (concat doom-private-dir "auto-insert-templates")
      auto-insert-alist '(
                          ("\\.\\([Hh]\\|hh\\|hpp\\)\\'" . "template.h")
                          ("\\.\\(jsx?\\|tsx?\\)\\'" . "my.js")
                          ("\\.\\(vue\\)\\'" . "my.vue")
                          ))
(add-hook 'find-file-hook #'auto-insert)

(sp-local-pair
 '(org-mode)
 "<<" ">>"
 :actions '(insert))

(use-package! smartparens
  :init
  (map! :map smartparens-mode-map
       "C-)" #'sp-forward-slurp-sexp
       "C-(" #'sp-forward-barf-sexp
       "C-{" #'sp-backward-slurp-sexp
       "C-}" #'sp-backward-barf-sexp
       "s--" #'sp-splice-sexp
       "s-_" #'sp-rewrap-sexp
       ))

(use-package! popper
  :bind
  ("C-`" . popper-toggle-latest)
  ("C-~" . popper-cycle)
  ("C-s-`" . popper-kill-latest-popup)
  :custom
  (popper-reference-buffers
   '("*eshell*"
     "*vterm*"
     "*color-rg*"
     "Output\\*$"
     "*Process List*"
     "COMMIT_EDITMSG"
     embark-collect-mode
     deadgrep-mode
     grep-mode
     rg-mode
     rspec-compilation-mode
     inf-ruby-mode
     nodejs-repl-mode
     ts-comint-mode
     compilation-mode))
  :config
  (defun zero-point-thirty-seven () 0.37)
  (advice-add 'popper-determine-window-height :override #'zero-point-thirty-seven)
  :init
  (popper-mode)
  )

;; https://github.com/dp12/parrot
(use-package! parrot
  :config
  (parrot-mode))

;; apend
(dolist (entry '(
                 (:rot ("lizchicheng" "fanlingling"))
                 (:rot ("Array" "Object" "String" "Function"))
                 ))
  (add-to-list 'parrot-rotate-dict entry))

(after! treemacs
  (setq
   evil-treemacs-state-cursor 'box
   treemacs-project-follow-cleanup t
   treemacs-width 25
   )
  (treemacs-follow-mode +1)
  )

;; [[file:config.org::*basic][basic:1]]
(setq org-list-demote-modify-bullet
      '(("+" . "-")
        ("-" . "+")
        ("*" . "+")
        ("1." . "a.")))

;; cancel compeltion in org-mode
(defun dqv/adjust-org-company-backends ()
  (remove-hook 'after-change-major-mode-hook '+company-init-backends-h)
  (setq-local company-backends nil))
(add-hook! org-mode (dqv/adjust-org-company-backends))

(after! org
  (add-hook 'org-mode-hook (lambda () (visual-line-mode -1)))
  (org-babel-do-load-languages 'org-babel-load-languages
                             (append org-babel-load-languages
                              '((http . t))))

  (setq
   ;; org-ellipsis " ▾ "

   ;; org-enforce-todo-dependencies nil ;; if t, it hides todo entries with todo children from agenda
   ;; org-enforce-todo-checkbox-dependencies nil
   org-provide-todo-statistics t
   org-pretty-entities t
   org-hierarchical-todo-statistics t

   ;; org-startup-with-inline-images t
   org-hide-emphasis-markers t
   ;; org-fontify-whole-heading-line nil
   org-src-fontify-natively t
   org-imenu-depth 9

   org-use-property-inheritance t

   org-log-done 'time
   org-log-redeadline 'time
   org-log-reschedule 'time
   org-log-into-drawer "LOGBOOK"

   org-src-preserve-indentation t
   org-edit-src-content-indentation 0
   org-todo-keywords
   '((sequence "TODO(t)" "PROJECT(p)" "NEXT(n)" "WAIT(w)" "HOLD(h)" "IDEA(i)" "SOMEDAY(s)" "MAYBE(m)" "|" "DONE(d)" "CANCELLED(c)")
     (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")
     ;; (sequence "|" "OKAY(o)" "YES(y)" "NO(x)")
     )
   org-tag-alist (quote (("@home" . ?h)
                         (:newline)
                         ("CANCELLED" . ?c)))
   org-todo-keyword-faces `(("NEXT" . ,(doom-color 'green))
                            ("TODO" . ,(doom-color 'yellow))
                            ("PROJECT" . ,(doom-color 'tan))
                            ("WAIT" . ,(doom-color 'teal))
                            ("HOLD" . ,(doom-color 'red))
                            ("IDEA" . ,(doom-color 'tomato))
                            ("SOMEDAY" . ,(doom-color 'base7))
                            ("MAYBE" . ,(doom-color 'base5))
                            ("[ ]" . ,(doom-color 'green))
                            ("[-]" . ,(doom-color 'yellow))
                            ("[?]" . ,(doom-color 'red)))))
;; basic:1 ends here

;; [[file:config.org::*counsel-org-clock][counsel-org-clock:1]]
(use-package! counsel-org-clock
  :commands (counsel-org-clock-context
             counsel-org-clock-history
             counsel-org-clock-goto)
  :config
  (setq counsel-org-clock-history-limit 20))
;; counsel-org-clock:1 ends here

;; [[file:config.org::*org-roam-ui][org-roam-ui:1]]
(use-package! websocket
  :after org-roam)
(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-open-on-start nil
        org-roam-ui-update-on-save t
        org-roam-ui-follow t
        org-roam-ui-sync-theme t
        org-roam-ui-browser-function #'xwidget-webkit-browse-url))
;; org-roam-ui:1 ends here

;; [[file:config.org::*org-roam][org-roam:1]]
(use-package! org-roam
  :hook
  (after-init . org-roam-mode)
  :bind (("C-c n l" . org-roam-buffer-toggle)
          ("C-c n f" . org-roam-node-find)
          ("C-c n g" . org-roam-graph)
          ("C-c n i" . org-roam-node-insert)
          ("C-c n c" . org-roam-capture)
          ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (setq org-roam-capture-templates
        '(
          ("a" "auto export" plain "%?" :target
           (file+head "${slug}.org" "#+SETUPFILE:~/.dqvrc/org/hugo_setup.org
#+HUGO_SLUG: ${slug}
#+TITLE: ${title}\n

<badge: GCCLL | Homepage | green | / | gnu-emacs | tinder>
...

\* COMMENT Local Variables       :ARCHIVE:
# Local Variables:
# after-save-hook: dqv/org-html-export-to-html
# End:")
           :unnarrowed t)
          ("d" "default" plain "%?" :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ))
  (setq org-roam-ref-capture-templates
        '(("r" "ref" plain
           "%?"
           :target ("lit/${slug}" "#+SETUPFILE:./hugo_setup.org
#+ROAM_KEY: ${ref}
#+HUGO_SLUG: ${slug}
#+ROAM_TAGS: website
#+TITLE: ${title}
- source :: ${ref}")
           :unnarrowed t)))
  )
;; org-roam:1 ends here

;; [[file:config.org::*org-fragtog][org-fragtog:1]]
(use-package! org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode)
  )
;; org-fragtog:1 ends here

;; [[file:config.org::*org-ol-tree][org-ol-tree:1]]
(use-package! org-ol-tree
  :commands org-ol-tree)

(map! :map org-mode-map
    :after org
    :localleader
    :desc "Outline" "O" #'org-ol-tree)
;; org-ol-tree:1 ends here

;; [[file:config.org::*org-appear][org-appear:1]]
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks t)
  )
;; org-appear:1 ends here

;; [[file:config.org::*org-fancy-priorities][org-fancy-priorities:1]]
(use-package! org-fancy-priorities
    :diminish
    :hook (org-mode . org-fancy-priorities-mode)
    :config
    (setq org-fancy-priorities-list
          '("🅰" "🅱" "🅲" "🅳" "🅴")))
;; org-fancy-priorities:1 ends here

;; [[file:config.org::*org-mac-link][org-mac-link:1]]
(when IS-MAC
  (use-package! org-mac-link
    :after org
    :config
    (setq org-mac-grab-Acrobat-app-p nil) ; Disable grabbing from Adobe Acrobat
    (setq org-mac-grab-devonthink-app-p nil) ; Disable grabbinb from DevonThink
    ))
;; org-mac-link:1 ends here

;; [[file:config.org::*org-auto-tangle][org-auto-tangle:1]]
(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default nil))
;; org-auto-tangle:1 ends here

;; [[file:config.org::*org-mind-map][org-mind-map:1]]
(use-package! org-mind-map
  :after org
  :init
  (require 'ox-org)
  :config
  (setq
   ;; org-mind-map-rankdir ;; set the chart dir, up-down, left-right
   org-mind-map-include-text t
   org-mind-map-engine "dot"
   )
  ;; (setq org-mind-map-engine "neato")  ; Undirected Spring Graph
  ;; (setq org-mind-map-engine "twopi")  ; Radial Layout
  ;; (setq org-mind-map-engine "fdp")    ; Undirected Spring Force-Directed
  ;; (setq org-mind-map-engine "sfdp")   ; Multiscale version of fdp for the layout of large graphs
  ;; (setq org-mind-map-engine "twopi")  ; Radial layouts
  ;; (setq org-mind-map-engine "circo")  ; Circular Layout
  )
;; org-mind-map:1 ends here

;; [[file:config.org::*org-agenda][org-agenda:1]]
(after! org-agenda
  (advice-add #'org-agenda-archive :after #'org-save-all-org-buffers)
  (advice-add #'org-agenda-archive-default :after #'org-save-all-org-buffers)
  (advice-add #'org-agenda-refile :after (lambda (&rest _)
                                           "Refresh view."
                                           (if (string-match "Org QL" (buffer-name))
                                               (org-ql-view-refresh)
                                             (org-agenda-redo))))
  (advice-add #'org-agenda-redo :around #'doom-shut-up-a)
  (advice-add #'org-agenda-set-effort :after #'org-save-all-org-buffers)
  (advice-add #'org-schedule :after (lambda (&rest _)
                                      (org-save-all-org-buffers)))
  (advice-add #'org-deadline :after (lambda (&rest _)
                                      (org-save-all-org-buffers)))
  (advice-add #'+org-change-title :after (lambda (&rest _)
                                           (org-save-all-org-buffers)))
  (advice-add #'org-cut-special :after #'org-save-all-org-buffers)
  (advice-add #'counsel-org-tag :after #'org-save-all-org-buffers)
  (advice-add #'org-agenda-todo :after #'aj-org-agenda-save-and-refresh-a)
  (advice-add #'org-todo :after (lambda (&rest _)
                                  (org-save-all-org-buffers)))
  (advice-add #'org-agenda-kill :after #'aj-org-agenda-save-and-refresh-a)

  (setq
      org-agenda-prefix-format '((agenda    . "  %-6t %6e ")
                                 (timeline  . "  %-6t %6e ")
                                 (todo      . "  %-6t %6e ")
                                 (tags      . "  %-6t %6e ")
                                 (search    . "%l")
                                 )
      org-agenda-tags-column 80
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-timestamp-if-done t
      ;; org-agenda-todo-ignore-scheduled t
      ;; org-agenda-todo-ignore-deadlines t
      ;; org-agenda-todo-ignore-timestamp t
      ;; org-agenda-todo-ignore-with-date t
      org-agenda-start-on-weekday nil ; 从今天开始
      org-agenda-todo-list-sublevels t
      org-agenda-include-deadlines t
      org-agenda-log-mode-items '(closed clock state)
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-breadcrumbs-separator " ❱ "
      org-agenda-current-time-string "⏰ ┈┈┈┈┈┈┈┈┈┈┈ now"
      org-agenda-sorting-strategy
      '((agenda habit-down time-up effort-up priority-down category-keep)
        (todo   priority-up effort-up todo-state-up category-keep)
        (tags   priority-down category-keep)
        (search category-keep))
   )
  )
;; org-agenda:1 ends here

;; [[file:config.org::*org-super-agenda][org-super-agenda:1]]
(use-package! org-super-agenda
  :after org-agenda
  :commands (org-super-agenda-mode))

(setq
 org-agenda-custom-commands
 '(("o" "Overview"
    ((agenda "" ((org-agenda-span 'day)
                 (org-super-agenda-groups
                  '((:name "Today"
                     :time-grid t
                     :date today
                     :todo "TODAY"
                     :scheduled today
                     :order 1)))))
     (alltodo
      ""
      ((org-agenda-overriding-header "")
       (org-super-agenda-groups
        '((:name "Next"         :todo "NEXT"        :order 1)
          (:name "Important"     :tag "Important"    :order 2    :priority "A")
          (:name "Due Today" :deadline today     :order 3)
          (:name "Due Soon"  :deadline future    :order 8)
          (:name "Overdue"      :deadline past      :order 9    :face error)
          (:name "Emacs"             :tag "Emacs"        :order 10)
          (:name "Vue"               :tag "Vue"          :order 15)
          (:name "React"             :tag "React"        :order 18)
          (:name "Assignments"  :tag "Assignment"   :order 20)
          (:name "Waiting"      :todo "WAITING"     :order 21)
          (:name "To read"      :tag "Read"         :order 25)
          (:name "Issues"       :tag "Issue"        :order 30)
          (:name "Projects"     :tag "Project"      :order 40)
          (:name "Research"     :tag "Research"     :order 50)
          (:name "University"   :tag "uni"          :order 60)
          (:name "Trivial"
           :priority<= "E"
           :tag ("Trivial" "Unimportant")
           :todo ("SOMEDAY" )
           :order 90)
          (:discard (:tag ("Chore" "Routine" "Daily")))))))))))
;; org-super-agenda:1 ends here

;; [[file:config.org::*org-pretty-capture][org-pretty-capture:1]]
(defun org-capture-select-template-prettier (&optional keys)
  "Select a capture template, in a prettier way than default
Lisp programs can force the template by setting KEYS to a string."
  (let ((org-capture-templates
         (or (org-contextualize-keys
              (org-capture-upgrade-templates org-capture-templates)
              org-capture-templates-contexts)
             '(("t" "Task" entry (file+headline "" "Tasks")
                "* TODO %?\n  %u\n  %a")))))
    (if keys
        (or (assoc keys org-capture-templates)
            (error "No capture template referred to by \"%s\" keys" keys))
      (org-mks org-capture-templates
               "Select a capture template\n━━━━━━━━━━━━━━━━━━━━━━━━━"
               "Template key: "
               `(("q" ,(concat (all-the-icons-octicon "stop" :face 'all-the-icons-red :v-adjust 0.01) "\tAbort")))))))
(advice-add 'org-capture-select-template :override #'org-capture-select-template-prettier)

(defun org-mks-pretty (table title &optional prompt specials)
  "Select a member of an alist with multiple keys. Prettified.

TABLE is the alist which should contain entries where the car is a string.
There should be two types of entries.

1. prefix descriptions like (\"a\" \"Description\")
   This indicates that `a' is a prefix key for multi-letter selection, and
   that there are entries following with keys like \"ab\", \"ax\"…

2. Select-able members must have more than two elements, with the first
   being the string of keys that lead to selecting it, and the second a
   short description string of the item.

The command will then make a temporary buffer listing all entries
that can be selected with a single key, and all the single key
prefixes.  When you press the key for a single-letter entry, it is selected.
When you press a prefix key, the commands (and maybe further prefixes)
under this key will be shown and offered for selection.

TITLE will be placed over the selection in the temporary buffer,
PROMPT will be used when prompting for a key.  SPECIALS is an
alist with (\"key\" \"description\") entries.  When one of these
is selected, only the bare key is returned."
  (save-window-excursion
    (let ((inhibit-quit t)
          (buffer (org-switch-to-buffer-other-window "*Org Select*"))
          (prompt (or prompt "Select: "))
          case-fold-search
          current)
      (unwind-protect
          (catch 'exit
            (while t
              (setq-local evil-normal-state-cursor (list nil))
              (erase-buffer)
              (insert title "\n\n")
              (let ((des-keys nil)
                    (allowed-keys '("\C-g"))
                    (tab-alternatives '("\s" "\t" "\r"))
                    (cursor-type nil))
                ;; Populate allowed keys and descriptions keys
                ;; available with CURRENT selector.
                (let ((re (format "\\`%s\\(.\\)\\'"
                                  (if current (regexp-quote current) "")))
                      (prefix (if current (concat current " ") "")))
                  (dolist (entry table)
                    (pcase entry
                      ;; Description.
                      (`(,(and key (pred (string-match re))) ,desc)
                       (let ((k (match-string 1 key)))
                         (push k des-keys)
                         ;; Keys ending in tab, space or RET are equivalent.
                         (if (member k tab-alternatives)
                             (push "\t" allowed-keys)
                           (push k allowed-keys))
                         (insert (propertize prefix 'face 'font-lock-comment-face) (propertize k 'face 'bold) (propertize "›" 'face 'font-lock-comment-face) "  " desc "…" "\n")))
                      ;; Usable entry.
                      (`(,(and key (pred (string-match re))) ,desc . ,_)
                       (let ((k (match-string 1 key)))
                         (insert (propertize prefix 'face 'font-lock-comment-face) (propertize k 'face 'bold) "   " desc "\n")
                         (push k allowed-keys)))
                      (_ nil))))
                ;; Insert special entries, if any.
                (when specials
                  (insert "─────────────────────────\n")
                  (pcase-dolist (`(,key ,description) specials)
                    (insert (format "%s   %s\n" (propertize key 'face '(bold all-the-icons-red)) description))
                    (push key allowed-keys)))
                ;; Display UI and let user select an entry or
                ;; a sub-level prefix.
                (goto-char (point-min))
                (unless (pos-visible-in-window-p (point-max))
                  (org-fit-window-to-buffer))
                (let ((pressed (org--mks-read-key allowed-keys
                                                  prompt
                                                  (not (pos-visible-in-window-p (1- (point-max)))))))
                  (setq current (concat current pressed))
                  (cond
                   ((equal pressed "\C-g") (user-error "Abort"))
                   ;; Selection is a prefix: open a new menu.
                   ((member pressed des-keys))
                   ;; Selection matches an association: return it.
                   ((let ((entry (assoc current table)))
                      (and entry (throw 'exit entry))))
                   ;; Selection matches a special entry: return the
                   ;; selection prefix.
                   ((assoc current specials) (throw 'exit current))
                   (t (error "No entry available")))))))
        (when buffer (kill-buffer buffer))))))
(advice-add 'org-mks :override #'org-mks-pretty)
;; org-pretty-capture:1 ends here

;; [[file:config.org::*org-capture][org-capture:1]]
(use-package! doct
  :commands (doct))

(after! org-capture

  (defun +doct-icon-declaration-to-icon (declaration)
    "Convert :icon declaration to icon"
    (let ((name (pop declaration))
          (set  (intern (concat "all-the-icons-" (plist-get declaration :set))))
          (face (intern (concat "all-the-icons-" (plist-get declaration :color))))
          (v-adjust (or (plist-get declaration :v-adjust) 0.01)))
      (apply set `(,name :face ,face :v-adjust ,v-adjust))))

  (defun +doct-iconify-capture-templates (groups)
    "Add declaration's :icon to each template group in GROUPS."
    (let ((templates (doct-flatten-lists-in groups)))
      (setq doct-templates (mapcar (lambda (template)
                                     (when-let* ((props (nthcdr (if (= (length template) 4) 2 5) template))
                                                 (spec (plist-get (plist-get props :doct) :icon)))
                                       (setf (nth 1 template) (concat (+doct-icon-declaration-to-icon spec)
                                                                      "\t"
                                                                      (nth 1 template))))
                                     template)
                                   templates))))

  (setq doct-after-conversion-functions '(+doct-iconify-capture-templates))

  (defvar +org-capture-recipies  "~/.dqvrc/org/cookbook.org")

  (defun set-org-capture-templates ()
    (setq org-capture-templates
          (doct `(("Personal todo" :keys "t"
                   :icon ("checklist" :set "octicon" :color "green")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Inbox"
                   :type entry
                   :template ("* TODO %?"
                              "%i %a")
                   )
                  ("Personal note" :keys "n"
                   :icon ("sticky-note-o" :set "faicon" :color "red")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Notes"
                   :type entry
                   :template ("* %?"
                              "%i %a"))
                  ("Web" :keys "w"
                   :icon ("web" :set "material" :color "yellow")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Web"
                   :type entry
                   :template ("* TODO %{desc}%? :%{i-type}:"
                              "%i %a")
                   :children (("React" :keys "r"
                               :icon ("react" :set "alltheicon" :color "blue")
                               :desc ""
                               :headline "React"
                               :i-type "web:react"
                               )
                              ("JavaScript" :keys "j"
                               :icon ("javascript-shield" :set "alltheicon" :color "yellow")
                               :desc ""
                               :i-type "web:javascript"
                               )
                              ("HTML" :keys "h"
                               :icon ("html5" :set "alltheicon" :color "orange")
                               :desc ""
                               :i-type "web:html"
                               )
                              ("CSS" :keys "c"
                               :icon ("css3" :set "alltheicon" :color "blue")
                               :desc ""
                               :i-type "web:css"
                               ))
                   )
                  ("Interesting" :keys "i"
                   :icon ("eye" :set "faicon" :color "lcyan")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Interesting"
                   :type entry
                   :template ("* [ ] %{desc}%? :%{i-type}:"
                              "%i %a")
                   :children (("Webpage" :keys "w"
                               :icon ("globe" :set "faicon" :color "green")
                               :desc "%(org-cliplink-capture) "
                               :i-type "read:web"
                               )
                              ("Links" :keys "l"
                               :icon ("link" :set "octicon" :color "blue")
                               :desc "%(org-cliplink-capture) "
                               :i-type "link:web"
                               )
                              ("Article" :keys "a"
                               :icon ("file-text" :set "octicon" :color "yellow")
                               :desc ""
                               :i-type "read:reaserch"
                               )
                              ("\tCookbok" :keys "c"
                               :icon ("spoon" :set "faicon" :color "dorange")
                               :file +org-capture-recipies
                               :headline "Unsorted"
                               :template "%(org-chef-get-recipe-from-url)"
                               )
                              ("Information" :keys "i"
                               :icon ("info-circle" :set "faicon" :color "blue")
                               :desc ""
                               :i-type "read:info"
                               )
                              ("Idea" :keys "I"
                               :icon ("bubble_chart" :set "material" :color "silver")
                               :desc ""
                               :i-type "idea"
                               )))
                  ("Tasks" :keys "k"
                   :icon ("inbox" :set "octicon" :color "yellow")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Tasks"
                   :type entry
                   :template ("* TODO %? %^G%{extra}"
                              "%i %a")
                   :children (("General Task" :keys "k"
                               :icon ("inbox" :set "octicon" :color "yellow")
                               :extra ""
                               )
                              ("Task with deadline" :keys "d"
                               :icon ("timer" :set "material" :color "orange" :v-adjust -0.1)
                               :extra "\nDEADLINE: %^{Deadline:}t"
                               )
                              ("Scheduled Task" :keys "s"
                               :icon ("calendar" :set "octicon" :color "orange")
                               :extra "\nSCHEDULED: %^{Start time:}t"
                               )
                              ))
                  ("Project" :keys "p"
                   :icon ("repo" :set "octicon" :color "silver")
                   :prepend t
                   :type entry
                   :headline "Inbox"
                   :template ("* %{time-or-todo} %?"
                              "%i"
                              "%a")
                   :file ""
                   :custom (:time-or-todo "")
                   :children (("Project-local todo" :keys "t"
                               :icon ("checklist" :set "octicon" :color "green")
                               :time-or-todo "TODO"
                               :file +org-capture-project-todo-file)
                              ("Project-local note" :keys "n"
                               :icon ("sticky-note" :set "faicon" :color "yellow")
                               :time-or-todo "%U"
                               :file +org-capture-project-notes-file)
                              ("Project-local changelog" :keys "c"
                               :icon ("list" :set "faicon" :color "blue")
                               :time-or-todo "%U"
                               :heading "Unreleased"
                               :file +org-capture-project-changelog-file))
                   )
                  ("Centralised project templates"
                   :icon ("ionic-project" :set "fileicon" :color "cyan")
                   :keys "o"
                   :type entry
                   :prepend t
                   :template ("* %{time-or-todo} %?"
                              "%i"
                              "%a")
                   :children (("Project todo"
                               :keys "t"
                               :prepend nil
                               :time-or-todo "TODO"
                               :heading "Tasks"
                               :file +org-capture-central-project-todo-file)
                              ("Project note"
                               :keys "n"
                               :time-or-todo "%U"
                               :heading "Notes"
                               :file +org-capture-central-project-notes-file)
                              ("Project changelog"
                               :keys "c"
                               :time-or-todo "%U"
                               :heading "Unreleased"
                               :file +org-capture-central-project-changelog-file))
                   )))))

  (set-org-capture-templates)
  (unless (display-graphic-p)
    (add-hook 'server-after-make-frame-hook
              (defun org-capture-reinitialise-hook ()
                (when (display-graphic-p)
                  (set-org-capture-templates)
                  (remove-hook 'server-after-make-frame-hook
                               #'org-capture-reinitialise-hook))))))
;; org-capture:1 ends here

;; [[file:config.org::*org-capture][org-capture:2]]
(setf (alist-get 'height +org-capture-frame-parameters) 15)
;; (alist-get 'name +org-capture-frame-parameters) "❖ Capture") ;; ATM hardcoded in other places, so changing breaks stuff
(setq +org-capture-fn
      (lambda ()
        (interactive)
        (set-window-parameter nil 'mode-line-format 'none)
        (org-capture)))
;; org-capture:2 ends here

;; [[file:config.org::*org-chef][org-chef:1]]
(use-package! org-chef
  :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))
;; org-chef:1 ends here

;; [[file:config.org::*org-ref][org-ref:1]]
(use-package! org-ref
  :after org)
;; org-ref:1 ends here

;; [[file:config.org::*org-roam-bibtex][org-roam-bibtex:1]]
(setq bibtex-completion-bibliography (concat user-dot-directory "org/notes/references.bib"))
(setq bibtex-completion-notes-path (concat user-dot-directory "org/notes/references"))
;; (setq bibtex-completion-library-path (concat user-books-directory "")
(use-package! org-roam-bibtex
  :after org-roam
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :config
  (require 'org-ref)
  (setq orb-performat-keywords '("citekey" "title" "url" "author-or-editor" "keywords" "file" "year")
        orb-process-file-keyword t
        orb-attached-file-extensions '("pdf")
        ;; orb-insert-interface 'helm-bibtex
        ;; orb-note-actions-interface 'helm
        ))
;; org-roam-bibtex:1 ends here

;; [[file:config.org::*org-ql][org-ql:1]]
(use-package! org-ql
  :after org)

(defun zz/headings-with-tags (file tags)
  (string-join
   (org-ql-select file
     `(tags-local ,@tags)
     :action '(let ((title (org-get-heading 'no-tags 'no-todo)))
                (concat "- "
                        (org-link-make-string
                         (format "file:%s::*%s" file title)
                         title))))
   "\n"))

(defun zz/headings-with-current-tags (file)
  (let ((tags (s-split ":" (cl-sixth (org-heading-components)) t)))
    (zz/headings-with-tags file tags)))
;; org-ql:1 ends here

;; [[file:config.org::*org-transclusion][org-transclusion:1]]
(use-package! org-transclusion
  :after org)
;; org-transclusion:1 ends here

;; [[file:config.org::*ob-http][ob-http:1]]
(use-package! ob-http
  :after org)
;; ob-http:1 ends here

;; [[file:config.org::*org-super-links][org-super-links:1]]
(use-package! org-super-links
  :after org
  :config
  (setq org-super-links-related-into-drawer t
        org-export-with-broken-links t
  	org-super-links-link-prefix 'org-super-links-link-prefix-timestamp))
;; org-super-links:1 ends here

;; [[file:config.org::*org-preview-html][org-preview-html:1]]
(use-package! org-preview-html
  :after org
  :config
  (setq org-preview-html-viewer 'xwidget))
;; org-preview-html:1 ends here

;; [[file:config.org::*org-special-block-extras][org-special-block-extras:1]]
(use-package! org-special-block-extras
  :after org
  :hook (org-mode . org-special-block-extras-mode)
  ;; All relevant Lisp functions are prefixed ‘o-’; e.g., `o-docs-insert'.
  :custom
  (o-docs-libraries
   '("~/.doom.d/examples/documentation.org")
   "The places where I keep my ‘#+documentation’")
  (defun ospe-add-support-for-derived-backend (new-backend parent-backend)
    "See subsequent snippet for a working example use."
    (add-to-list 'org-export-filter-parse-tree-functions
		 `(lambda (tree backend info)
		    (when (eq backend (quote ,new-backend))
		      (org-element-map tree 'export-block
			(lambda (el)
			  (when (string= (org-element-property :type el) (s-upcase (symbol-name (quote ,new-backend))))
			    (org-element-put-property el :type (s-upcase (symbol-name (quote ,parent-backend))))))))
		    tree))
    ;; “C-x C-e” at the end to see an example of support for ox-hugo
    (progn
      ;; Register new backend
      (ospe-add-support-for-derived-backend 'hugo 'html)
      ;; Register new special block
      (o-defblock noteblock (title "Note") (titleColor "primary")
	          "Define noteblock export for docsy ox hugo"
	          (if ;; ≈ (or (equal backend 'latex) (equal backend new-backend) ⋯)
		      (org-export-derived-backend-p backend 'hugo)
		      (format "{{%% alert title=\"%s\" color=\"%s\"%%}}\n%s{{%% /alert %%}}" title titleColor raw-contents) title titleColor
		      raw-contents))
      ;; Do an example export
      (with-temp-buffer
        (insert (s-join "\n" '("#+begin_noteblock \"My new Title\" :titleColor \"secondary\""
                               "It worked!"
                               "#+end_noteblock")))
        (org-export-to-buffer 'hugo "*Export Result Buffer*" nil nil t t)))
    )
  )
;; org-special-block-extras:1 ends here

;; [[file:config.org::*org-krita][org-krita:1]]
(use-package! org-krita
  :config
  (add-hook 'org-mode-hook 'org-krita-mode))
;; org-krita:1 ends here

;; [[file:config.org::*org-sketch][org-sketch:1]]
(use-package! org-sketch
  :hook (org-mode . org-sketch-mode)
  :init
  (setq org-sketch-note-dir "~/.dqvrc/resources/imgs/" ;; xopp， drawio
        org-sketch-xournal-template-dir "~/.dqvrc/resources/templates/"  ;; xournal
        org-sketch-xournal-default-template-name "template.xopp"
        org-sketch-apps '("drawio" "xournal")
        ))
;; org-sketch:1 ends here

;; [[file:config.org::*ob-mermaid][ob-mermaid:1]]
(use-package! ob-mermaid
  :config
  (setq ob-mermaid-cli-path "/usr/local/nbin/mmdc"))
;; ob-mermaid:1 ends here

(setq
    css-indent-offset 2
    js2-basic-offset 2
    js-switch-indent-offset 2
    js-indent-level 2
    js-jsx-indent-level 2
    js2-mode-show-parse-errors nil
    js2-mode-show-strict-warnings nil
    web-mode-attr-indent-offset 2
    web-mode-code-indent-offset 2
    web-mode-css-indent-offset 2
    web-mode-markup-indent-offset 2
    web-mode-enable-current-element-highlight t
    web-mode-enable-current-column-highlight t)

(after! prog-mode
  (map! :map prog-mode-map "C-h C-f" #'find-function-at-point)
  (map! :map prog-mode-map
        :localleader
        :desc "Find function at point"
        "g p" #'find-function-at-point))

(use-package! js-mode
  :ensure t
  :mode "\\.js\\'")
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))

(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.css\\'"   . web-mode)
         ("\\.js\\'"   . web-mode)
         ("\\.jsx?\\'"  . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'"))))

(defun setup-tide-mode()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(use-package! tide
  :ensure t
  :after (web-mode)
  :hook (web-mode . prettier-js-mode))

(use-package! typescript-mode
  :init
  (define-derived-mode typescript-tsx-mode typescript-mode "typescript-tsx")
  (add-to-list 'auto-mode-alist (cons (rx ".tsx" string-end) #'typescript-tsx-mode))
  )

(add-hook! typescript-tsx-mode 'lsp!)

(use-package! tree-sitter
  :hook (prog-mode . turn-on-tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (require 'tree-sitter-langs)

  (tree-sitter-require 'tsx)
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-tsx-mode . tsx))

  ;; This makes every node a link to a section of code
  (setq tree-sitter-debug-jump-buttons t
        ;; and this highlights the entire sub tree in your code
        tree-sitter-debug-highlight-jump-region t))

(use-package! evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package! flycheck :ensure)
  (use-package! rustic
    :ensure
    :bind (:map rustic-mode-map
                ("M-j" . lsp-ui-imenu)
                ("M-?" . lsp-find-references)
                ("C-c C-c l" . flycheck-list-errors)
                ("C-c C-c a" . lsp-execute-code-action)
                ("C-c C-c r" . lsp-rename)
                ("C-c C-c q" . lsp-workspace-restart)
                ("C-c C-c Q" . lsp-workspace-shutdown)
                ("C-c C-c s" . lsp-rust-analyzer-status))
    :config
    ;; uncomment for less flashiness
    ;; (setq lsp-eldoc-hook nil)
    ;; (setq lsp-enable-symbol-highlighting nil)
    ;; (setq lsp-signature-auto-activate nil)

    ;; comment to disable rustfmt on save
    (setq rustic-format-on-save t)
    (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

  (defun rk/rustic-mode-hook ()
    ;; so that run C-c C-c C-r works without having to confirm, but don't try to
    ;; save rust buffers that are not file visiting. Once
    ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
    ;; no longer be necessary.
    (when buffer-file-name
      (setq-local buffer-save-without-query t)))
