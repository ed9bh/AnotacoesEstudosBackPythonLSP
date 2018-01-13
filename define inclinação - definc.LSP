(defun c:definc(/ plBjt ptDist porInc plEBjt
		plLength plCoords n ptList
		pA pB c xa ya xb yb percent lay)
  (vl-load-com)
  (setq plBjt(entsel"\nSelecione a polyline: ")
	ptDist 1.0000
	porInc(abs(getreal"\tDigite a porcentagem maxima de inclinação: "))
	plEBjt(vlax-ename->vla-object(car plBjt))
	plLength(vlax-get plEBjt 'Length)
	)
  (setq	plCoords(progn
		  (setq plCoords(list(vlax-curve-getstartpoint plEBjt))
			n ptDist
			)
		  (repeat(fix(/ plLength ptDist))
		    (setq plCoords(vl-list*
				    (vlax-curve-getpointatdist plEBjt n)
				    plCoords
				    )
			  n(+ n ptDist)
			  )
		    )
		  (if(=(car(car plCoords))(car(vlax-curve-getendpoint plEBjt)))
		    nil
		    (setq plCoords(vl-list*
				    (vlax-curve-getendpoint plEBjt)
				    plCoords
				    )
			  )
		    )
		  (reverse plCoords)
		  )
	ptList(list(car plCoords))
	pA nil pB nil
	)
  (repeat(1-(length plCoords))
    (setq pA(if(= pA nil)(nth 0 plCoords)pB)
	  pB(if(= pB nil)(nth(setq n 1)plCoords)(nth(setq n(1+ n))plCoords))
	  c 0
	  )
    (setq xa(car pA)ya(cadr pA)xb(car pB)yb(cadr pB)
	  percent(*(/(- yb ya)(- xb xa))100)
	  )
    (if(=(+(abs percent)percent)0)
      (while(< percent(- porInc))
	(setq yb(+ yb 0.001)
	      percent(*(/(- yb ya)(- xb xa))100)
	      pB(list xb yb 0)
	      )
	)
      (while(> percent porInc)
	(setq yb(- yb 0.001)
	      percent(*(/(- yb ya)(- xb xa))100)
	      pB(list xb yb 0)
	      )
	)
      )
    (setq ptList(vl-list* pB ptList))
    )
  (setq angLst(progn
		(setq n 0 angLst nil PlPtLst nil ptLst ptList prec 0.9999)
		(repeat(1-(length ptLst))
		  (setq angA(angtos(angle(nth n ptLst)(nth(setq n(1+ n))ptLst))0 4)
			angLst(vl-list* angA angLst)
			)
		  (if(>(length angLst)1)
		    (if(equal(read angA)(read angB)prec)
		      (princ)
		      (setq PlPtLst(vl-list*(nth(1- n)ptLst)PlPtLst))
		      )
		    (setq PlPtLst(vl-list*(nth 0 ptLst)PlPtLst))
		    )
		  (if(= angB nil)(setq angB angA))
		  (if(equal(read angA)(read angB)prec)(princ)(setq angB angA))
		  )
		(reverse angLst)
		)
	)
  (setq PlPtLst(vl-list*(nth 0(reverse ptLst))PlPtLst)
	ptList(apply'append(reverse PlPtLst))
	lay(strcat"LINHA_GREIDE_INCLINACAO_-"
		  (rtos porInc 2 1)"%-_"
		  (vl-registry-read "HKEY_CURRENT_USER\\VOLATILE ENVIRONMENT" "USERNAME")
		  "_-D_"(rtos(getvar"cdate")2 0)
		  "_H_"(rtos(*(-(GETVAR"CDATE")(FIX(GETVAR"CDATE")))10000)2 0)
		  )
	)
  (entmake(list'(0 . "LAYER")'(100 . "AcDbSymbolTableRecord")'(100 . "AcDbLayerTableRecord")(cons 2 lay)'(6 . "Continuous")'(62 . 250)'(70 . 0)))
  (vla-addpolyline
    (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length ptList))))ptList))
    )
  (vlax-put(vlax-ename->vla-object(entlast))'Color 135)
  (vla-put-layer
    (vlax-ename->vla-object(entlast))
    lay
    )
  (princ)
  )


;|
DESENVOLVEDOR: ERIC DRUMOND - 07/2013
CONTATO:
	EMAIL:	ericdrumond@gmail.com
	
Este Lisp foi importante pra você e quer fazer uma doação? https://goo.gl/5yor73
-----------------------------------------------------------------------------------------------
OBRIGADO POR UTILIZAR ESTE LISP, DIVULGUE E MODIFIQUE MÁS NÃO TIRE A PROPRIEDADE DESTE LISP. :)
-----------------------------------------------------------------------------------------------
|;