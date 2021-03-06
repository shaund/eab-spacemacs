;; require dired

(require 'dired-async)

(eab/patch-this-code
 'dired-async-create-files
 "(require 'cl-lib) (require 'dired-aux) (require 'dired-x)"
 (let ((print-quoted 't))
   (prin1-to-string
    `(progn
       (require 'cl-lib)
       (require 'dired-aux)
       (require 'dired-x)
       (add-to-list
	'load-path
	,(file-name-directory
	  (buffer-file-name
	   (car (find-function-noselect 'docker-tramp-add-method)))))
       (require 'tramp)
       (add-to-list 'tramp-methods ',eab/sussh)
       (require 'docker-tramp)))) 't)

(dired-async-mode)
(setq dired-dwim-target 't)

(setq dired-listing-switches "-al -h")
(setq eab/dired-group-directories-off t)

(defun eab/dired-group-directories-toggle ()
  (interactive)
  (if eab/dired-group-directories-off
      (progn
	(setq dired-listing-switches "-al --group-directories-first -h")
	(setq eab/dired-group-directories-off nil))
    (progn
      (setq dired-listing-switches "-al -h")
      (setq eab/dired-group-directories-off 't))))

(defun eab/make-list-paths (&optional arg)
  "In dired-mode set last kill-ring value to full paths of marked files like Total Commander. (e.g)
    in dired: file1 (eab/make-list-paths)  -> /home/john/file1 to kill-ring"
  (interactive "p")
  (let* ((dropp (if (eq arg 1) nil 't))
	 (string-my (dired-get-marked-files dropp))
	 (buf-name (symbol-name (gensym))))
    (switch-to-buffer buf-name)
    (dolist (every-str string-my)
      (insert-for-yank-1 (if dropp (eab/add-drop every-str) every-str))
      (newline))
    (delete-backward-char 1)
    (beginning-of-buffer)
    (copy-region-as-kill (mark) (point))
    (kill-buffer buf-name)))


(provide 'eab-dired)
