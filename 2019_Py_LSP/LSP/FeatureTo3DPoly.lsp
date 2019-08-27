(defun c:FeatureTo3DPoly(/ *error* main doc ssObject vlObject Coords l PList n model)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            ssObject(entsel "\nSelecione a Feature Line : ")
            vlObject(if ssObject
                        (vlax-ename->vla-object (car ssObject))
                        (quit)
            )
            Coords(vlax-invoke vlObject 'GetPoints)
            l (/ (length Coords) 3)
            PList nil
            n -1
            model(vla-get-ModelSpace doc)
        )

        (repeat l
            (setq PList(vl-list*
                            (list
                                (nth (setq n (1+ n)) Coords)
                                (nth (setq n (1+ n)) Coords)
                                (nth (setq n (1+ n)) Coords)
                            )
                            PList
                        )
                )
        )

        (vla-Add3DPoly model 
            (vlax-make-variant
                (vlax-safearray-fill
                    (vlax-make-safearray vlax-vbDouble
                        (cons 0 (1-(length(apply'append(reverse PList))))))
                    (apply'append(reverse PList))
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
