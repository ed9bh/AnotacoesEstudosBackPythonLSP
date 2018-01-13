(defun c:brx(/ point)
  (setq
    point
     (getpoint "\tPonto a quebrar: ")
    )
  (command
    "break"
    point
    "first"
    point
    point
    )
  (princ)
  )