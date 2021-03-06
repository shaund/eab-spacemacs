(require 'magit)
;; TODO emacs 24: autorevert.el doesn't contain auto-revert-buffer-list-filter
;; (require 'magit-autorevert)
;; (setq auto-revert-buffer-list-filter 'magit-auto-revert-repository-buffer-p)
(setq magit-stage-all-confirm nil)
(setq magit-push-always-verify nil)
;; (add-hook 'magit-status-mode-hook 'magit-filenotify-mode) ;; TODO too slow
;; org-magit workaround
(defvar magit-currently-shown-commit nil)
(defadvice magit-show-commit (after eab-magit-show-commit activate)
  (setq magit-currently-shown-commit (ad-get-arg 0)))

(require 'magit-wip)
(require 'magit-annex)

(require 'git-wip)

;; TODO see magit-commit-amend, похоже там нет только опции reuse-message
(defun eab/magit-just-amend ()
  (interactive)
  (save-window-excursion
    (shell-command "git --no-pager commit --amend --reuse-message=HEAD")
    (magit-refresh)))

(provide 'eab-git)
