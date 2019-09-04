;(entget(car(entsel)))
;(vlax-dump-object(vlax-ename->vla-object(car(entsel))))
(defun c:ns()
  (vl-load-com)
  (setq
    eixos(ssnamex (ssget"x"'((0 . "line") (410 . "Model") (8 . "EPC00SecLinhas") (62 . 2) (6 . "DIVIDE"))))
    terrenos(ssnamex (ssget"x"'((0 . "lwpolyline") (410 . "Model") (8 . "EPC00SecTracTerrenoNatural") (62 . 4))))
    greides(ssnamex (ssget"x"'((0 . "lwpolyline") (410 . "Model") (8 . "EPC00SecTracGreide") (62 . 6) (6 . "Continuous"))))
    malhas(ssnamex (ssget"x"'((0 . "line") (410 . "Model") (8 . "EPC00SecLinhas") (62 . 9) (6 . "Continuous"))))
    cotas(ssnamex (ssget"x" '((0 . "mtext") (410 . "Model") (8 . "EPC02TX") (62 . 2) (1 . "CP=*******"))) )
    estacas(ssnamex (ssget"x" '((0 . "mtext") (410 . "Model") (8 . "EPC03TX") (62 . 4) (1 . "ESTACA - *"))) )
    os(getvar'osmode)
    bigLeft nil
    bigRight nil
    NotaServicoLinha nil
    arq(open(strcat(getvar'dwgprefix)"NostasDeServico_"(getvar'dwgname)".txt")"w")
    )
  (foreach x eixos
    (ns x)
    )

  ;;;
  (setq secBig(apply'max bigLeft))
  (setq NotaServicoLinha (vl-sort NotaServicoLinha '(lambda (a b) (< (car a) (car b) ))))
  ; KM / Estaca / OffSet Esquerdo / Distancias / Eixo [Cota Terreno, Cota Greide, Cota Vermelha] / Distancias / OffSet Direito
  (foreach x NotaServicoLinha
    (progn
      (setq espacos (- secBig (length(nth 3 x)))
	    esp ""
	    esq(apply'append(nth 3 x))
	    dir(apply'append(nth 7 x))
	    distEsq ""
	    distDir ""
	    )
      ;(princ espacos)
      (repeat(1-(* espacos 2))(setq esp(strcat esp "\t")))
      (foreach e esq
	(setq distEsq(strcat distEsq (rtos e 2 2) "\t"))
	)
      (foreach d dir
	(setq distDir(strcat distDir (rtos d 2 2) "\t"))
	)
      ;|
(10.0
"0+10,00"
(-37.2856 651.03 0.0)
((-33.002 644.44 0.0) (-33.0 642.44 0.0) (-25.0 642.6 0.0) (-20.0 642.6 0.0))
650.219 643.0 7.2193
((20.0 642.6 0.0) (25.0 642.6 0.0)) (25.002 644.6 0.0))
|;
      (setq linha(strcat
		   (rtos(nth 0 x)2 2)	 		; KM
		   "\t"
		   (nth 1 x)				; Estaca
		   "\t"
		   (rtos(car(nth 2 x))2 2)		; OffSet Dist
		   "\t"
		   (rtos(cadr(nth 2 x))2 2)		; OffSet Cota
		   esp
		   distEsq				;Distancias Esquerdas
		   (rtos(nth 4 x)2 2)			; Cota Terreno
		   "\t"
		   (rtos(nth 5 x)2 2)			; Cota Greide
		   "\t"
		   (rtos(nth 6 x)2 2)			; Cota Vermelha
		   "\t"
		   distDir				;Distancias Direitas
		   (rtos(car(nth 8 x))2 2)		; OffSet Dist
		   "\t"
		   (rtos(cadr(nth 8 x))2 2)		; OffSet Cota
		   ;"\n"
		   )
	    )
      (setq linha(vl-string-translate "." "," linha))
      (write-line linha arq)
      (princ linha)
      (princ "\n")
      )
    )
  (close arq)
  (princ"\nPronto!!!")
  (princ)
  )


(defun ns(zzz);/ vest terreno greide EList CList string dist c n cota point cotaVermelha left right )
  (setq
    zzz (cadr zzz)
    ;zzz (cadr(nth 0 eixos))
    erro -1
     )
  (setq xest zzz
	vest (vlax-ename->vla-object zzz)
	)
  
  (princ"Terreno Natural")
  (foreach x terrenos
    (progn
      (setq
	x (vlax-ename->vla-object(cadr x))
	)
      (if (vlax-invoke vest 'IntersectWith x acExtendNone)
	(setq terreno x )
	)
      )
    )
  
  (princ"Greide")
  (foreach x greides
    (progn
      (setq
	x (vlax-ename->vla-object(cadr x))
	)
      (if (vlax-invoke vest 'IntersectWith x acExtendNone)
	(setq greide x )
	)
      )
    )
  
  (princ"Estaca")
  (setq EList nil)
  (foreach x estacas
    (progn
      (setq
	x (vlax-ename->vla-object(cadr x))
	string (vlax-get x 'TextString)
	estaca (substr string 10)
	point (vlax-get x 'InsertionPoint)
	dist (distance point (vlax-get vest 'EndPoint))
	EList(vl-list* (list dist estaca) EList )
	)
      )
    )
  (setq EList (vl-sort EList '(lambda (a b) (< (car a) (car b))))
	estaca (cadr(car EList))
	)
  
  (princ"Referenciando")
  (setq CList nil)
  (foreach x cotas
    (progn
      (setq
	x (vlax-ename->vla-object(cadr x))
	string (vlax-get x 'TextString)
	cota (read(vl-string-translate "," "." (substr string 4)))
	point (vlax-get x 'InsertionPoint)
	dist (distance point (vlax-get vest 'StartPoint))
	CList(vl-list* (list dist cota) CList )
	)
      )
    )
  (setq CList (vl-sort CList '(lambda (a b) (< (car a) (car b))))
	cota (cadr(car CList))
	rPoint(vlax-invoke vest 'IntersectWith greide acExtendNone)
	rpoint(list (car rPoint) (cadr rPoint) (caddr rPoint))
	tPoint(vlax-invoke vest 'IntersectWith terreno acExtendNone)
	tPoint(list (car tPoint) (cadr tPoint) (caddr tPoint))
	)
  (command"ucs""")
  (setvar'osmode 0)
  (command"ucs""o" rPoint )
  (command"ucs""o" (list 0 (* cota -1) 0) )
  (setvar'osmode os)

  ;(princ"Listando Pontos\n")
  ;(princ(rtos(setq erro(1+ erro))2 0))
  (princ"\n")
  (setq
    coords(progn
	    (setq coords nil
		  n -1
		  greidecoords (vlax-get greide 'Coordinates)
		  )
	    (repeat(/(length greidecoords)2)
	      (setq coords
		     (vl-list*
		       (trans
			 (list
			   (nth(setq n(1+ n))greidecoords)
			   (nth(setq n(1+ n))greidecoords)
			   )
			 0 1)
		       coords
		       )
		    )
	      )
	    )
    coords(vl-sort coords '(lambda (a b) (<(car a)(car b))))
    cotaVermelha(-(cadr tPoint)(cadr rpoint))
    n -1
    left 0
    right 0
    )

  (princ(rtos(setq erro(1+ erro))2 0))
  (princ"\n")
  (repeat(length coords)
    (setq c (car(nth (setq n(1+ n)) coords))
	  )
    (if(< c 0)
      (setq left (1+ left))
      (setq right (1+ right))
      )
    )
  (setq bigLeft(vl-list* left bigLeft)
	bigRight(vl-list* right bigRight)
	)
  (setq NSLeftPoints nil
	NSRightPoints nil
	OffSetEsq (nth 0 coords)
	OffSetDir (nth (1-(length coords)) coords)
	n 0
	)
  
  ;(princ(rtos(setq erro(1+ erro))2 0))
  ;(princ"\n")
  (repeat(-(length coords)2);(nth n coords)
    (setq point(nth(setq n(1+ n))coords)
	  )
    (if(< (car point) 0)
      (setq NSLeftPoints (vl-list* (list (car point) (cadr point)) NSLeftPoints))
      )
    (if(> (car point) 1)
      (setq NSRightPoints (vl-list* (list (car point) (cadr point)) NSRightPoints))
      )
    )

  ;(princ(rtos(setq erro(1+ erro))2 0))
  ;(princ"\n")
  (setq NSLeftPoints(reverse NSLeftPoints)
	NSRightPoints(reverse NSRightPoints)
	EixoTer(cadr(trans tPoint 0 1))
	EixoGre(cadr(trans rPoint 0 1))
	km(+(*(read(substr estaca 1 (vl-string-position(ascii"+")estaca)))20) (read(vl-string-translate "," "." (substr estaca (+(vl-string-position(ascii"+")estaca)2) ))))
	)

  ; KM / Estaca / OffSet Esquerdo / Distancias / Eixo [Cota Terreno, Cota Greide, Cota Vermelha] / Distancias / OffSet Direito
  (setq NotaServicoLinha(vl-list* (list km estaca OffSetEsq NSLeftPoints EixoTer EixoGre CotaVermelha NSRightPoints OffSetDir) NotaServicoLinha))
  (command"ucs""")
  )