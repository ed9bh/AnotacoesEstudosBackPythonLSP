(defun c:ExtractProfile (/ *error* doc model file ent vEnt n count point vPoint)
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
		count(/(length(vlax-safearray->list(vlax-variant-value (vlax-get-property vEnt 'Coordinates ))))2)
		n 0
        file(open (strcat (getvar '"dwgprefix") "ProfilePoints.txt" ) "w")
	)

	(repeat count
		(setq
			point(vlax-safearray->list (vlax-variant-value (vlax-get-property vEnt 'Coordinate n)))
			vPoint(vla-AddPoint model (vlax-3d-point point))
			n(1+ n)
		)
        (write-line (strcat (rtos (nth 0 point) 2 6) " " (rtos (nth 1 point) 2 6) ) file )
	)

    (close file)

    
    (vla-EndUndoMark doc)
    (princ)
)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g