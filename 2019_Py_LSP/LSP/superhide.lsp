(defun c:superHide ()
  (vl-load-com)
  (princ "\n !!!Atenção!!! Para desocultar entidades digite superUnhide!!! \n")
  (princ "\tSelecione as entidades a ocultar : ")
  (setq
    ss(ssget)
  )
  (foreach item (ssnamex ss)
    (if (>(car item)0)
      (setq
        vlao(vlax-ename->vla-object (cadr item))
        fun(vlax-put vlao 'Visible 0)
      )
    )
  )
)

(defun c:superUnhide ()
  (vl-load-com)
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
    Count (vlax-get MSpace 'Count)
    n -1
  )
  (while
    (< (setq n(1+ n)) Count)
    (if (=(vlax-get (vlax-invoke MSpace 'Item n) 'Visible)0)
      (vlax-put (vlax-invoke MSpace 'Item n) 'Visible -1)
    )
  )
)