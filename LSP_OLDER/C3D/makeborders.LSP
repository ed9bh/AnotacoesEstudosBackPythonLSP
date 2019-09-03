;(vlax-dump-object (vlax-invoke (vlax-get acad 'Documents)'Item 1) t)
(defun c:makeborders()
  (setq error *error*
	acad(vlax-get-acad-object)
	doc(vla-get-ActiveDocument acad)
	model(vla-get-ModelSpace doc)
	)
  (vla-StartUndoMark doc)
  (setvar'cmdecho 0)

  (defun *error*(msg)
    (setq *error* error)
    (princ msg)
    (if errmsg
      (princ (vl-catch-all-error-message errmsg))
      )
    (setvar'cmdecho 1)
    (vla-EndUndoMark doc)
    (princ)
    )

  (setq
    ss
     (ssget"x"'((0 . "AECC_TIN_SURFACE")))
    )

  (if ss
    (setq
      ss(ssnamex ss)
      )
    (quit)
    )

  (foreach x ss
    (progn
      (setq
	x(vlax-ename->vla-object (cadr x))
	errmsg nil
	errmsg(vl-catch-all-apply 'vlax-invoke-method (list x 'ExtractBorder 1))
	)
      )
    )
  (setq *error* error)
  (vla-EndUndoMark doc)
  (setvar'cmdecho 1)
  (princ)
  )
