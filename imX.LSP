(vl-load-com)
(defun c:imX(/ r rb rc)
  (initget 8 "Desativar Ativar Back")
  (setq
    r
     (getpoint
       "\nOpções para as imagens[Desativar todas / Ativar todas / draworder Back]<Ponto inicial do retangulo de seleção>: "
       )
    )
  (cond
    ((= r "Desativar")
     (mapcar'(lambda(x)
	       (vlax-put(vlax-ename->vla-object(cadr x))'ImageVisibility 0)
	       )
	    (ssnamex(ssget"x"'((0 . "image"))))
	    )
     )
    ((= r "Ativar")
     (mapcar'(lambda(x)
	       (vlax-put(vlax-ename->vla-object(cadr x))'ImageVisibility -1)
	       )
	    (ssnamex(ssget"x"'((0 . "image"))))
	    )
     )
    ((= r "Back")
     (mapcar'(lambda(x)
	    (vlax-invoke
	      (vla-addobject
		(vla-GetExtensionDictionary
		  (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
		  )
		"ACAD_SORTENTS" "AcDbSortentsTable"
		)
	      'MoveToBottom;'MoveToTop
	      (list(vlax-ename->vla-object(cadr x)))
	      )
	    )
	 (ssnamex(ssget"x"'((0 . "image"))))
	 )
     )
    ((/= r nil)
     (progn
       (setq
	 rb
	  (getcorner
	    r
	    "\tPonto final: ")
	 rc(ssget"c"r rb'((0 . "image")))
	 )
       (if rc
	 (mapcar'(lambda(x)
		   (vlax-put(vlax-ename->vla-object(cadr x))'ImageVisibility (if(=(vlax-get(vlax-ename->vla-object(cadr x))'ImageVisibility)0)-1 0))
		   )
		(cdr(reverse(ssnamex rc)))
		)
	 )
       )
     )
    ((= r nil)(princ))
    )
  (princ)
  )