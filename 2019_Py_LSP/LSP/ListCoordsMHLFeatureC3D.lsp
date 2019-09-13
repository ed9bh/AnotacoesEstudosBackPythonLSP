(defun c:ListCoordsMHLFeatureC3D (/ *error* main doc 
                                    eEnty vEnty AC3DMLH Points Count 
                                    Coords Size 3d excel workbooks book 
                                    sheets sheet cells roll n col MLH MLHName Elevation
                                    )
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            eEnty(entsel "\nSelecione a entidade (FeatureLine, 3D Polyline ou LWPolyline) : ")
            vEnty(vlax-ename->vla-object (car eEnty))
            AC3DMLH(ssget "x" '((0 . "AECC_TIN_SURFACE")))
            Points nil
            Count -1
        )

        (if (= AC3DMLH nil) (quit))

        (if(=(vlax-method-applicable-p vEnty 'GetPoints) t)
            (setq
                Coords(vlax-invoke vEnty 'GetPoints)
                Size(/ (length Coords) 3)
                3d t
            )
            (if(=(vlax-property-available-p vEnty 'Coordinates)t)
                (if(= (vlax-get vEnty 'ObjectName) "AcDb3dPolyline")
                    (setq
                        Coords(vlax-get vEnty 'Coordinates)
                        Size(/ (length Coords) 3)
                        3d t
                    )
                    (setq
                        Coords(vlax-get vEnty 'Coordinates)
                        Size(/ (length Coords) 2)
                        3d nil
                    )
                )
                (quit)
            )
        )

        (setq
            excel(vlax-get-or-create-object "Excel.Application")
            workbooks(vlax-get excel 'workbooks)
            book(vlax-invoke-method workbooks 'add)
            sheets(vlax-get book 'sheets)
            sheet(vlax-get-property sheets 'Item 1)
            cells(vlax-get sheet 'cells)
            roll 1
            n 0
        )

        (vla-put-Visible excel :vlax-true)

        (vlax-put-property cells 'Item roll 1 "REG")
        (vlax-put-property cells 'Item roll 2 "Norte")
        (vlax-put-property cells 'Item roll 3 "Este")

        (repeat Size
            (if 3d
                (setq
                    Points(vl-list*
                                (list
                                    (nth (setq Count(1+ Count)) Coords)
                                    (nth (setq Count(1+ Count)) Coords)
                                    (nth (setq Count(1+ Count)) Coords)
                                )
                                Points
                            )
                )
                (setq
                    Points(vl-list*
                                (list
                                    (nth (setq Count(1+ Count)) Coords)
                                    (nth (setq Count(1+ Count)) Coords)
                                )
                                Points
                            )
                )
            )
        )

        (setq Points(reverse Points))

        (foreach Point Points
            (progn
                (setq col 3 roll(1+ roll))

                (vlax-put-property cells 'Item roll 1 (setq n (1+ n)) )
                (vlax-put-property cells 'Item roll 2 (cadr Point))
                (vlax-put-property cells 'Item roll 3 (car Point))

                (foreach MLH (ssnamex AC3DMLH)
                    (progn
                        (setq
                            MLH (vlax-ename->vla-object (cadr MLH))
                            MLHName (vlax-get MLH 'Name)
                            Elevation (vl-catch-all-apply 'vlax-invoke (list MLH 'FindElevationAtXY (car Point) (cadr Point) ))
                        )
                        (if (vl-catch-all-error-p Elevation)
                            (vlax-put-property cells 'Item roll (setq col(1+ col)) "-")
                            (vlax-put-property cells 'Item roll (setq col(1+ col)) Elevation)
                        )

                        (vlax-put-property cells 'Item 1 col MLHName)
                    )
                )
            )
        )

        
        (vla-EndUndoMark doc)
        (princ)
    )
    (defun *error*(s)
        (princ s)
        (princ "\nLine, Circle, Arc, Point ou qualquer outra entidade nao e compactivel...")
        (vla-EndUndoMark doc)
        (princ)
    )
    (main)
)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g