#!/usr/bin/env bash
set -euo pipefail

cd $HOME/.doom.d

# emacs --batch --eval "(progn (require 'org) (setq org-confirm-babel-evaluate nil) (org-babel-tangle-file \"README.org\"))"

cp $HOME/.doom.d/config.org $BLOG_HOME/content/emacs/doom-emacs-configuration-2022.org
cd $BLOG_HOME
gpush
# $HOME/.gclrc/shl/cp-config-org.sh
