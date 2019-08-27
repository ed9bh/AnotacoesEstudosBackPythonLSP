;;; Apagar linha duplicada em seções apos serem exportadas para autoCAD do Civil 3D para acabamento.

(defun c:DoubleLineSection (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            CyanLine(ssget "x" '((0 . "Line")(62 . 4)))
        )

        (foreach x (ssnamex CyanLine)
            (progn
                (setq
                    x (vlax-ename->vla-object (cadr x))
                    MasterA(vlax-get x 'StartPoint)
                    MasterB(vlax-get x 'EndPoint)
                    GreyLine(ssget "x" '((0 . "Line")(62 . 8)))
                )
                (foreach y (ssnamex GreyLine)
                    (progn
                        (setq
                            y (vlax-ename->vla-object (cadr y))
                            PA (vlax-get y 'StartPoint)
                            PB (vlax-get y 'EndPoint)
                        )
                        (if (and (equal MasterA PA) (equal MasterB PB))
                            (vla-Delete y)
                            (princ "-")
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
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)
