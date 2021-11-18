;; -*- lexical-binding: t; -*-
;;; comint-prompt.el ---
;;
;; Copyright (C) 2017 Yevgnen Koh
;;
;; Author: Yevgnen Koh <wherejoystarts@gmail.com>
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.5"))
;; Keywords: comint, prompt
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;
;;
;; See documentation on https://github.com/Yevgnen/comint-prompt.el.

;;; Code:

(defcustom comint-prompt-prompts
  '((python . (inferior-python-mode . ((python-shell-prompt-input-regexps
                                        python-shell-prompt-pdb-regexp)
                                       . python-shell-prompt-output-regexps)))
    (shell . (shell-mode . (shell-prompt-pattern))))
  "Prompts to add font-lock.")

(defface comint-prompt-input-face '((t (:foreground "#303f9f" :weight bold)))
  "Face for comint input prompts.")

(defface comint-prompt-output-face '((t (:foreground "#d84314" :weight bold)))
  "Face for comint output prompts.")

(defun comint-prompt--to-list (x)
  (if (listp x)
      x
    (list x)))

(defun comint-prompt--format-regex (regex)
  (if regex
      (mapconcat #'identity
                 (cl-remove-if #'string-empty-p
                               (apply #'append
                                      (mapcar (lambda (x)
                                                (comint-prompt--to-list (symbol-value x)))
                                              (comint-prompt--to-list regex))))
                 "\\|")))

(defun comint-prompt-font-lock (mode in &optional out)
  (let* ((in-regex (comint-prompt--format-regex in))
         (out-regex (comint-prompt--format-regex out))
         (hook (intern (concat (symbol-name mode) "-hook"))))
    (add-hook hook
              (defalias (intern
                         (format "comint-prompt-setup-%s-prompt"
                                 (symbol-name mode)))
                (lambda ()
                  (if in-regex
                      (font-lock-add-keywords nil `((,in-regex 0 'comint-prompt-input-face prepend))))
                  (if out-regex
                      (font-lock-add-keywords nil `((,out-regex 0 'comint-prompt-output-face prepend)))))))))

;;;###autoload
(defun comint-prompt-setup ()
  (custom-set-faces '(comint-highlight-prompt ((t nil))))
  (dolist (config comint-prompt-prompts)
    (let* ((feature (car config))
           (conf (cdr config))
           (mode (car conf))
           (regex (cdr conf)))
      (with-eval-after-load feature
        (comint-prompt-font-lock mode (car regex) (cdr regex))))))

(provide 'comint-prompt)

;;; comint-prompt.el ends here
