(defun c:clone(/ *error*)
  (defun *error*(msg)
    (princ msg)
    (setq *error* err)
    (princ)
    )
  (setq
    eSel(entsel"\nSelecione o Objeto a Duplicar : ")
    vSel(vlax-ename->vla-object(car eSel))
    )
  (vla-copy vSel)
  (princ)
  )

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g