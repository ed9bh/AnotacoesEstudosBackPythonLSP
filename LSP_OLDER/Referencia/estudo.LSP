(vl-load-com)
(defun c:aaa()
  (setq arq(open(setq xxx(vl-filename-mktemp nil nil".txt"))"w"))
  ;;;;
  (foreach teste
	   '("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	     "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	     "ccccccccccccccccccccccccccccccccccc"
	     "dddddddddddddddddddddddddddddddd"
	     )
    (write-line teste arq)
    )
  (close arq)
  ;;;;
  (command"notepad" xxx "")
  (vl-file-delete xxx)
  (princ)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;(defun _StartUndo ( doc ) (_EndUndo doc)
;;;    (vla-StartUndoMark doc)
;;;  )
;;; 
;;;  (defun _EndUndo ( doc )
;;;    (if (= 8 (logand 8 (getvar 'UNDOCTL)))
;;;      (vla-EndUndoMark doc)
;;;    )
;;;  )
;;;
;;;(setq acdoc (vla-get-ActiveDocument (vlax-get-acad-object)) *segs (cond ( *segs ) ( 10 )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;(defun c:bbb()
;;;  (setq obj(ssget"_:L"'((0 . "circle,lwpolyline")))
;;;	>n<(getint"\nNumero de seguimentos? ")
;;;	)
;;;  (repeat (setq <n> (sslength obj))
;;;    ;;;aqui que é a magica...hahahaha
;;;    (lambda (e / k l i p)
;;;      (setq k(/ (vlax-curve-getDistatParam e (vlax-curve-getEndParam e)) (float >n<))
;;;	    l(entget e)
;;;	    i -1
;;;	    )
;;;      (repeat (1+ >n<)
;;;	(setq p (cons (cons 10(trans(vlax-curve-getPointatDist e (*(setq i(1+ i))k)) 0 e)) p))
;;;	)
;;;      ;(if
;;;	(entmake
;;;	  (append
;;;	    (list
;;;	      (cons 0 "LWPOLYLINE")
;;;	      (cons 100 "AcDbEntity")
;;;	      (cons 100 "AcDbPolyline")
;;;	      (cons 90 (length p))
;;;	      (cons 38 (last(car p)))
;;;	      (cons 70 (if(vlax-curve-isClosed e) 1 0))
;;;	      )
;;;;;;provavel parte que insere os pontos
;;;(apply 'append
;;;       (mapcar '(lambda( a )(if(assoc a l)(list(assoc a l)))) '(6 8 39 48 62 210))
;;;       )
;;;	    p
;;;	    )
;;;	  )
;;;	(entdel e)
;;;	;)
;;;      )
;;;    (ssname obj(setq <n>(1- <n>)))
;;;    )
;;;  )

(defun c:bbb()
  (setq obj(car(entsel"\nPolilinha? "))
	objx(entget obj)
	>n< 20
	>d<(/
	     (vlax-curve-getDistatParam obj(vlax-curve-getEndParam obj))
	     (float >n<)
	     )
	<n> -1
	points nil
	)
  (repeat(1+ >n<)
    (setq points
	   (cons
	     (cons 10
		     (vlax-curve-getpointatdist obj(*(setq <n>(1+ <n>))>d<))
		     )
	     points
	     )
	  )
    )
  (entmake
    (append
      (list
	(cons 0 "LWPOLYLINE")
	(cons 100 "AcDbEntity")
	(cons 100 "AcDbPolyline")
	(cons 90(length points))
	(cons 62 1)
	(cons 38 0)
	(assoc 8 objx)
	(assoc 210 objx)
	)
      points
      )
    )
  )

(defun c:bbb+()
  (setq obj(car(entsel"\nPolilinha? "))
	objx(entget obj)
	>n< (fix(/(vlax-get (vlax-ename->vla-object obj) 'length)10))
	>d< 10
	<n> -1
	points nil
	)
  (repeat(1+ >n<)
    (setq points
	   (cons
	     (cons 10
		     (vlax-curve-getpointatdist obj(*(setq <n>(1+ <n>))>d<))
		     )
	     points
	     )
	  )
    )
  (entmake
    (append
      (list
	(cons 0 "LWPOLYLINE")
	(cons 100 "AcDbEntity")
	(cons 100 "AcDbPolyline")
	(cons 90(length points))
	(cons 62 1)
	(cons 38 0)
	(assoc 8 objx)
	(assoc 210 objx)
	)
      points
      )
    )
  )


;;;
(command"_.pline")(while(= 1(logand 1(getvar'cmdactive)))(command"\\"))
(command-s"_.pline")(while(= 1(logand 1(getvar'cmdactive)))(command-s"\\"))
;;;

;;;
(while (= 5 (car (setq gr (grread 't 13 0))))
  (command"redraw")
  (setq cp (cadr gr)
	p2 (polar '(0 0 0) (angle '(0 0 0) cp) 100)
	)
  (grvecs(list 1 '(0 0 0) cp))
  )
;;;