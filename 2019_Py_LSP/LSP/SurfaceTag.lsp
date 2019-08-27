(defun c:SurfaceTAG (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))
        
        (setq
            eSurface(entsel "\nSelecione a Surface para TAG : ")
            vSurface(vlax-ename->vla-object (car eSurface) )
            point(getpoint "\tClique no ponto para Texto da Surface : ")
            model(vla-get-ModelSpace doc)
            SurfaceName(vlax-get vSurface 'Name)

            SMtext (vla-AddMText model (vlax-3d-point point) 0 SurfaceName)
        )

        (vlax-put SMtext 'Height 2)
        (vlax-put SMtext 'Color 2)
        (vla-put-BackgroundFill SMtext :vlax-true)

        (setq
            change (subst (cons 45 1.0) (cons 45 1.5) (entget(vlax-vla-object->ename SMtext)))
            change (entmod change)
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