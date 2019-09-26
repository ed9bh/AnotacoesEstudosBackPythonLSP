(defun c:xmtext (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            p1(getpoint "\nPrimeiro ponto da janela de selecao : ")
            p2(getcorner p1 "\tPonto Final : ")
            ssset(ssget "w" p1 p2 '((0 . "text")))
            model(vla-get-ModelSpace doc)
        )

        (foreach x (ssnamex ssset)
            (progn
                (if(= 2 (car x))
                    (progn
                        (setq
                            vx (vlax-ename->vla-object (cadr x))
                            PointInsert (vlax-get vx 'InsertionPoint)
                            PointInsertAlig (vlax-get vx 'TextAlignmentPoint)
                            TString (vlax-get vx 'TextString)
                            Layer (vlax-get vx 'Layer)
                            Height (vlax-get vx 'Height)
                            Color (vlax-get vx 'TrueColor)
                            Style (vlax-get vx 'StyleName)
                            Rotation (vlax-get vx 'Rotation)
                            Entity (vla-AddMText model (vlax-3d-point PointInsert) 0 TString)
                        )
                        ;(*(1- (strlen TString))Height)
                        (vlax-put Entity 'Layer Layer)
                        (vl-catch-all-apply 'vlax-put (list Entity 'TextAlignmentPoint PointInsertAlig))
                        (vlax-put Entity 'Height Height)
                        (vlax-put Entity 'Rotation Rotation)
                        (vlax-put Entity 'TrueColor Color)
                        (vlax-put Entity 'StyleName Style)
                        (vlax-put Entity 'BackgroundFill -1)
                        
                        (setq eEntity (entget(vlax-vla-object->ename Entity)))

                        (entmod (subst (cons 45 1) (assoc 45 eEntity) eEntity))

                        (vla-Delete vx)
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

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g