(defcustom slamdata-mode-line " 💪"
  "Mode line ligher for SlamData.

The value of this variable is a mode line template as in
`mode-line-format'.  See Info Node `(elisp)Mode Line Format' for
details about mode line templates.

Customize this variable to change how SlamData displays its
status in the mode line.  The default value displays the project
name.  Set this variable to nil to disable the mode line
entirely."
  :group 'slamdata
  :type 'sexp)

(defcustom slamdata-slamengine-directory nil
  "Where the slamengine repo lives"
  :group 'slamdata
  :type 'directory)

(defun it-directory ()
  (concat slamdata-slamengine-directory "/it/src/test/resources/tests/"))

(defcustom slamdata-keymap-prefix (kbd "C-c C-s")
  "SlamData keymap prefix."
  :group 'slamdata
  :type 'string)

(defun slamdata-mongo ()
  (interactive)
  (inf-mongo "/usr/local/bin/mongo --username slamengine --password slamengine ds045089.mongolab.com:45089/slamengine-test-01"))

(defun slamdata-git-open-issue ()
  (interactive)
  (start-process "slamdata-open-issue" "*slamdata-open-issue*" "ghi" "open"))

(defun slamdata-git-comment-issue (issue-number)
  (interactive "nissue number: ")
  (start-process "slamdata-comment-issue"
                 "*slamdata-comment-issue*"
                 "ghi" "comment" issue-number))

(defun slamdata-git-wip (branch-suffix)
  (interactive "sbranch: ")
  (start-process "slamdata-wip"
                 "*slamdata-wip*"
                 (format "%s/scripts/wip" slamdata-slamengine-directory)
                 branch-suffix))

(defun slamdata-git-ready (branch-suffix)
  (interactive "sbranch: ")
  (start-process "slamdata-ready"
                 "*slamdata-ready*"
                 (format "%s/scripts/ready" slamdata-slamengine-directory)
                 branch-suffix))

(defun slamdata-new-integration-test (name)
  (interactive (list (read-file-name "file name for test: " (it-directory))))
  ;; TODO: use empty template instead of copying existing test
  (copy-file (concat (it-directory) "groupedJoin.test") name)
  (find-file name))

(defun slamdata-run-coverage ()
  (interactive)
  (let ((default-directory slamdata-slamengine-directory))
    (start-process "slamdata-coverage"
                   "*slamdata-coverage*"
                   "./sbt" "-DisCoverageRun"
                   "coverage"
                   "project it"    "test"
                   "project admin" "test"
                   "project web"   "test"
                   "project core"  "test")))

(defun slamdata-run-tests ()
  (interactive)
  (let ((default-directory slamdata-slamengine-directory))
    (start-process "slamdata-tests" "*slamdata-tests*" "./sbt" "test")))

;;; Minor mode
(defvar slamdata-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g i o") 'slamdata-git-open-issue)
    (define-key map (kbd "g i c") 'slamdata-git-comment-issue)
    (define-key map (kbd "g w")   'slamdata-git-wip)
    (define-key map (kbd "g r")   'slamdata-git-ready)
    (define-key map (kbd "m")     'slamdata-mongo)
    (define-key map (kbd "r c")   'slamdata-run-coverage)
    (define-key map (kbd "r t")   'slamdata-run-tests)
    map)
  "Keymap for Slamdata commands after `slamdata-keymap-prefix'")
(fset 'slamdata-command-map slamdata-command-map)

(defvar slamdata-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map slamdata-keymap-prefix 'slamdata-command-map)
    map)
  "Keymap for Slamdata mode.")

;;;###autoload
(define-minor-mode slamdata-mode
  "Minor mode to assist project management and navigation.

When called interactively, toggle `slamdata-mode'.  With prefix
ARG, enable `slamdata-mode' if ARG is positive, otherwise disable
it.

When called from Lisp, enable `slamdata-mode' if ARG is omitted,
nil or positive.  If ARG is `toggle', toggle `slamdata-mode'.
Otherwise behave as if called interactively.

\\{slamdata-mode-map}"
  :lighter slamdata-mode-line
  :keymap slamdata-mode-map
  :group 'slamdata
  :require 'slamdata
  #'identity)

;;;###autoload
(define-globalized-minor-mode slamdata-global-mode
  slamdata-mode
  slamdata-mode)

(defun slamdata-local-auto-mode (pattern mode)
  (add-to-list 'auto-mode-alist
               `(,(format "^%s%s"
                          (expand-file-name slamdata-slamengine-directory)
                          pattern)
                 . ,mode)))
(defvar slamdata-integration-test-path "it/src/test/resources/tests/")
(slamdata-local-auto-mode (concat slamdata-integration-test-path ".*\\.data\\'")
                          #'json-mode)
(slamdata-local-auto-mode (concat slamdata-integration-test-path ".*\\.test\\'")
                          #'json-mode)

(provide 'slamdata)
