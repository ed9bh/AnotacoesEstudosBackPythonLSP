(vl-load-com)
(defun c:ddetec(/ p1 p2 dlist ve txt ntxt k c n)
  (setq
    p1
     (getpoint"\nPonto inicial: ")
    p2
     (getcorner p1 "\tPonto Final: ")
    dlist
     (if(and p1 p2)
       (ssget"w"p1 p2'((0 . "text")))
       (quit)
       )
    dlist
     (cdr(reverse(ssnamex dlist)))
    )
  (mapcar'(lambda(x)
	    (progn
	      (setq
		ve
		 (vlax-ename->vla-object(cadr x))
		txt
		 (vlax-get ve 'TextString)
		k
		 nil
		c
		 (strlen txt)
		n
		 -1
		)
	      (if(vl-string-position(ascii ",") txt nil t)
		(princ)
		(progn
		  (setq
		    ntxt
		     (vl-string-subst
		       ","
		       "."
		       txt
		       (vl-string-position(ascii ".") txt nil t)
		       )
		    )
		  (vlax-put ve 'TextString ntxt)
		  )
		)
	      )
	    )	
	 dlist
	 )
  (princ)
  )
