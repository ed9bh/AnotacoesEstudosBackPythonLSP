(defun c:xbindAll (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (princ "\nBinding All...")
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            ssX(ssget "x" '(( 0 . "INSERT")))
        )

        (foreach x (ssnamex ssX)
            (progn
                (setq
                    x(vlax-ename->vla-object (cadr x))
                )
                (vl-catch-all-apply 'vlax-invoke-method (list x "bind" :vlax-true))
                ;|
                (if (= (vlax-get-property x 'IsXref) :vlax-true)
                    (progn
                        (vlax-invoke-method x "bind" :vlax-true)
                    )
                )
                |;
            )
        )
        
        (vla-EndUndoMark doc)
        (princ "\tDone...")
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
