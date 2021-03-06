;; require grep-a-lot

(require 'grep-a-lot)
(require 'wgrep)
(setq wgrep-enable-key "r")
(setq wgrep-default-line-header-regexp "^\\(.*?[^/\n]\\)\\([:-][ \t]*\\)\\([1-9][0-9]*\\)[ \t]*[-]:")

(setq grep-use-null-device nil)

(setcar (car grep-regexp-alist) "^\\(.+?\\)\\(:[ \t]*\\)\\([1-9][0-9]*\\)[ \t]*\\2")

(defun eab/grep-align ()
  (interactive)
  (read-only-mode -1)
  (toggle-truncate-lines 1)
  (save-excursion
    (beginning-of-buffer)
    (compilation-next-error 1)
    (call-interactively 'set-mark-command)
    (end-of-buffer)
    (backward-paragraph)
    (align-regexp (region-beginning) (region-end) "\\(:[0-9]+\\)\\(\\):" 2 1 t))
  (read-only-mode 1))

(defun eab/wgrep-change-to-wgrep-mode ()
  (interactive)
  (eab/grep-align)
  (call-interactively 'wgrep-change-to-wgrep-mode))

(defun eab/grep-utf ()
  (interactive)
  (let* ((ss (split-string (car compilation-arguments) "LANG=C "))
	(compilation-arguments
	 (append
	  (if (> (length ss) 1) (list (cadr ss)) (list (car compilation-arguments)))
	  (cdr compilation-arguments))))
    (eab/recompile)))

(defun eab/gz-grep (extension)
  (if (string= extension "gz")
      "zgrep"
    "LANG=C grep"))

(setq grep-highlight-matches 'auto-detect)

;; DONE fixed bug (grep-compute-defaults): if grep-history is empty than
;; grep-command isn't parsed correctly
;; (setq grep-history '("grep -i -nH -e test  `git ls-files \\`git rev-parse --show-toplevel\\``"))

(defun eab/grep (arg)
  (interactive "P")
  (let* ((grep-host-defaults-alist nil)
	 (extension (ignore-errors
		      (file-name-extension buffer-file-name)))
	 (str (concat (eab/gz-grep extension) " --color=auto -i -nH -e  "))
	 (grep-command-no-list
	  (if (or (file-exists-p ".gitignore")
		  (string= (shell-command-to-string "git clean -xn `pwd` | wc -l") "0\n"))
	      `,(concat str " `git ls-files \\`git rev-parse --show-toplevel\\``")
	    `,(concat str " *."
		      extension)))
	 (len-str (1+ (length str)))
	 (grep-command
	  (if grep-history
	      (cons grep-command-no-list len-str)
	    grep-command-no-list))
	 (grep-command-complete
	  (concat
	   (substring grep-command-no-list 0 len-str)
	   (symbol-name (symbol-at-point)) " "
	   (substring grep-command-no-list len-str))))
    (if (not arg)
	(call-interactively 'grep)
      (compilation-start
       (if (and grep-use-null-device null-device)
	   (concat  grep-command-complete " " null-device)
	 grep-command-complete)
       'grep-mode))))

(defun eab/find-grep ()
  (interactive)
  (let ((grep-host-defaults-alist nil)
        (grep-find-command
         `(,"find . -iname '**' -type f -print0 | xargs -0 -e grep -i -nH -e \"\"" . 17)))
    (call-interactively 'find-grep)))

(grep-a-lot-advise eab/grep)

(provide 'eab-grep)
