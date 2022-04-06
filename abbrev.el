;;; abbrev.el -*- lexical-binding: t; -*-
;;; https://github.com/snosov1/dot-emacs/blob/master/.abbrev_defs

(define-global-abbrev 'global-abbrev-table
  '(
    ("xchar" "(char-to-string (+ ?x ))" nil 0)
    ("xdate" "(format-time-string \"%d, %b, %Y\")" nil 0)
    ("xnocaps" "setxkbmap -option \"ctrl:nocaps\"" nil 0)
    ("xtoday" "(format-time-string \"%d, %b, %Y\")" nil 0)
    ("xunits" "(calc-eval (math-convert-units (calc-eval \"29ft + 8in\" 'raw) (calc-eval \"m\" 'raw)))" nil 0)
    ("xmail" "gccll.love@gmail.com" nil 0)
    ))


(define-abbrev-table 'shell-mode-abbrev-table
  '(("ssh-keygen" "ssh-keygen -t rsa -C \"your_email@example.com\"" nil 0)))
