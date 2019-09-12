(defun c:herdarElevacao (/ *error* main doc)
    (vl-load-com)
    (defun main ()
        (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))

        (setq
            blk(entsel "\nSelecione o bloco com a eleva??o : ")
            pline(entsel "\tSelecione a polylinha a herdar : ")
        )

        (if blk
            (setq blk(vlax-ename->vla-object (car blk)))
            (quit)
        )

        (if pline
            (setq pline(vlax-ename->vla-object (car pline)))
        )

        (setq
            elev(vlax-get blk 'InsertionPoint)
            elev(nth 2 elev)
        )

        (vlax-put pline 'Elevation elev)
        
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
