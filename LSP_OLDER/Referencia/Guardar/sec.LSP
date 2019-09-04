(defun c:sec1 ()
  (vl-load-com)
  (defun zoom () (vla-zoomextents (vlax-get-acad-object)))
  (defun xlst (xy)
    (setq xList	nil
	  n -2
    )
    (repeat (/ (length xy) 2)
      (setq xList (vl-list* (nth (setq n (+ n 2)) xy) xList))
    )
    xList
  )
  (defun ylst (xy)
    (setq yList	nil
	  n -1
    )
    (repeat (/ (length xy) 2)
      (setq yList (vl-list* (nth (setq n (+ n 2)) xy) yList))
    )
    yList
  )
  (zoom)
  (command "-PURGE" "a" "" "n")
  (setq
    model (vla-get-modelspace
	    (vla-get-activedocument (vlax-get-acad-object))
	  )
    os	  (getvar "osmode")
    blks  (progn
	    (setq blks nil
		  blks (vl-list* (cdr (assoc 2 (tblnext "block" t))) blks)
	    )
	    (while (setq b (tblnext "block"))
	      (setq blks (vl-list* (cdr (assoc 2 b)) blks))
	    )
	    blks
	  )
  )
  (setvar "osmode" 0)
  (repeat (length blks)
    (command "bedit" (car blks))
    (zoom)
;;;Linha Yellow do Eixo
    (vlax-invoke
      (vlax-ename->vla-object
	(setq del
	       (cadr
		 (car (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 2))))
		 )
	       )
	)
      )
      'Explode
    )
    (entdel del)
    (setq LineEixoYellow
	   (vlax-ename->vla-object
	     (cadr
	       (car
		 (ssnamex (ssget "x" '((0 . "line") (62 . 2)))
		 )
	       )
	     )
	   )
    )
;;;Texto
    (setq
      TCTerreno
		 (vlax-ename->vla-object
		   (cadr
		     (car
		       (ssnamex
			 (ssget
			   "x"
			   '((0 . "text") (1 . "Cota do terreno: *************"))
			 )
		       )
		     )
		   )
		 )
      TCProjeto
		 (vlax-ename->vla-object
		   (cadr
		     (car
		       (ssnamex
			 (ssget
			   "x"
			   '((0 . "text") (1 . "Cota do projeto: *************"))
			 )
		       )
		     )
		   )
		 )
      TPoint	 (vlax-get TCTerreno 'InsertionPoint)
      TEstaca
		 (vlax-ename->vla-object
		   (cadr
		     (car
		       (ssnamex
			 (ssget	"w"
				(list (car TPoint) (+ (cadr TPoint) 1.25))
				(list (+ (car TPoint) 50) (+ (cadr TPoint) 6.0))
				'((0 . "text"))
			 )
		       )
		     )
		   )
		 )
      elevter
		 (read (vl-string-left-trim
			 "Cota do terreno: "
			 (vl-string-translate
			   ","
			   "."
			   (vlax-get TCTerreno 'TextString)
			 )
		       )
		 )
      TXTTerreno (vlax-get TCTerreno 'TextString)
      TXTProjeto (vlax-get TCProjeto 'TextString)
      TXTEstaca	 (vlax-get TEstaca 'TextString)
    )
;;;Pline Terreno
    (setq
      plTerreno
       (vlax-ename->vla-object
	 (cadr
	   (car (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 3)))))
	 )
       )
    )
;;;Move Scale
    (command "move"
	     "all"
	     ""
	     (vlax-invoke
	       plTerreno
	       'IntersectWith
	       LineEixoYellow
	       acextendnone
	     )
	     (list 0 elevter)
    )
    (zoom)
    (command "scale"
	     "all"
	     ""
	     (list 0 elevter)
	     0.2
	     ""
    )
    (zoom)
    (setq
      SCTTerreno (vlax-get TCTerreno 'Height)
      INTTerreno (vlax-get TCTerreno 'InsertionPoint)
      SCTProjeto (vlax-get TCProjeto 'Height)
      INTProjeto (vlax-get TCProjeto 'InsertionPoint)
      SCTEstaca	 (vlax-get TEstaca 'Height)
      INTEstaca	 (vlax-get TEstaca 'InsertionPoint)
    )
;;;Apaga Inutilidades
    (mapcar
      '(lambda (x)
	 (if
	   (= (length
		(vlax-get (vlax-ename->vla-object (cadr x)) 'Coordinates)
	      )
	      4
	   )
	    (entdel (cadr x))
	 )
       )
      (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 1))))
    )
    (mapcar '(lambda (x) (entdel (cadr x)))
	    (ssnamex (ssget "x" '((0 . "text") (62 . 3))))
    )
;;;Linhas Gabarito
    (setq
      CoordsLineGabarito
			 (apply
			   'append
			   (mapcar
			     '(lambda (x)
				(vlax-get (vlax-ename->vla-object (cadr x)) 'Coordinates)
			      )
			     (apply 'append
				    (list
				      (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 1))))
				      (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 4))))
					;(ssnamex(ssget"x"'((0 . "lwpolyline")(62 . 54))))
				      (ssnamex (ssget "x" '((0 . "lwpolyline") (62 . 254))))
				    )
			     )
			   )
			 )
      xListGabarito
			 (xlst CoordsLineGabarito)
      yListGabarito
			 (ylst CoordsLineGabarito)
      x<
			 (car (vl-sort xListGabarito '(lambda (x1 x2) (< x1 x2))))
      x>
			 (car (vl-sort xListGabarito '(lambda (x1 x2) (> x1 x2))))
      y<
			 (car (vl-sort yListGabarito '(lambda (y1 y2) (< y1 y2))))
      y>
			 (car (vl-sort yListGabarito '(lambda (y1 y2) (> y1 y2))))
      xcEixo
			 (car (vlax-get LineEixoYellow 'StartPoint))
    )
    (setq
      yMLH< (progn (setq yMLH< 0)
		   (while (< yMLH< y<) (setq yMLH< (+ yMLH< 2)))
	    )
      yMLH> (progn (setq yMLH> 0)
		   (while (< yMLH> y>) (setq yMLH> (+ yMLH> 2)))
	    )
      yMLH< (- yMLH< 4)
      yMLH> (+ yMLH> 4)
      xMLH< (progn (setq xMLH< 0)
		   (while (> xMLH< x<) (setq xMLH< (- xMLH< 2)))
	    )
      xMLH< (if	xMLH<
	      xMLH<
	      10
	    )
      xMLH> (progn (setq xMLH> 0)
		   (while (< xMLH> x>) (setq xMLH> (+ xMLH> 2)))
	    )
      xMLH> (if	xMLH>
	      xMLH>
	      10
	    )
      xMLH< (if	(>= xMLH< -10)
	      -12
	      (- xMLH< 2)
	    )
      xMLH> (if	(<= xMLH> 10)
	      12
	      (+ xMLH> 2)
	    )
      ny    -2
      nx    -2
      t1    (vla-addline
	      model
	      (vlax-3d-point xMLH< (- yMLH< 100))
	      (vlax-3d-point xMLH< (+ yMLH> 100))
	    )
      t2    (vla-addline
	      model
	      (vlax-3d-point xMLH> (- yMLH< 100))
	      (vlax-3d-point xMLH> (+ yMLH> 100))
	    )
      p1    (vlax-get plTerreno 'Coordinates)
      p1    (list (nth 0 p1) (nth 1 p1))
      p2    (vlax-get plTerreno 'Coordinates)
      p2    (list (nth (- (length p2) 2) p2) (nth (1- (length p2)) p2))
    )
    (vla-zoomwindow
      (vlax-get-acad-object)
      (vlax-3d-point
	(list (1- (min (car p1) (car p2)))
	      (1- (min (cadr p1) (cadr p2)))
	)
      )
      (vlax-3d-point
	(list (1+ (max (car p1) (car p2)))
	      (1+ (max (cadr p1) (cadr p2)))
	)
      )
    )
    (if	(> xMLH< (car p1))
      (command "trim"
	       (vlax-vla-object->ename t1)
	       (vlax-vla-object->ename t2)
	       ""
	       p1
	       ""
      )
    )
    (if	(< xMLH> (car p2))
      (command "trim"
	       (vlax-vla-object->ename t1)
	       (vlax-vla-object->ename t2)
	       ""
	       p2
	       ""
      )
    )
    (zoom)
    (entdel (vlax-vla-object->ename t1))
    (entdel (vlax-vla-object->ename t2))
					;Y
    (repeat (/ (- yMLH> yMLH<) 2)
      (setq
	m (vla-addline
	    model			;(vla-add(vla-get-blocks(vla-get-activedocument(vlax-get-acad-object)))(vlax-3d-point'(0. 0. 0.))(car blks))
	    (vlax-3d-point (list xMLH< (+ yMLH< (setq ny (+ ny 2)))))
	    (vlax-3d-point (list xMLH> (+ yMLH< ny)))
	  )
      )
      (vlax-put m 'Color 1)
      (vlax-put m 'Layer "TG")
      (setq mt (read (substr (rtos (+ yMLH< ny) 2 0) 2)))
      (if (cond	((= mt 00) t)
		((= mt 10) t)
		((= mt 20) t)
		((= mt 30) t)
		((= mt 40) t)
		((= mt 50) t)
		((= mt 60) t)
		((= mt 70) t)
		((= mt 80) t)
		((= mt 90) t)
	  )
	(progn
	  (setq	m (vla-addline
		    model
		    (vlax-3d-point (list (1- xMLH<) (+ yMLH< ny)))
		    (vlax-3d-point (list xMLH< (+ yMLH< ny)))
		  )
		x (vla-addtext
		    model
		    (rtos (+ yMLH< ny) 2 0)
		    (vlax-3d-point (list (- xMLH< 1.5) (+ yMLH< ny)))
		    0.1688
		  )
	  )
	  (vlax-put m 'Color 1)
	  (vlax-put x 'Color 3)
	  (vlax-put m 'Layer "TG")
	  (vlax-put x 'Layer "TG")
	)
	(progn
	  (setq	m (vla-addline
		    model
		    (vlax-3d-point (list (- xMLH< 0.5) (+ yMLH< ny)))
		    (vlax-3d-point (list xMLH< (+ yMLH< ny)))
		  )
	  )
	  (vlax-put m 'Color 1)
	  (vlax-put m 'Layer "TG")
	)
      )
    )
					;X
    (repeat (/ (- xMLH> xMLH<) 2)
      (setq
	m (vla-addline
	    model
	    (vlax-3d-point (list (+ xMLH< (setq nx (+ nx 2))) yMLH<))
	    (vlax-3d-point (list (+ xMLH< nx) yMLH>))
	  )
      )
      (vlax-put m 'Color 1)
      (vlax-put m 'Layer "TG")
      (setq mt (abs (read (rtos (+ xMLH< nx) 2 0))))
      (if (cond	((= mt 0) t)
		((= mt 10) t)
		((= mt 20) t)
		((= mt 30) t)
		((= mt 40) t)
		((= mt 50) t)
		((= mt 60) t)
		((= mt 70) t)
		((= mt 80) t)
		((= mt 90) t)
	  )
	(progn
	  (setq	m (vla-addline
		    model
		    (vlax-3d-point (list (+ xMLH< nx) (1- yMLH<)))
		    (vlax-3d-point (list (+ xMLH< nx) yMLH<))
		  )
		x (vla-addtext
		    model
		    (rtos (+ xMLH< nx) 2 0)
		    (vlax-3d-point (list (+ xMLH< nx) (- yMLH< 1.25)))
		    0.1688
		  )
	  )
	  (vlax-put m 'Color 1)
	  (vlax-put x 'Color 3)
	  (vlax-put m 'Layer "TG")
	  (vlax-put x 'Layer "TG")
	  (vla-put-alignment x acAlignmentTopCenter)
	  (vla-put-textalignmentpoint
	    x
	    (vlax-3d-point (list (+ xMLH< nx) (- yMLH< 1.25)))
	  )
	)
	(progn
	  (setq	m (vla-addline
		    model
		    (vlax-3d-point (list (+ xMLH< nx) (- yMLH< 0.5)))
		    (vlax-3d-point (list (+ xMLH< nx) yMLH<))
		  )
	  )
	  (vlax-put m 'Color 1)
	  (vlax-put m 'Layer "TG")
	)
      )
    )
					;Texto Estaca
    (setq x (vla-addtext
	      model
	      TXTTerreno
	      (vlax-3d-point (list (car INTTerreno) (+ yMLH> 0.5)))
	      0.3
	    )
    )
    (vlax-put x 'Color 3)
    (vlax-put x 'Layer "TG")
    (setq x (vla-addtext
	      model
	      TXTProjeto
	      (vlax-3d-point (list (car INTProjeto) (+ yMLH> 1.0)))
	      0.3
	    )
    )
    (vlax-put x 'Color 3)
    (vlax-put x 'Layer "TG")
    (setq x (vla-addtext
	      model
	      TXTEstaca
	      (vlax-3d-point (list (car INTEstaca) (+ yMLH> 1.5)))
	      0.3
	    )
    )
    (vlax-put x 'Color 3)
    (vlax-put x 'Layer "TG")
;;;
    (zoom)
    (command "move"
	     "all"
	     ""
	     (vlax-invoke
	       plTerreno
	       'IntersectWith
	       LineEixoYellow
	       acextendnone
	     )
	     '(0 0 0)
    )
    (zoom)
;;;
    (entdel (vlax-vla-object->ename LineEixoYellow))
    (command "bsave" "bclose")
    (if	(vl-string-search "+" TXTEstaca)
      (entdel
	(cadr
	  (car
	    (ssnamex
	      (ssget "x" (list '(0 . "insert") (cons 2 (car blks))))
	    )
	  )
	)
      )
      (command "rename" "block" (car blks) TXTEstaca)
    )
    (setq blks (cdr blks))
  )
  (zoom)
  (setvar "osmode" os)
  (command "-PURGE" "a" "" "n")
  (command "qsave")
  (princ)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:sec2 ()
  (vl-load-com)
  (setvar "cmdecho" 0)
  (setvar "ctab" "secoes")
  (setq
    pspace   (vla-get-paperspace
	       (vla-get-activedocument (vlax-get-acad-object))
	     )
    model    (vla-get-modelspace
	       (vla-get-activedocument (vlax-get-acad-object))
	     )
    basefile (getfiled
	       "Arquivo de seções já organizadas..."
	       (strcat (getvar "dwgprefix") "Seções Organizadas.dwg")
	       "DWG"
	       2
	     )
    SecIni   (getint (strcat "\n"
			     (vl-filename-base basefile)
			     "\nDigite a estaca da 1ª Seção: "
		     )
	     )
    SecFin   (getint "\tDigite a estaca da Ultima Seção: ")
  )
  (entmake '((0 . "LAYER")
	     (100 . "AcDbSymbolTableRecord")
	     (100 . "AcDbLayerTableRecord")
	     (2 . "FOLHA")
	     (6 . "Continuous")
	     (62 . 250)
	     (70 . 0)
	    )
  )
  (vla-insertblock
    pspace
    (vlax-3d-point '(0 0 0))
    basefile
    1
    1
    1
    0
  )
  (vla-zoomextents (vlax-get-acad-object))
;;;
  (defun folha (basepoint / xa ya xb yb tox toy tdx tdy f to td)
    (setq
      xa  00.0000
      ya  00.0000
      xb  56.6000
      yb  31.3840
      tox 28.3000
      toy 23.5380
      tdx 28.3000
      tdy 7.8460
      f
	  (vla-addpolyline
	    model
	    (vlax-make-variant
	      (vlax-safearray-fill
		(vlax-make-safearray
		  vlax-vbdouble
		  (cons	0
			(1- (length
			      (list
				(+ xa (car basepoint))
				ya
				0
				(+ xb (car basepoint))
				ya
				0
				(+ xb (car basepoint))
				yb
				0
				(+ xa (car basepoint))
				yb
				0
				(+ xa (car basepoint))
				ya
				0
			      )
			    )
			)
		  )
		)
		(list
		  (+ xa (car basepoint))
		  ya
		  0
		  (+ xb (car basepoint))
		  ya
		  0
		  (+ xb (car basepoint))
		  yb
		  0
		  (+ xa (car basepoint))
		  yb
		  0
		  (+ xa (car basepoint))
		  ya
		  0
		)
	      )
	    )
	  )
      to  (vla-addtext
	    model
	    "@ORIG@"
	    (vlax-3d-point (list (+ tox (car basepoint)) toy))
	    8
	  )
      td  (vla-addtext
	    model
	    "@DEST@"
	    (vlax-3d-point (list (+ tdx (car basepoint)) tdy))
	    8
	  )
    )
    (vla-put-alignment to acAlignmentMiddleCenter)
    (vla-put-textalignmentpoint
      to
      (vlax-3d-point (list (+ tox (car basepoint)) toy))
    )
    (vla-put-alignment td acAlignmentMiddleCenter)
    (vla-put-textalignmentpoint
      td
      (vlax-3d-point (list (+ tdx (car basepoint)) tdy))
    )
    (mapcar '(lambda (x) (vlax-put x 'Layer "FOLHA"))
	    (list f to td)
    )
    (list f
	  to
	  td
	  (list (+ tox (car basepoint)) toy)
	  (list (+ tdx (car basepoint)) tdy)
	  (list (+ xa (car basepoint)) ya)
	  (list (+ xb (car basepoint)) yb)
    )
  )
;;;(folha '(0 0))
  (setq
    n  -1
    bx -56.6000
  )
  (repeat (if (>= (- SecFin SecIni) 253)
	    253
	    (- SecFin SecIni)
	  )
    (setvar "ctab" "model")
    (setq
      ins  (folha (list (setq bx (+ bx 56.6)) 0))
      Sec1 (rtos (+ SecIni (setq n (1+ n))) 2 0)
      Sec2 (rtos (+ SecIni (1+ n)) 2 0)
      o	   (nth 3 ins)
      d	   (nth 4 ins)
    )
    (vlax-put (nth 1 ins) 'TextString Sec1)
    (vlax-put (nth 2 ins) 'TextString Sec2)
    (if	(and (tblsearch "block" Sec1) (tblsearch "block" Sec2))
      (progn
	(vla-insertblock model (vlax-3d-point o) Sec1 1 1 1 0)
	(vla-insertblock model (vlax-3d-point d) Sec2 1 1 1 0)
      )
    )
;;;Layout
    (command "layout" "copy" "base" Sec1)
    (setvar "ctab" Sec1)
    (setq
      cad     (vla-get-ActiveDocument (vlax-get-acad-object))
      windowV
	      (vlax-ename->vla-object
		(cadr
		  (car (ssnamex
			 (ssget "x" (list '(0 . "viewport") (cons 410 Sec1)))
		       )
		  )
		)
	      )
    )
    (vla-Display windowV :vlax-true)
    (vla-put-mspace cad :vlax-true)
    (vla-put-activepviewport cad windowV)
    (vla-zoomwindow
      (vlax-get-acad-object)
      (vlax-3d-point (nth 5 ins))
      (vlax-3d-point (nth 6 ins))
    )
    (vla-put-mspace cad :vlax-false)
    (txtsec Sec1)
    (gc)
;;;
  )
  (setvar "ctab" "model")
  (vla-zoomextents (vlax-get-acad-object))
  (mapcar '(lambda (x) (entdel (cadr x)))
	  (cdr
	    (reverse (ssnamex (ssget "w"
				     '(-214.6486 -61.9834)
				     '(-127.2740 -46.8996)
				     '((0 . "text") (410 . "model"))
			      )
		     )
	    )
	  )
  )
  (vla-zoomextents (vlax-get-acad-object))
  (command "-layer" "plot" "n" "FOLHA" "")
  (command "layout" "d" "secoes")
  (command "layout" "d" "base")
  (command "-PURGE" "a" "" "n")
  (command "saveas"
	   ""
	   (strcat (getvar "dwgprefix")
		   "Seções Formatadas\\Folha - Seções - "
		   (rtos SecIni 2 0)
		   "_"
		   Sec1
	   )
  )
  (if (> (- SecFin SecIni) 254)
    (alert
      (strcat "Superada a quantidade maxima de formatos, faltam "
	      (rtos (- (- SecFin SecIni) 256) 2 0)
	      " formatos a concluir!!!"
      )
    )
  )
  (setvar "cmdecho" 1)
  (princ)
)

(defun txtsec
	      (s       /       n       l       arq     E1R     E2R
	       *VBASE* *VSUBBASE*      EST     VBS     VSB     *EIO*
	       *EFO*   *E*     *12C*   *3C*    *EID*   *EFD*   *V95*
	       *V100*  *U95*   *U100*  *DMT*   #EIO#   #EFO#   #E#
	       #12C#   #3C#    #EID#   #EFD#   #V95#   #V100#  #U95#
	       #U100#  #DMT#
	      )
  (defun toList	(est txt / to)
    (setq
      to (ssget	"x"
		(list '(0 . "TEXT")
		      (cons 410 est)
		      (cons 62 250)
		      (cons 1 txt)
		)
	 )
      to (if to
	   (mapcar
	     '(lambda (x)
		(progn
		  (list	(cadr (vlax-get	(vlax-ename->vla-object (cadr x))
					'InsertionPoint
			      )
			)
			(vlax-ename->vla-object (cadr x))
		  )
		)
	      )
	     (ssnamex to)
	   )
	 )
      to (if to
	   (vl-sort to '(lambda (t1 t2) (> (car t1) (car t2))))
	 )
    )
    to
  )
  (setq
    arq	   (open (strcat (getvar "dwgprefix") "secoes.txt") "r")
    *EIO*  (tolist s "@EIO")
    *EFO*  (tolist s "@EFO")
    *E*	   (tolist s "@E")
    *12C*  (tolist s "@12C")
    *3C*   (tolist s "@3C")
    *EID*  (tolist s "@EID")
    *EFD*  (tolist s "@EFD")
    *V95*  (tolist s "@V95")
    *V100* (tolist s "@V100")
    *U95*  (tolist s "@U95")
    *U100* (tolist s "@U100")
    *DMT*  (tolist s "@DMT")
    n	   -1
  )
  (if (and *EIO* arq)
;;;Inicio do IF
    (progn
      (while (setq l (read-line arq))
	(setq
	  E1R	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  E2R	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #EIO#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #EFO#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #E#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #12C#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #3C#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #EID#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #EFD#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #V95#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #V100# (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #U95#	 (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #U100# (substr l 1 (vl-string-search "\t" l))
	  l	 (substr l (+ (vl-string-search "\t" l) 2))
	  #DMT#	 (substr l 1 (vl-string-search "\t" l))
	)
	(if (= E1R s)
	  (progn
	    (princ s)
	    (setq n (1+ n))
	    (mapcar '(lambda (l1 l2)
		       (progn (vlax-put l1 'TextString l2)
			      (vlax-put l1 'Color 1)
		       )
		     )
		    (list
		      (cadr (nth n *EIO*))
		      (cadr (nth n *EFO*))
		      (cadr (nth n *E*))
		      (cadr (nth n *12C*))
		      (cadr (nth n *3C*))
		      (cadr (nth n *EID*))
		      (cadr (nth n *EFD*))
		      (cadr (nth n *V95*))
		      (cadr (nth n *V100*))
		      (cadr (nth n *U95*))
		      (cadr (nth n *U100*))
		      (cadr (nth n *DMT*))
		    )
		    (list #EIO#	  #EFO#	  #E#	  #12C#	  #3C#
			  #EID#	  #EFD#	  #V95#	  #V100#  #U95#
			  #U100#  #DMT#
			 )
	    )
	  )
	)
      )
    )
  )
;;;Fim do IF
  (if arq
    (close arq)
  )
  (if (ssget "x"
	     (list '(0 . "TEXT")
		   (cons 410 s)
		   (cons 62 250)
		   '(1 . "@EIO")
	     )
      )
    (mapcar '(lambda (x) (entdel (cadr x)))
	    (apply 'append
		   (list
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@EIO")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@EFO")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@E")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@12C")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@3C")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@EID")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@EFD")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@V95")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@V100")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@U95")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@U100")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@DMT")
				     )
			      )
		     )
		   )
	    )
    )
  )
;;;VOLUME BASE / SUB-BASE
  (setq
    arq	       (open (strcat (getvar "dwgprefix") "volumes seção.txt") "r")
    *VBASE*    (vlax-ename->vla-object
		 (cadr (car (ssnamex (ssget "x"
					    (list '(0 . "TEXT")
						  (cons 410 s)
						  (cons 62 250)
						  '(1 . "@VBASE")
					    )
				     )
			    )
		       )
		 )
	       )
    *VSUBBASE* (vlax-ename->vla-object
		 (cadr (car (ssnamex (ssget "x"
					    (list '(0 . "TEXT")
						  (cons 410 s)
						  (cons 62 250)
						  '(1 . "@VSUBBASE")
					    )
				     )
			    )
		       )
		 )
	       )
  )
  (while (setq l (read-line arq))
    (setq
      EST (substr l 1 (vl-string-search "\t" l))
      l	  (substr l (+ (vl-string-search "\t" l) 2))
      VBS (substr l 1 (vl-string-search "\t" l))
      l	  (substr l (+ (vl-string-search "\t" l) 2))
      VSB (substr l 1 (vl-string-search "\t" l))
    )
    (if	(= EST s)
      (progn
	(vlax-put *VBASE* 'TextString VBS)
	(vlax-put *VSUBBASE* 'TextString VSB)
	(vlax-put *VBASE* 'Color 1)
	(vlax-put *VSUBBASE* 'Color 1)
      )
    )
  )
  (close arq)
  (if (ssget "x"
	     (list '(0 . "TEXT")
		   (cons 410 s)
		   (cons 62 250)
		   '(1 . "@VBASE")
	     )
      )
    (mapcar '(lambda (x) (entdel (cadr x)))
	    (apply 'append
		   (list
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@VBASE")
				     )
			      )
		     )
		     (ssnamex (ssget "x"
				     (list '(0 . "TEXT")
					   (cons 410 s)
					   (cons 62 250)
					   '(1 . "@VSUBBASE")
				     )
			      )
		     )
		   )
	    )
    )
  )
;;;VOLUME BASE / SUB-BASE
  (vlax-put (vlax-ename->vla-object
	      (cadr (car (ssnamex (ssget "x"
					 (list '(0 . "TEXT")
					       (cons 410 s)
					       (cons 62 250)
					       '(1 . "@EST")
					 )
				  )
			 )
		    )
	      )
	    )
	    'Color
	    1
  )
  (vlax-put (vlax-ename->vla-object
	      (cadr (car (ssnamex (ssget "x"
					 (list '(0 . "TEXT")
					       (cons 410 s)
					       (cons 62 1)
					       '(1 . "@EST")
					 )
				  )
			 )
		    )
	      )
	    )
	    'TextString
	    s
  )
)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:sec3();Rebaixo
  (vl-load-com)
  (setq
    arq(open(strcat(getvar"dwgprefix")"rebaixo.txt")"r")
    model(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    rList(progn
	   (setq
	     rList nil
	     )
	   (while(setq l(read-line arq))
	     (setq
	       EST(substr l 1 (vl-string-search"\t"l))l(substr l(+(vl-string-search"\t"l)2))
	       RBX(substr l 1 (vl-string-search"\t"l))
	       rList(vl-list*(list EST (read RBX))rList)
	       )
	     )
	   (reverse rList)
	   )
    SectionCounter -1
    )
  (close arq)
  (repeat(length rList)
    (setq
      sEnty(nth(setq SectionCounter(1+ SectionCounter))rList)
      sEst(car sEnty)
      sRBX(cadr sEnty)
      );sEst
    (if(tblsearch"block"sEst)
      (progn
	(command"bedit"sEst)
	(if(setq ss(ssget"x"'((0 . "lwpolyline,hatch")(62 . 10))))(mapcar'(lambda(x)(entdel(cadr x)))(ssnamex ss)))
	(setq
	  sPlat(ssget"x"'((0 . "lwpolyline")(62 . 4)))
	  sPlat(mapcar'(lambda(x)(if(=(/(length(vlax-get(vlax-ename->vla-object(cadr x))'Coordinates))2)5)
				   (vlax-ename->vla-object(cadr x))
				   )
			 )
		      (ssnamex sPlat)
		      )
	  sPlat
	   (progn
	     (repeat 10
	       (if(=(car sPlat)nil)
		 (setq sPlat(cdr sPlat))
		 )
	       )
	     (car sPlat)
	     )
	  sPlat
	   (if splat splat (vlax-ename->vla-object(cadr(car(ssnamex(ssget"x"'((0 . "lwpolyline")(62 . 54))))))))
	  sPlatCoordListA
	   (progn
	     (setq
	       sPlatCoordListA nil
	       n -1
	       )
	     (repeat(/(length(vlax-get sPlat'Coordinates))2)
	       (setq
		 sPlatCoordListA(vl-list*
				  (list
				    (nth(setq n(1+ n))(vlax-get sPlat'Coordinates))
				    (nth(setq n(1+ n))(vlax-get sPlat'Coordinates))
				    0
				    )
				  sPlatCoordListA
				  )
		 )
	       )
	     (list(nth 0 sPlatCoordListA)(nth 2 sPlatCoordListA)(nth 4 sPlatCoordListA))
	     )
	  sPlatCoordListB
	   (list
	     (list(car(nth 0 sPlatCoordListA))(-(cadr(nth 0 sPlatCoordListA))sRBX)0)
	     (list(car(nth 1 sPlatCoordListA))(-(cadr(nth 1 sPlatCoordListA))sRBX)0)
	     (list(car(nth 2 sPlatCoordListA))(-(cadr(nth 2 sPlatCoordListA))sRBX)0)
	     )
	  sPlatCoordListA(reverse sPlatCoordListA)
	  sPlatCoordRBXLst(apply'append(list sPlatCoordListA sPlatCoordListB (list(car sPlatCoordListA))))
	  sPlatCoordRBXLst(apply'append sPlatCoordRbxLst)
	  sPlatRBX
	   (vla-addpolyline
	     model
	     (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length sPlatCoordRBXLst))))sPlatCoordRBXLst)))
	  plTerreno
	   (vlax-ename->vla-object(cadr(car(ssnamex(ssget"x"'((0 . "lwpolyline")(62 . 3)))))))
	  )
	;;;
	(setq
	  cLstPlatSup
	   (progn
	     (setq
	       cLstPlatSup nil
	       cLstPlatSub nil
	       n -1
	       cB(abs(-(car(nth 0 sPlatCoordListA))(car(nth 2 sPlatCoordListA))))
	       cR(/ cB 100)
	       cX(-(car(nth 0 sPlatCoordListA))cR)
	       )
	     (repeat 101
	       (setq
		 lIx(vla-addline model
		      (vlax-3d-point (list(setq cX(+ cX cR)) 100))
		      (vlax-3d-point (list cX -100))
		      )
		 iXA(vlax-invoke lIx 'IntersectWith sPlatRBX acextendnone)
		 iXB(list(nth 3 iXA)(nth 4 iXA));(nth 5 iXA))
		 iXA(list(nth 0 iXA)(nth 1 iXA));(nth 2 iXA))
		 iXC(vlax-invoke lIx 'IntersectWith plTerreno acextendnone)
		 iXC(list(nth 0 iXC)(nth 1 iXC))
		 )
	       (entdel(vlax-vla-object->ename lIx))
	       (setq
		 cLstPlatSup(vl-list*
			      (cond
				((and(<(cadr iXC)(cadr iXB))(<(cadr iXC)(cadr iXA)))iXB);;;Se menor que a base e topo de corte...
				((and(>(cadr iXC)(cadr iXB))(<(cadr iXC)(cadr iXA)))iXC);;;Se maior que a base e menor que o topo...
				((and(>(cadr iXC)(cadr iXB))(>(cadr iXC)(cadr iXA)))iXA);;;Se maior que a base e o topo...
				)
			      cLstPlatSup
			      )
		 cLstPlatSub(vl-list*
			      (cond
				((and(<(cadr iXC)(cadr iXB))(<(cadr iXC)(cadr iXA)))iXB);;;Se menor que a base e topo de corte...
				((and(>(cadr iXC)(cadr iXB))(<(cadr iXC)(cadr iXA)))iXB);;;Se maior que a base e menor que o topo...
				((and(>(cadr iXC)(cadr iXB))(>(cadr iXC)(cadr iXA)))iXB);;;Se maior que a base e o topo...
				)
			      cLstPlatSub
			      )
		 )
	       )
	     (entdel(vlax-vla-object->ename sPlatRBX))
	     ;;;
	     (setq
	       cLstPlat
		(apply'append(apply'append(list(reverse cLstPlatSup)cLstPlatSub(list(car(reverse cLstPlatSup))))))
	       sPlatRBX
		(progn
		  (vla-addLightweightPolyline
		    model
		    (setq hList(vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble (cons 0 (1-(length cLstPlat))))cLstPlat)))
		    )
		  )
	       aTXT
		(vlax-get sPlatRBX 'Area)
	       )
	     (vla-put-closed sPlatRBX t)
	     ;;;Hatch
	     (setq hatch(vla-addhatch model achatchpatterntypepredefined "SOLID" :vlax-true))
	     (vlax-invoke hatch 'AppendOuterLoop (list sPlatRBX))
	     (vla-evaluate hatch)
	     ;;;
	     (vlax-put sPlatRBX 'Color 10)
	     (vlax-put hatch 'Color 10)
	     ;;;(vlax-dump-object sPlatRBX t)
	     )
	  )
	(command"bsave""bclose")
	);;;Final de Progn
      );;;Final de IF
    ;(if(member sEst(layoutlist))(setvar"ctab"(rtos(1-(read sEst))2 0)))
    (if(and aTXTLast sPlatRBX(=(1-(read sEst))(read LastEst)))
      (setq vol³(*(/(+ aTXT aTXTLast)2)10)LastEst sEst aTXTLast aTXT)
      (setq aTXTLast aTXT LastEst sEst)
      )
    (if vol³
      (progn
	(command"layout""set"sEst)
	(setq txtRebaixo(ssget"x"(list'(0 . "text")'(1 . "@REBAIXO")'(62 . 250)(cons 410(rtos(1-(read sEst))2 0))))
	      txtRebaixo(if txtRebaixo (vlax-ename->vla-object(cadr(car(ssnamex txtRebaixo)))))
	      )
	(if txtRebaixo
	  (progn
	    (vlax-put txtRebaixo 'TextString (vl-string-translate"."","(rtos vol³ 2 3)))
	    (vlax-put txtRebaixo 'Color 1)
	    )
	  )
	)
      )
    ;(if(=(1-(read sEst))(read LastEst))(princ)(setq aTXTLast nil))
    (setq sPlatRBX nil vol³ nil)
    );;;Final de Repeat Master
  (setq
    tabs(layoutlist)
    )
  (repeat(length tabs)
    (setvar"ctab"(car tabs))
    (setq tabs(cdr tabs)
	  txtRebaixo(ssget"x"'((0 . "text")(1 . "@REBAIXO")(62 . 250)))
	  txtRebaixo(if txtRebaixo (cadr(car(ssnamex txtRebaixo))))
	  )
    (if txtRebaixo(entdel txtRebaixo))
    )
  (princ)
  )