(defun c:gerarpontos(/ *error* acad doc model)
	(defun *error*(msg)
		(vla-EndUndoMark doc)
		(princ(strcat "\nErro : " msg))
		(princ)
	)

	(setq
		acad(vlax-get-acad-object)
		doc(vla-get-ActiveDocument acad)
		model(vla-get-ModelSpace doc)
	)

	(vla-StartUndoMark doc)

	(command "-layer" "new" "_PointReference_" "" )

	(setq
		ePoly(entsel "\nSelecione a Polylinha : ")
	)

	(if ePoly
		(setq vPoly(vlax-ename->vla-object (car ePoly)))
		(quit)
	)

	(setq
		count(/(length(vlax-safearray->list(vlax-variant-value (vlax-get-property vPoly 'Coordinates ))))2)
		n 0
	)

	(repeat count
		(setq
			point(vlax-safearray->list (vlax-variant-value (vlax-get-property vPoly 'Coordinate n)))
			vPoint(vla-AddPoint model (vlax-3d-point point))
			n(1+ n)
		)
		(vla-put-Layer vPoint "_PointReference_")
	)

(vla-EndUndoMark doc)
(princ)

)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g