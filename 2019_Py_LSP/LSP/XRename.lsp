(defun c:XRename (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            Surfaces (ssget "x" '((0 . "AECC_TIN_SURFACE")))
        )

        (if Surfaces
            (foreach x (ssnamex Surfaces)
                (progn
                    (setq
                        arq (open (strcat(getvar "dwgprefix")"BestReName.csv") "r")
                        v (vlax-ename->vla-object (cadr x))
                    )
                    (while (setq line (read-line arq))
                        (setq
                            Positian (vl-string-position (ascii ";") line)
                            OldName (substr line 1 Positian)
                            NewName (substr line (+ Positian 2))
                        )
                        ;(princ (strcat "\n"OldName" - "NewName))
                        (if (= (vlax-get v 'Name) OldName)
                            (vlax-put v 'Name NewName)
                        )
                    )
                    (close arq)
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
