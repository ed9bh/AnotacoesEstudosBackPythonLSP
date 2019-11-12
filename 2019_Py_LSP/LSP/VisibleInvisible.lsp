(defun c:invisible (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (prompt "Selecione Entidades a ficarem invisiveis : ")
        (setq 
            ents (sssetfirst nil (ssget))
        )

        (foreach ent (ssnamex(cadr ents))
            (progn
                (if (> (car ent) -1)
                    (progn
                        (setq ent(vlax-ename->vla-object (cadr ent)))
                        (vlax-put ent 'Visible 0)
                    )
                )
            )
        )
	
	(sssetfirst)
        
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
