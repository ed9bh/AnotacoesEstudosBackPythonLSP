(defun c:corrigeDimScale (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq xxx (ssget "x" '((0 . "DIMENSION"))))
        
        (foreach x (ssnamex xxx)
            (progn
                (setq
                    vx (vlax-ename->vla-object(cadr x))
                )
                (vlax-put vx 'LinearScaleFactor 1)
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
