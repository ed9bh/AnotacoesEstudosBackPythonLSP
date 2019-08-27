(defun c:xyzCSV()
  (setq
    dir nil
    eEnty(entsel"\nEntidade : ")
    vEnty(vlax-ename->vla-object ( car eEnty ) ) 
    );(vlax-dump-object vEnty t)

  (cond
    ; LWPolyline
    (
     (= (vla-get-objectname vEnty) "AcDbPolyline")
     (setq
       count(/ (length(vlax-safearray->list (vlax-variant-value (vla-get-coordinates vEnty)))) 2)
       xyzList nil
       )
     (repeat count
       (setq
	 xyzList(vl-list*
		  (vlax-safearray->list (vlax-variant-value (vla-get-coordinate vEnty (setq count (1- count)))))
		  xyzList
		  )
	 )
       )
     (setq xyzList(reverse xyzList))
     )

    
    )

  
  (if xyzList
    (progn
      (setq
	dir(getvar'dwgprefix)
	fname(strcat (substr (getvar'dwgname) 1 (- (strlen (getvar'dwgname) ) 3 ) ) "csv")
	file(open (strcat dir fname) "w")
	)
      (mapcar'(lambda(x)
		(write-line
		  (strcat
		    (rtos(car x)2)
		    ";"
		    (rtos(cadr x)2)
		    )
		  file
		  )
		)
	     xyzList
	     )
      (close file)
      )

    )

  (princ)
  )

;;; By Eric Drumond - https://www.youtube.com/channel/UCIG9FBilGznGdNp-_WzHM7g