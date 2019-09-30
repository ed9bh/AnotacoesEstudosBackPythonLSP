(defun c:invisible (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            ent(entsel "\nSelecione Item a ficar Invisivel : ")
        )

        (if ent
            (setq vEnt(vlax-ename->vla-object (car ent)))
            (quit)
        )

        (vlax-put vEnt 'Visible 0)
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)

(defun c:visible (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq ssInvisibles (ssget "x"))

        (foreach x (ssnamex ssInvisibles)
            (progn
                (setq v (vlax-ename->vla-object (cadr x))
                    status(vlax-get v 'Visible)
                )
                (if (= status 0)
                    (vlax-put v 'Visible -1)
                )
            )
        )
        
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
