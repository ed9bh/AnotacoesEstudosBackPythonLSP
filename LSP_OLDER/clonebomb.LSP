(vl-load-com)
(defun c:clonebomb()
  (prompt"\nSelecione os objextos a explodir: ")
  (setq
    ss(ssget)
    )
  (mapcar'(lambda(x)
	    (vlax-invoke
	      (vlax-ename->vla-object(cadr x))
	      'Explode
	      )
	    )
	 (cdr(reverse(ssnamex ss)))
	 )
  (princ)
  )
