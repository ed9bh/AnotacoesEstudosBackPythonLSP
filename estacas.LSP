;;;Programas para auxilio de projeto. Estaqueia um eixo.
(defun c:estacas()
  (vl-load-com)
  (command"undo""be")
  (setq estINI(getreal"\nEstaca inicial [0]: ")
	estINI(if(= estINI nil)0 estINI)
	dist(getreal"\tDigite a distancia entre as estacas [20]: ")
	dist(if(= dist nil)20 dist)
	inter(if(= dist 20)(progn(initget 1 "5 10 Não")(getkword"\nDeseja inserir estacas intermediarias?[5/10/Não]: "))nil)
	>i<(cond((= inter "Não")"AB")((= inter "5")"A")((= inter "10")"B"))
	<i> 0
	inter(if(/= inter "Não")(read inter)nil)
	dist(cond((= inter nil)dist)((= inter 5)(/ dist 4))((= inter 10)(/ dist 2)))
	eixoSS nil
	)
  (while(/= "LWPOLYLINE"(cdr(assoc 0 eixoSS)))
    (setq eixo(entsel"\nSelecione a polylinha do eixo: ")
	  eixoSS(entget(car eixo))
	  )
    )
  (setq >dis<(vlax-get(vlax-ename->vla-object(car eixo))'Length)
	>est<(fix(/ >dis< dist))
	<d> 0
	pontos nil
	pontos(cons(cons 10(vlax-curve-getpointatdist (car eixo) 0))pontos)
	pontosEST pontos
	pontosEST(cons(cons 10(vlax-curve-getpointatdist (car eixo) 0.01))pontos)
	)
  (repeat(1+ >est<)
    (setq pontos
	   (cons
	     (cons 10(vlax-curve-getpointatdist(car eixo)(*(setq <d>(1+ <d>))dist)))
	     pontos)
	  )
    (setq pontosEST(cons(cons 10(vlax-curve-getpointatdist(car eixo)(-(* <d> dist)0.01)))pontosEST)
	  pontosEST(cons(cons 10(vlax-curve-getpointatdist(car eixo)(+(* <d> dist)0.01)))pontosEST)
	  )
    )
  (setq pontos(reverse pontos)pontosEST(cdr pontosEST)pontosEST(reverse pontosEST))
  (repeat(1+ >est<)
    ;(entmake(list(cons 0 "point") (car pontos)))
    (if(cdr pontosEST)
      (progn
	(setq ang(angle(cdr(car pontosEST))(cdr(cadr pontosEST)))
	      ang+(+(angle(cdr(car pontosEST))(cdr(cadr pontosEST)))1.5708)
	      ang-(-(angle(cdr(car pontosEST))(cdr(cadr pontosEST)))1.5708)
	      cTE(cons 10(trans(polar(cdr(car pontos)) ang+ 1.25)0 1))
;;;	      cTE(trans(polar(cdr(car pontos)) ang+ 1.25)0 1)
;;;	      cTE(list(car cTE)(cadr cTE))
	      cTiE(cons 10(trans(polar(cdr(car pontos)) ang+ 0.75)0 1))
	      cLA(cons 10(trans(polar(cdr(car pontos)) ang+ 1)0 1))
	      cLB(cons 11(trans(polar(cdr(car pontos)) ang- 1)0 1))
	      cLiA(cons 10(trans(polar(cdr(car pontos)) ang+ 0.5)0 1))
	      cLiB(cons 11(trans(polar(cdr(car pontos)) ang- 0.5)0 1))
	      )
	(cond((= <i> 0)
	      (progn
		(entmake(list '(0 . "line") (assoc 8 eixoSS) cLA cLB))
;;;		(vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
;;;		  (rtos estINI 2 0)
;;;		  (vlax-3d-point cTE)
;;;		  1.50
;;;		  )
		(entmake(list '(0 . "text") (assoc 8 eixoSS) cTE
			      (cons 1 (rtos estINI 2 0)) '(40 . 1.50) (cons 50 ang)
			      )
			)
		(vlax-put(vlax-ename->vla-object(entlast))'Alignment acAlignmentBottomCenter)
		(vla-put-textalignmentpoint(vlax-ename->vla-object(entlast))(vlax-3d-point(cdr cTE)))
		))
	     ((and(= >i< "B")(= <i> 1))
	      (progn
		(entmake(list '(0 . "line") (assoc 8 eixoSS) cLiA cLiB))
		(entmake(list '(0 . "text") (assoc 8 eixoSS)
			      cTiE (cons 1 "+10") '(40 . 1.25) (cons 50 ang)
			      )
			)
		(vlax-put(vlax-ename->vla-object(entlast))'Alignment acAlignmentBottomCenter)
		(vla-put-textalignmentpoint(vlax-ename->vla-object(entlast))(vlax-3d-point(cdr cTiE)))
		))
	     ((and(= >i< "A")(= <i> 1))
	      (progn
		(entmake(list '(0 . "line") (assoc 8 eixoSS) cLiA cLiB))
		(entmake(list '(0 . "text") (assoc 8 eixoSS)
			      cTiE (cons 1 "+5") '(40 . 1.25) (cons 50 ang)
			      )
			)
		(vlax-put(vlax-ename->vla-object(entlast))'Alignment acAlignmentBottomCenter)
		(vla-put-textalignmentpoint(vlax-ename->vla-object(entlast))(vlax-3d-point(cdr cTiE)))
		))
	     ((and(= >i< "A")(= <i> 2))
	      (progn
		(entmake(list '(0 . "line") (assoc 8 eixoSS) cLiA cLiB))
		(entmake(list '(0 . "text") (assoc 8 eixoSS)
			      cTiE (cons 1 "+10") '(40 . 1.25) (cons 50 ang)
			      )
			)
		(vlax-put(vlax-ename->vla-object(entlast))'Alignment acAlignmentBottomCenter)
		(vla-put-textalignmentpoint(vlax-ename->vla-object(entlast))(vlax-3d-point(cdr cTiE)))
		))
	     ((and(= >i< "A")(= <i> 3))
	      (progn
		(entmake(list '(0 . "line") (assoc 8 eixoSS) cLiA cLiB))
		(entmake(list '(0 . "text") (assoc 8 eixoSS)
			      cTiE (cons 1 "+15") '(40 . 1.25) (cons 50 ang)
			      )
			)
		(vlax-put(vlax-ename->vla-object(entlast))'Alignment acAlignmentBottomCenter)
		(vla-put-textalignmentpoint(vlax-ename->vla-object(entlast))(vlax-3d-point(cdr cTiE)))
		))
	)
;;;	(vla-put-alignment(vlax-ename->vla-object(entlast))acAlignmentBottomCenter)
;;;	(vla-put-rotation(vlax-ename->vla-object(entlast))ang)
;;;	(vla-put-layer(vlax-ename->vla-object(entlast))eixoSS)
	(setq <i>(1+ <i>))
	(cond((= >i< "AB")(setq <i> 0 estINI(1+ estINI)))
	     ((and(= >i< "A")(= <i> 4))(setq <i> 0 estINI(1+ estINI)))
	     ((and(= >i< "B")(= <i> 2))(setq <i> 0 estINI(1+ estINI)))
	     )
	)  
      )
    ;(cons 0 "text")(cons 1 txt)(cons 8 l)(cons 7 (getvar"textstyle"))(cons 10(list x y))(cons 40 h)(cons 50 r)
		  
    
    (setq pontos(cdr pontos)
	  pontosEST(cdr pontosEST)pontosEST(cdr pontosEST)
	  )
    )
  (command"undo""e")
  (princ)
  )

;|
DESENVOLVEDOR: ERIC DRUMOND - 06/2013
CONTATO:
	EMAIL:	ericdrumond@gmail.com
	
Este Lisp foi importante pra você e quer fazer uma doação?
https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=CVRHG2B25BPXW&lc=BR&item_name=Desenvolvimento%20AutoLisp&currency_code=BRL&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted

-----------------------------------------------------------------------------------------------
OBRIGADO POR UTILIZAR ESTE LISP, DIVULGUE E MODIFIQUE MÁS NÃO TIRE A PROPRIEDADE DESTE LISP. :)
-----------------------------------------------------------------------------------------------
|;