(defun c:ExtractProfile (/ *error* doc model file ent vEnt n count point vPoint dist elev pvi GetCoordError)
    (defun *error*(s)
        (princ s)
        (if file
            (close file)
        )
        (vla-EndUndoMark doc)
        (princ)
    )
    (vl-load-com)
    (vla-StartUndoMark (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))))


    (setq
        ent(entsel "\nSelecione o perfil a extrair dados : ")
    )

    (if ent
        (setq vEnt(vlax-ename->vla-object(car ent)))
        (quit)
    )

    (setq
        model(vla-get-ModelSpace doc)
		n 0
        file(open (strcat (getvar '"dwgprefix") "ProfilePoints.txt" ) "w")
	)

	(while (= (vl-catch-all-error-p GetCoordError) nil)
		(setq
            pvi(vl-catch-all-apply 'vlax-get (list vEnt 'PVIs))
            GetCoordError(setq pvi(vl-catch-all-apply 'vlax-invoke (list pvi 'Item n)))
        )
        
        (if (= (vl-catch-all-error-p GetCoordError) nil)
            (progn
                (setq
                    dist(vlax-get pvi 'Station)
                    elev(vlax-get pvi 'Elevation)
                )
                (write-line (strcat (rtos dist 2 6) " " (rtos elev 2 6) ) file )
            )
        )

        (setq n(1+ n))

        ;(if (vl-catch-all-error-p GetCoordError)
        ;    (print (vl-catch-all-error-message GetCoordError))
        ;)

	)

    (close file)

    
    (vla-EndUndoMark doc)
    (princ)
)