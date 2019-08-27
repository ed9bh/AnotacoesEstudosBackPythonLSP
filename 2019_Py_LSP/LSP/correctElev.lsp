(defun c:correctElev (/ *error* main doc msg c)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq blk(ssget "x" '((0 . "insert"))))

        (if (= blk nil)
            (quit)
        )

        (foreach x (ssnamex blk)
            (progn
                (setq msg "Start error..." c(if(= c nil) 0 (1+ c) ))
                (setq
                    x (vlax-ename->vla-object (cadr x))
                )
                (if (= (vlax-method-applicable-p x 'GetAttributes) t)
                    (progn
                        (setq att (vlax-invoke x 'GetAttributes))
                        (setq msg "Get att error...")
                        (if (=(length att)3)
                            (progn
                                (setq elev (read(vl-string-translate "," "." (vlax-get(nth 2 att)'TextString))))
                                (setq msg "2")
                                (setq
                                    position (vlax-get x 'InsertionPoint)
                                    position (list (nth 0 position) (nth 1 position) elev)
                                )
                                (setq msg "Insert error...")
                                ;(princ x)
                                ;(princ position)
                                (vl-catch-all-apply 'vlax-put (list x 'InsertionPoint position))
                            )
                        )
                    )
                )

            )
        )

        
        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (princ "\n")
        (princ msg)
        (princ "\n")
        (princ c)
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
