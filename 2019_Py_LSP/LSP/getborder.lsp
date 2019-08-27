(defun c:getborder(/ *error* eEnty border)
	(defun edg:action(eEnty)
		(setq
			vEnty(vlax-ename->vla-object eEnty)
		)
		(setq
			border(vl-catch-all-apply 'vlax-invoke-method (list vEnty 'ExtractBorder 1))
		)
	)

	(defun *error*(msg)
		(princ (strcat "\nErro : "msg))
		(if border
			(print(vl-catch-all-error-message border))
		)
		(princ)
	)
	
	(setq
		eEnty(entsel "\nSelecione a Malha Triangular do Civil 3D : ")
		)
	
	(if eEnty
		(setq eEnty(car eEnty))
	)

	(edg:action eEnty)

	(princ)
	)


;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g