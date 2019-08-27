(defun c:renblk()
	(setq
		acad(vlax-get-acad-object)
		doc(vla-get-ActiveDocument acad)
		model(vla-get-ModelSpace doc)
	)
	
	(vla-StartUndoMark doc)

	(setq erro *error*)

	(defun *error*(msg)
		(princ msg)
		(setq *error* erro)
		(vla-EndUndoMark doc)
	)

	(setq
		eBLk(entsel"\nSelecione o Bloco : ")
		vBLK(vlax-ename->vla-object(car eBLK))
	)

	(if (= (vlax-property-available-p vBLK 'EffectiveName) t)
		(setq name (vla-get-EffectiveName vBLK))
		(setq name (vla-get-Name vBLK))
	)

	(setq newName(getstring "\nDigite o novo nome : "))
;|

	(if (= (vlax-property-available-p vBLK 'Name) t)
		(setq rr (vl-catch-all-apply 'vlax-put-property (list vBLK 'EffectiveName newName)))
		(setq rr (vl-catch-all-apply 'vlax-put-property (list vBLK 'Name newName)))
	)

	(princ (vl-catch-all-error-message rr))

|;

;	(entmod (subst (cons 2 newName) (assoc 2 (entget(car eBLK))) (entget(car eBLK))))

	(command "-rename" "block" Name newName)

	(vla-EndUndoMark doc)
	(setq *error* erro)
	(princ)
)

