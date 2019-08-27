(defun c:getarea(/ *error* acad doc model eEnty vEnty ss c h)
	(defun *error*(msg)
		(princ (strcat "\nErro de execução : " msg))
		(vla-EndUndoMark doc)
		(princ)
	)

	(setq
		acad(vlax-get-acad-object)
		doc(vla-get-ActiveDocument acad)
		model(vla-get-ModelSpace doc)
	)

	(vla-StartUndoMark doc)

	(setq
		eEnty(entsel "\nSelecione entidade a extrair a área : ")
	)

	(if eEnty
		(setq vEnty(vlax-ename->vla-object (car eEnty)))
		(quit)
	);(vlax-dump-Object(vlax-ename->vla-object(car(entsel)))t)

	; Height

	(if (= (vlax-property-available-p vEnty 'Area) t)
		(setq area (vlax-get vEnty 'Area))
		(quit)
	)

	(setq
	 ss(ssnamex(ssget "x" '((0 . "text,mtext"))))
	 c 0
	 h 0
	)

	(foreach s ss
		(progn
			(setq
				c(1+ c)
				s(vlax-ename->vla-object (cadr s))
				h( + (vlax-get s 'Height) h )
			)
		)
	)

	(setq h( / h c))

	(setq
		point(getpoint "\nClique no ponto para inserir o texto : ")
	)

	(setq mtext(vla-AddMText model (vlax-3d-point point) h (strcat "Área : "(rtos area) " m²") ))
	(vla-put-Height mtext h)
	(vlax-put mtext 'BackgroundFill -1)

(vla-EndUndoMark doc)
(princ)
)

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g