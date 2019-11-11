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
                        
                        (vlax-invoke-method vx 'GetBoundingBox 'Dest01 'Dest02)
                        (vlax-invoke-method Entity 'GetBoundingBox 'Orig01 'Orig02)
                        
                        (setq
                            ORI1 (vlax-safearray->list Orig01)
                            ORI2 (vlax-safearray->list Orig02)
                            ORI3 (list (car ORI1) (cadr ORI2) (caddr ORI2))
                            DES1 (vlax-safearray->list Dest01)
                            DES2 (vlax-safearray->list Dest02)
                            DES3 (list (car DES1) (cadr DES2) (caddr DES2))
                        )
                        
                        (setq eEntity (entget(vlax-vla-object->ename Entity)))

                        (entmod (subst (cons 45 1) (assoc 45 eEntity) eEntity))

                        (vla-Delete vx)

                        (vla-Move Entity (vlax-3d-point ORI3) (vlax-3d-point DES3))

                        ;(foreach www (list ORI1 DES1 ORI2 DES2)
                        ;    (princ www)
                        ;)

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