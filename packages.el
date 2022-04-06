;; funny

(package! org-krita
  :recipe (:host github
           :repo "lepisma/org-krita"
           :files ("resources" "resources" "*.el" "*.el"))
  :disable t)
(package! org-sketch
  :recipe (:host github
           :repo "yuchen-lea/org-sketch")
  :disable t)
;; (package! el-easydraw
;;   :recipe (:host github
;;            :repo "misohena/el-easydraw"))

(when IS-MAC
  (package! org-mac-link))

(package! spacemacs-theme)
(package! nano-theme
  :recipe (:host github
           :repo "rougier/nano-theme"))

;; File and directory management
(package! crux)
(package! deft)
;; (package! ranger)
(package! autoinsert)

;; Tools
(package! mu4e-dashboard
  :recipe (:host github :repo "rougier/mu4e-dashboard"))
(package! mu4e-alert)
(package! zoom)
(package! youdao-dictionary)
(package! popper
  :recipe (:host github :repo "waymondo/popper") :disable t)
(package! engine-mode)
(package! emacs-everywhere)
(package! counsel-osx-app)
(package! dash-at-point
  :recipe (:host github
           :repo "waymondo/dash-at-point"))
;; (package! impatient-mode)
(package! popweb
  :recipe (:host github :repo "manateelazycat/popweb") :disable t)

;; search
(package! deadgrep)
(package! visual-regexp)
(package! visual-regexp-steriods
  :recipe (:host github :repo "benma/visual-regexp-steroids.el"))
;; (package! color-rg
;;   :recipe (:host github :repo "manateelazycat/color-rg"))
;; (package! exec-path-from-shell)

;; Text
(package! pangu-spacing)
(package! move-text)
(package! string-inflection)
(package! parrot)
(package! cycle-quotes)
(package! visual-fill-column)
(package! maple-iedit
  :recipe (:host github
           :repo "honmaple/emacs-maple-iedit"))
(package! zzz-to-char)
(package! tiny)
(package! evil-nerd-commenter)
(package! mixed-pitch)
(package! svg-tag-mode)
(package! svg-lib)
(package! annotate)


;; org
(unpin! code-review)
(unpin! org-roam)
(package! org-appear)
(package! org-fancy-priorities)
(package! org-ol-tree
  :recipe (:host github :repo "Townk/org-ol-tree"))
(package! org-fragtog)
(package! org-roam-ui)
(package! org-auto-tangle)
(package! graphviz-dot-mode)
(package! counsel-org-clock)
(package! org-mind-map)
(package! org-super-agenda)
(package! doct
  :recipe (:host github :repo "progfolio/doct"))
;; hightlight latex export results
(package! engrave-faces
  :recipe (:host github :repo "tecosaur/engrave-faces"))
(package! org-chef)
(package! org-ql)
(package! org-transclusion)
(package! org-super-links
  :recipe (:host github :repo "toshism/org-super-links"))
(package! org-preview-html)
(package! org-special-block-extras
   :recipe (:host github :repo "gcclll/org-special-block-extras"))
(package! ob-mermaid)
(package! mathpix.el
  :recipe (:host github :repo "jethrokuan/mathpix.el"))
(package! ox-hugo)
(package! ox-texinfo+
  :recipe (:host github :repo "tarsius/ox-texinfo-plus"))
(package! org-roam-bibtex)
(package! org-ref)

;; study & gaming
(package! leetcode)
(package! dotenv-mode)
(package! prettier-js)
(package! ob-typescript)
(package! org-wild-notifier)
(package! org-alert
  :recipe (:host github :repo "spegoraro/org-alert"))

(package! lsp-tailwindcss
  :recipe (:host github :repo "merrickluo/lsp-tailwindcss"))

(package! emacs-solidity
  :recipe (:host github :repo "ethereum/emacs-solidity"))

;; programming
(package! js-doc)
(package! mmm-mode)
(package! rjsx-mode)
(package! tide)
(package! tree-sitter)
(package! tree-sitter-langs)
(package! web-mode)
(package! visual-fill)
(package! evil-nerd-commenter)


;; TODO dap-mode
(package! devdocs)
(package! deno-fmt)
(package! prettier)
(package! ob-http)
;; (package! npm
;;  :recipe (:host github :repo "shaneikennedy/npm.el"))
(package! lsp-volar
  :recipe (:host github :repo "jadestrong/lsp-volar"))

;; eaf
;; (package! eaf
;;   :recipe (:host github :repo "manateelazycat/emacs-application-framework"
;;            :files ("eaf.el" "src/lisp/*.el")))

;; Disable
(disable-packages! bookmark tide eldoc grip-mode)
