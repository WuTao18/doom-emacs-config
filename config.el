;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq
 user-full-name "Tao Wu"
 user-mail-address "taowuuwoat@outlook.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq
 doom-font (font-spec :family "iosevka" :size 22)
 doom-variable-pitch-font (font-spec :family "iosevka" :size 22))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-opera-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/knowledge-base/org/")

(pushnew! initial-frame-alist '(width . 200) '(height . 55))

;; --------- nano themes ---------
; (setq doom-theme 'nil)
; (require 'disp-table)
; (require 'nano-base-colors)
; (require 'nano-faces)
; (require 'nano-colors)
; (require 'nano-defaults)
; (require 'nano-theme)
; (require 'nano-theme-dark)
; (require 'nano-modeline)
; (require 'nano-help)
; (require 'nano-layout)
; (nano-faces)
; (nano-theme)

;; --------- elegant-emacs theme ---------
; (setq doom-theme 'nil)
; (require 'elegance)
; (require 'sanity)

;; ========= share clipboard =========
(defun copy-selected-text (start end)
  (interactive "r")
  (if (use-region-p)
      (let ((text (buffer-substring-no-properties start end)))
        (shell-command (concat "echo '" text "' | clip.exe")))))

; wsl-copy
(defun wsl-copy (start end)
  (interactive "r")
  (shell-command-on-region start end "clip.exe")
  (deactivate-mark))

; wsl-paste
(defun wsl-paste ()
  (interactive)
  (let
      ((clipboard
        ; (shell-command-to-string "powershell.exe -command 'Get-Clipboard' 2> /dev/null")))
        (shell-command-to-string
         "powershell.exe -command 'Get-Clipboard' | iconv -f gbk -t utf8")))
    (setq clipboard (replace-regexp-in-string "\r" "" clipboard)) ; Remove Windows ^M characters
    (setq clipboard (substring clipboard 0 -1)) ; Remove newline added by Powershell
    (insert clipboard)))

;; ========= paste image from win clipboard =========
(defun my-yank-image-from-win-clipboard-through-powershell ()
  "to simplify the logic, use c:/Users/Public as temporary directoy, then move it into current directoy

Anyway, if need to modify the file name, please DONT delete or modify file extension \".png\",
otherwise this function don't work and don't know the reason
"
  (interactive)
  (let* ((powershell
          "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe")
         (file-name
          (format "%s"
                  (read-from-minibuffer
                   "Img Name:"
                   (format-time-string "screenshot_%Y%m%d_%H%M%S.png"))))
         ;; (file-path-powershell (concat "c:/Users/\$env:USERNAME/" file-name))
         (file-path-wsl
          (concat
           "~/knowledge-base/org/images/"
           (format-time-string "%Y/")
           file-name)))
    (if (file-exists-p
         (concat "~/knowledge-base/org/images/" (format-time-string "%Y")))
        (ignore)
      (make-directory
       (concat "~/knowledge-base/org/images/" (format-time-string "%Y"))))
    ;; (shell-command (concat powershell " -command \"(Get-Clipboard -Format Image).Save(\\\"C:/Users/\\$env:USERNAME/" file-name "\\\")\""))
    (shell-command
     (concat
      powershell
      " -command \"(Get-Clipboard -Format Image).Save(\\\"C:/Users/Public/"
      file-name
      "\\\")\""))
    (rename-file (concat "/mnt/c/Users/Public/" file-name) file-path-wsl)
    (format "%s" file-path-wsl)))

(defun my-yank-image-link-into-org-from-wsl ()
  "call `my-yank-image-from-win-clipboard-through-powershell' and insert image file link with org-mode format"
  (interactive)
  (let* ((file-path (my-yank-image-from-win-clipboard-through-powershell))
         (file-link
          (format "[[file:%s][%s]]"
                  file-path
                  (file-name-sans-extension
                   (file-name-nondirectory file-path)))))
    (insert (concat "#+ATTR_HTML: :width 50%\n") file-link)))
(global-set-key (kbd "<f8>") 'my-yank-image-link-into-org-from-wsl)

;; ========= use win's default browser to open url =========
(when (and (eq system-type 'gnu/linux)
           (string-match
            "Linux.*Microsoft.*Linux" (shell-command-to-string "uname -a")))
  (setq
   browse-url-generic-program "/mnt/c/Windows/System32/cmd.exe"
   browse-url-generic-args '("/c" "start")
   browse-url-browser-function #'browse-url-generic))

;; ========= use linux's chrome browser to open url =========
;; (setq browse-url-browser-function 'browse-url-firefox)

;; ========= log time when task is done =========
(setq org-log-done 'time)

;; ========= org capture =========
(after!
 org (setq org-capture-templates nil)
 (add-to-list
  'org-capture-templates
  '("i"
    "Inbox"
    entry
    (file+olp+datetree "~/knowledge-base/org/inbox.org")
    "* %U %?\n"
    :tree-type month))
 (add-to-list
  'org-capture-templates
  '("t"
    "Tasks"
    entry
    (file+olp+datetree "~/knowledge-base/org/tasks.org")
    "* TODO %? %U"
    :tree-type month))
 (add-to-list
  'org-capture-templates
  '("j"
    "Journal"
    entry
    (file+olp+datetree "~/knowledge-base/org/journal.org")
    "* %U %?\n")))

;; ========= English date/timestamp format =========
(setq system-time-locale "C")

;; ========= insert timestamp with time =========
(defun insert-now-timestamp-inactive ()
  "Insert org mode inactive timestamp at point with current date and time."
  (interactive)
  (org-time-stamp-inactive (current-time)))

;; ========= pyim =========
(add-load-path! "~/.doom.d/packages/pyim")

(require 'pyim)
(require 'pyim-basedict)
(require 'pyim-cregexp-utils)
;; 如果使用 popup page tooltip, 就需要加载 popup 包。
;; (require 'popup nil t)
;; (setq pyim-page-tooltip 'popup)
(setq pyim-page-tooltip '(posframe popup minibuffer))

;; 如果使用 pyim-dregcache dcache 后端，就需要加载 pyim-dregcache 包。
;; (require 'pyim-dregcache)
;; (setq pyim-dcache-backend 'pyim-dregcache)

;; 加载 basedict 拼音词库。
(pyim-basedict-enable)

;; 将 Emacs 默认输入法设置为 pyim.
(setq default-input-method "pyim")

;; 显示 5 个候选词。
(setq pyim-page-length 5)

;; 金手指设置，可以将光标处的编码（比如：拼音字符串）转换为中文。
;;(global-set-key (kbd "M-j") 'pyim-convert-string-at-point)
(global-set-key (kbd "M-n") 'pyim-convert-string-at-point)

;; 按 "C-<return>" 将光标前的 regexp 转换为可以搜索中文的 regexp.
(define-key
 minibuffer-local-map (kbd "C-<return>") 'pyim-cregexp-convert-at-point)

;; 设置 pyim 默认使用的输入法策略，我使用全拼。
(pyim-default-scheme 'quanpin)
;; (pyim-default-scheme 'wubi)
;; (pyim-default-scheme 'cangjie)

;; 设置 pyim 是否使用云拼音
(setq pyim-cloudim 'baidu)

;; 设置 pyim 探针
;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
;; 我自己使用的中英文动态切换规则是：
;; 1. 光标只有在注释里面时，才可以输入中文。
;; 2. 光标前是汉字字符时，才能输入中文。
;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
(setq-default pyim-english-input-switch-functions
              ;;                '(pyim-probe-dynamic-english
              '(pyim-probe-auto-english
                ;;                  pyim-probe-isearch-mode
                pyim-probe-program-mode pyim-probe-org-structure-template))

(setq-default pyim-punctuation-half-width-functions
              '(pyim-probe-punctuation-line-beginning
                pyim-probe-punctuation-after-punctuation))

;; 开启代码搜索中文功能（比如拼音，五笔码等）
;; (pyim-isearch-mode 1)

(add-load-path! "~/.doom.d/packages/pyim-tsinghua-dict")
(require 'pyim-tsinghua-dict)
(pyim-tsinghua-dict-enable)

;; ========= org roam + org roam ui =========
(use-package
 org-roam
 :ensure t
 :custom (org-roam-directory (file-truename "~/knowledge-base/org/roam"))
 :bind
 (("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n g" . org-roam-graph)
  ("C-c n i" . org-roam-node-insert)
  ("C-c n c" . org-roam-capture)
  ;; Dailies
  ("C-c n j" . org-roam-dailies-capture-today))
 :config
 ;; If you're using a vertical completion framework, you might want a more informative completion interface
 (setq org-roam-node-display-template
       (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
 (org-roam-db-autosync-mode)
 ;; If using org-roam-protocol
 (require 'org-roam-protocol))

(use-package! websocket :after org-roam)

(use-package!
 org-roam-ui
 :after org-roam ;; or :after org
 ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
 ;;         a hookable mode anymore, you're advised to pick something yourself
 ;;         if you don't care about startup time, use
 ;;  :hook (after-init . org-roam-ui-mode)
 :config
 (setq
  org-roam-ui-sync-theme t
  org-roam-ui-follow t
  org-roam-ui-update-on-save t
  org-roam-ui-open-on-start t))

;; global beacon minor-mode
; (use-package! beacon)
; (after! beacon (beacon-mode 1))

;; ========= Mouse scrolling in terminal emacs =========
(defun enable-mouse-scroll ()
  (unless (display-graphic-p)
    ;; activate mouse-based scrolling
    (xterm-mouse-mode 1)
    (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
    (global-set-key (kbd "<mouse-5>") 'scroll-up-line)))

(defun mouse-scroll-mode ()
  (interactive)
  (if xterm-mouse-mode
      (xterm-mouse-mode 0)
    (enable-mouse-scroll)))

;; ========= org-modern =========
(if (display-graphic-p)
    (use-package!
     org-modern
     :hook (org-mode . org-modern-mode)
     :config
     (setq
      ;; Edit settings
      org-auto-align-tags nil
      org-tags-column 0
      org-catch-invisible-edits 'show-and-error
      org-special-ctrl-a/e t
      org-insert-heading-respect-content t

      ;; Org styling, hide markup etc.
      ; org-hide-emphasis-markers t
      org-pretty-entities t
      org-ellipsis "…"

      ;; Agenda styling
      org-agenda-tags-column 0
      org-agenda-block-separator ?─
      org-agenda-time-grid
      '((daily today require-timed)
        (800 1000 1200 1400 1600 1800 2000)
        " ┄┄┄┄┄ "
        "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
      org-agenda-current-time-string "⭠ now ─────────────────────────────────────────────────")

     ; (global-org-modern-mode)
     ))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
