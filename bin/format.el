; Code written by Joe Wreschnig
; http://stackoverflow.com/a/15213482
(with-temp-buffer
  ;; Would like to implement --help but Emacs eats that before I can
  ;; process it here.
  (let ((param (nth 0 command-line-args-left)))
    (if param (funcall (intern param))))

  (condition-case nil
      (while t
        (insert (read-from-minibuffer ""))
        (insert "\n"))
    (error nil))
  (fill-region (point-min) (point-max))
  (princ (buffer-string)))
