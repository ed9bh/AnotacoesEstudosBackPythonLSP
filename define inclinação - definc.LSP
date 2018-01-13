(defun c:definc(/ plBjt ptDist porInc plEBjt
		plLength plCoords n ptList
		pA pB c xa ya xb yb percent lay)
  (vl-load-com)
  (setq plBjt(entsel"\nSelecione a polyline: ")
	ptDist(abs(getreal"\nDigite a distancia entre os vertices: "))
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
		  (if(=(car plCoords)(vlax-curve-getendpoint plEBjt))
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
  (setq ptList(reverse ptList)
	ptList(apply 'append ptList)
	lay(strcat"LINHA_GREIDE_INCLINACAO_-"
		  (rtos porInc 2 0)"%-_"
		  (vl-registry-read "HKEY_CURRENT_USER\\VOLATILE ENVIRONMENT" "USERNAME")
		  "_-D_"(rtos(getvar"cdate")2 0)
		  "_H_"(rtos(*(-(GETVAR"CDATE")(FIX(GETVAR"CDATE")))10000)2 0)
		  )
	)
  (entdel(entmakex(list'(0 . "point")'(10 0 0 0)(cons 8 lay))))
  (vla-addpolyline
    (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length ptList))))ptList))
    )
  (vlax-put(vlax-ename->vla-object(entlast))'Color 2)
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
	
Este Lisp foi importante pra você e quer fazer uma doação?
https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=CVRHG2B25BPXW&lc=BR&item_name=Desenvolvimento%20AutoLisp&currency_code=BRL&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted

-----------------------------------------------------------------------------------------------
OBRIGADO POR UTILIZAR ESTE LISP, DIVULGUE E MODIFIQUE MÁS NÃO TIRE A PROPRIEDADE DESTE LISP. :)
-----------------------------------------------------------------------------------------------
|;