; ----- Trajeto ----- ;Centro ----- ;Resize ----- 

(defun c:fk(/ op)
  (vl-load-com)
  (initget 1 "Trajeto Centro Resize")
  (setq op(getkword"[Trajeto / Centro / Resize]: "))
  (cond((= op "Trajeto")(trjt))((= op "Centro")(cntr))((= op "Resize")(rsz)))
  (princ"\nFAST KIT - BY EDG!!!");cntr rsz trjt
	(princ)
  )


;;;RESIZE
(defun rsz(/ entE entV crds crdsX crdsY n pnts len len+)
  (setvar'cmdecho 0)
  (setq
    entE(entsel"\nSelecione a entidade a receber nova escala: ")
    entV(if entE(vlax-ename->vla-object(car entE))(quit))
    crds(progn
	  (setq
	    crdsX nil
	    crdsY nil
	    n(-(setq len+(/(setq len(vlax-get entV
					      (cond
						((=(vlax-get entV 'ObjectName)"AcDbCircle")
						 "Circumference"
						 )
						((/=(vlax-get entV 'ObjectName)"AcDbCircle")
						 "Length"
						 )
						)
					      )
				 )
			   100)
		     )
	       )
	    )
	  (repeat 100
	    (setq
	      crdsX(vl-list*
		     (car(vlax-curve-getpointatdist entV (setq n(+ n len+))))
		     crdsX
		     )
	      crdsY(vl-list*
		     (cadr(vlax-curve-getpointatdist entV n))
		     crdsY
		     )
	      )
	    )
	  )
    )
  (princ
    (strcat
      "\tClique ou digite para definir nova escala. < "
      (rtos(distance(list(apply'min crdsX)(apply'min crdsY))(list(apply'max crdsX)(apply'max crdsY)))2 6)
      " >: "
      )
    )
  (command"scale"
	  entE
	  ""
	  (list
	    (/(+(apply'min crdsX)(apply'max crdsX))2)
	    (/(+(apply'min crdsY)(apply'max crdsY))2)
	    )
	  "r"
	  (list
	    (apply'min crdsX)
	    (apply'min crdsY)
	    )
	  (list
	    (apply'max crdsX)
	    (apply'max crdsY)
	    )
	  )
  (while(= 1(logand 1(getvar'cmdactive)))(command"\\"))
  (setvar'cmdecho 1)(princ)
  )

;;;Trajeto
(defun trjt(/ vlao point pA pB len lenA lenB lenFactor n plist pvlao)
  (prompt"\nSomente linhas, polilinhas, arcos e circulos!!!")
  (vla-getentity
    (vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
    'vlao 'point "\nSelecione a entidade: ")
  (if(or
       (=(vlax-get vlao 'ObjectName)"AcDbLine")(=(vlax-get vlao 'ObjectName)"AcDbPolyline")
       (=(vlax-get vlao 'ObjectName)"AcDbCircle")(=(vlax-get vlao 'ObjectName)"AcDbArc")
       )
    (princ)(quit)
    )
  (setq
    pA(getpoint"\nClique no ponto inicial: ")
    pB(getpoint pA"\tClique no ponto final: ")
    len(vlax-get vlao
		 (cond
		   ((=(vlax-get vlao 'ObjectName)"AcDbCircle")"Circumference")
		   ((=(vlax-get vlao 'ObjectName)"AcDbPolyline")"length")
		   ((=(vlax-get vlao 'ObjectName)"AcDbLine")"length")
		   ((=(vlax-get vlao 'ObjectName)"AcDbArc")"arclength")
		   )
		 );(vlax-dump-object vlao t)(vlax-get vlao 'ObjectName)
    lenA(vlax-curve-getdistatpoint vlao pA)
    lenB(vlax-curve-getdistatpoint vlao pB)
    lenFactor
     (if(or(=(vlax-get vlao 'ObjectName)"AcDbCircle")(=(vlax-get vlao 'ObjectName)"AcDbArc"))
       (abs(/(- lenA lenB)100))
       (/(- lenB lenA)100)
       )
    n(- lenFactor)
    plist nil
    )
  (repeat 101
    (setq
      plist(vl-list*
	     (vlax-curve-getpointatdist vlao
	       (if(=(vlax-get vlao 'ObjectName)"AcDbArc")
		 (+ lenB(setq n(+ n lenFactor)))
		 (+ lenA(setq n(+ n lenFactor)))
		 )
	       )
	     plist
	     )
      )
    )
  (setq plist(apply'append(reverse plist)))
  (setq pvlao(vla-addpolyline
	       (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	       (vlax-make-variant
		 (vlax-safearray-fill
		   (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length plist))))
		   plist
		   )
		 )
	       )
	)
  (mapcar'(lambda(d)(vlax-put pvlao d (vlax-get vlao d)))'("Layer" "LineType"));"Color"
  (princ(strcat"\n\nExtensão do trajeto = "(rtos(vla-get-length pvlao))))
  (princ)
  )

;Centro
(defun cntr(/ ba bb point lenMed factor n plist pvlao)
  (vla-getentity(vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
    'ba 'point "\nSelecione o um bordo: ")
  (vla-getentity(vla-get-utility(vla-get-activedocument(vlax-get-acad-object)))
    'bb 'point "\tSelecione o outro bordo: ")
  (setq
    lenMed(min(vla-get-length ba)(vla-get-length bb))
    factor(/ lenMed (cond
		      ((< lenMed 50)100)
		      ((< lenMed 500)1000)
		      ((< lenMed 5000)10000)
		      ((< lenMed 50000)100000)
		      )
	     )
    n(- factor)
    plist nil
    )
  (repeat(1+(cond((< lenMed 50)100)((< lenMed 500)1000)((< lenMed 5000)10000)((< lenMed 50000)100000)))
    (setq
      pa(vlax-curve-getpointatdist ba (setq n(+ n factor)))
      pb(vlax-curve-getpointatdist bb n)
      plist(vl-list*(list(/(+(car pa)(car pb))2)(/(+(cadr pa)(cadr pb))2)0.000)plist)
      )
    )
  (setq plist(apply'append(reverse plist)))
  (setq pvlao(vla-addpolyline
	       (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
	       (vlax-make-variant
		 (vlax-safearray-fill
		   (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length plist))))
		   plist
		   )
		 )
	       )
	)
  (mapcar'(lambda(d)(vlax-put pvlao d (vlax-get vlao d)))'("Layer" "LineType"));"Color"
  (princ(strcat"\n\nExtensão do centro = "(rtos(vla-get-length pvlao))))
  (princ)
  )
