;;;Substitui texto
(defun c:sut()
  (vl-load-com)
  (setq
    txtbase (entsel "\nSelecione o texto base: ")
    txtbase (if	txtbase
	      (vlax-ename->vla-object (car txtbase))
	      (quit)
	    )
    text    (vlax-get txtbase 'TextString)
  )
  (princ "\nSelecione os texto de destino: ")
  (setq
    txtdest (ssget '((0 . "text")))
    txtdest (cond
	      ((= (length (ssnamex txtdest)) 1) (ssnamex txtdest))
	      ((/= txtdest nil) (cdr (reverse (ssnamex txtdest))))
	      (quit)
	    )
  )
  (mapcar '(lambda (x)
	     (vlax-put (vlax-ename->vla-object (cadr x))
		       'TextString
		       text
	     )
	   )
	  txtdest
  )
  (princ)
)