(vl-load-com)
(defun c:DwgToKml(/ outFile file ascFile kmlFile exec)
  (setvar'cmdecho 0)
;;;  (cond
;;;    ((/=(findfile "./dwgtokml.exe")nil)(setq exec (findfile "./dwgtokml.exe")))
;;;    ((/=(findfile "c:/Lisp/DWGTOKML/dwgtokml.exe")nil)(setq exec (findfile "c:/Lisp/DWGTOKML/dwgtokml.exe")))
;;;    )
  (if(/=(findfile "c:/Lisp/DWGTOKML/dwgtokml.exe")nil)
    (setq exec (findfile "c:/Lisp/DWGTOKML/dwgtokml.exe"))
    (setq exec (findfile "./dwgtokml.exe"))
    )
  (if(= exec nil)(quit))
  (princ"\"APENAS PARA DATUM WGS84 OU SIRGAS-2000.\"\nAguarde o processamento dos dados!!!")
  (setq
    ascFile(strcat(getvar"dwgprefix")"dwgtokml.asc")
    kmlFile(strcat(getvar"dwgprefix")"dwgtokml.kml")
    )
  (if(/=(findfile kmlFile)nil)
    (vl-file-delete kmlFile)
    )
  (if(/=(findfile ascFile)nil)
    (vl-file-delete ascFile)
    )
  (setq
    outFile(open(setq file ascFile)"w")
    mag 100 ; Magnitude de precisão em conversão de arcos e circulos ;;;***********Alterar para 100 apos retirar animação
    )
  ;Exportação de entidades
  (DTKpoint)
  (DTKtext)
  (DTKarc)
  (DTKcircle)
  (DTKline)
  (DTKpoly)
  (DTKhatch)
  ;
  (close outFile)
  
  ; Pegando aplicação externa para execução de programa....................
  (startapp exec (strcat " \"" (vl-string-translate "\\" "/" (getvar"dwgprefix")) "\"" ) )
  (while(=(findfile kmlFile)nil)
    )
  ; Aguardando o termino do programa externo...
  (if(/=(findfile ascFile)nil)
    (vl-file-delete ascFile)
    )
  (princ"Concluido...\nPara mais informações acesse: http://ed9bh.blogspot.com.br/")
  (vl-catch-all-apply'vlax-invoke(list(setq app(vla-getInterfaceObject(vlax-get-acad-object)"Shell.Application"))'Open kmlFile))
  (vlax-release-object app)
  (setvar'cmdecho 1)
  (princ)
  )

; (entget(car(entsel)))
; (vlax-dump-object(vlax-ename->vla-object(car(entsel)))t)

(defun DTKpoly(/ entsE entsV len fdist nnn coords color layer)
  (setq
    entsE(ssget"x"'((0 . "lwpolyline")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq coords nil)
    (if(>(vlax-get(car entsV)'Length)100)(setq mag(fix(/(vlax-get(car entsV)'Length)2))));;;***********
    (if(= (DTKpolyArcException (car entsV)) 0)
      (setq coords(vlax-get(car entsV)'Coordinates))
      (progn
	(setq len(vlax-get(car entsV)'Length)
	      fdist(/ len mag)
	      nnn 0
	      )
	(repeat mag
	  (setq coords(vl-list*
			(list
			  (car (vlax-curve-getpointatdist(car entsV)nnn))
			  (cadr (vlax-curve-getpointatdist(car entsV)nnn))
			  )
			coords)
		nnn(+ nnn fdist)
		)
	  )
	(setq coords(apply'append(reverse coords)))
	)
      )
    (setq
      color(vla-get-color(car entsV))
      layer(vla-get-layer(car entsV))
      entsV(cdr entsV)
      )
    (write-line "Linha" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (while coords
      (write-line (strcat (rtos(car coords)2 15) "\t" (rtos(cadr coords)2 15)) outFile)
      (setq coords(cdr coords)
	    coords(cdr coords)
	    )
      )
    (write-line "Final" outFile)
    (setq mag 100);;;***********Alterar para 100 apos retirar animação
    )
  );;;
(defun DTKpolyArcException(polyTest / arcDetect ent);Detecta se a polylinha possui arco...
  (setq arcDetect 0
	ent(entget(vlax-vla-object->ename polyTest))
	)
  (repeat(length ent)
    (if(=(car(car ent)) 42)
      (if(/=(cdr(car ent))0.0)
	(setq arcDetect 1)
	)
      )
    (setq ent(cdr ent))
    )
  arcDetect
  )
      
  
(defun DTKline(/ entsE entsV len fdist nnn coords color layer p1 p2)
  (setq
    entsE(ssget"x"'((0 . "line")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq
      p1(vlax-get(car entsV)'StartPoint)
      p2(vlax-get(car entsV)'EndPoint)
      color(vla-get-color(car entsV))
      layer(vla-get-layer(car entsV))
      entsV(cdr entsV)
      )
    (write-line "Linha" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (write-line (strcat (rtos(car p1)2 15) "\t" (rtos(cadr p1)2 15)) outFile)
    (write-line (strcat (rtos(car p2)2 15) "\t" (rtos(cadr p2)2 15)) outFile)
    (write-line "Final" outFile)
    )
  )

(defun DTKpoint(/ entsE entsV len fdist nnn coords color layer point)
  (setq
    entsE(ssget"x"'((0 . "point")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq
      point(vlax-get(car entsV)'Coordinates)
      color(vla-get-color(car entsV))
      layer(vla-get-layer(car entsV))
      entsV(cdr entsV)
      )
    (write-line "Ponto" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (write-line (strcat (rtos(car point)2 15) "\t" (rtos(cadr point)2 15)) outFile)
    (write-line "Final" outFile)
    )
  )

(defun DTKarc(/ entsE entsV len fdist nnn coords color layer)
  (setq
    entsE(ssget"x"'((0 . "arc")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq
      len(vlax-get(car entsV)'ArcLength)
      fdist(/ len mag)
      nnn 0
      color(vla-get-color(car entsV))
      layer(vla-get-layer(car entsV))
      )
    (write-line "Linha" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (repeat mag
      (write-line (strcat
		    (rtos(car (vlax-curve-getpointatdist(car entsV)nnn) )2 15)
		    "\t"
		    (rtos(cadr (vlax-curve-getpointatdist(car entsV)nnn) )2 15)
		    )
	outFile)
      (setq nnn(+ nnn fdist))
      )
    (setq entsV(cdr entsV))
    (write-line "Final" outFile)
    )
  )

(defun DTKcircle(/ entsE entsV len fdist nnn coords color layer)
  (setq
    entsE(ssget"x"'((0 . "circle")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq
      len(vlax-get(car entsV)'Circumference)
      fdist(/ len mag)
      nnn 0
      color(vla-get-color(car entsV))
      layer(vla-get-layer(car entsV))
      )
    (write-line "Linha" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (repeat mag
      (write-line (strcat
		    (rtos(car (vlax-curve-getpointatdist(car entsV)nnn) )2 15)
		    "\t"
		    (rtos(cadr (vlax-curve-getpointatdist(car entsV)nnn) )2 15)
		    )
	outFile)
      (setq nnn(+ nnn fdist))
      )
    (setq entsV(cdr entsV))
    (write-line "Final" outFile)
    )
  )

(defun DTKtext(/ entsE entsV len fdist nnn coords color layer point)
  (setq
    entsE(ssget"x"'((0 . "text")(410 . "Model")))
    )
  (if entsE
    (setq entsV(mapcar'(lambda(x)(vlax-ename->vla-object(cadr x)))(ssnamex entsE)))
    )
  (repeat(length entsV)
    (setq
      point(vlax-get(car entsV)'InsertionPoint)
      color(vla-get-color(car entsV))
      layer(vlax-get(car entsV)'TextString)
      entsV(cdr entsV)
      )
    (write-line "Ponto" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (write-line (strcat (rtos(car point)2 15) "\t" (rtos(cadr point)2 15)) outFile)
    (write-line "Final" outFile)
    )
  )






; (vlax-dump-object(vlax-ename->vla-object(car(entsel)))t)
(defun DTKhatch(/ entsE entsV len fdist nnn coords color layer)
  (setq
    entsE(ssget"x"'((0 . "hatch")(410 . "Model")))
    )
  (if entsE
    (setq entsE(mapcar'(lambda(x)(cadr x))(ssnamex entsE)))
    )
  (repeat(length entsE)
    (setq
      coords nil
      coords(mapcar'(lambda(x)(if(=(car x)10)(list(cadr x)(caddr x))))(entget(car entsE)))
      coords(mapcar'(lambda(x)(if(= x nil)(vl-remove x coords))) coords)
      coords(cdr(car coords))
      coords(cdr(reverse coords))
      pini(list(car coords)(cadr coords))
      )
    ;(mapcar'(lambda(x)(entmake(list'(0 . "point")(cons 10 x))))coords)
    (setq
      coords(apply'append coords)
      color(vla-get-color(vlax-ename->vla-object(car entsE)))
      layer(vla-get-layer(vlax-ename->vla-object(car entsE)))
      entsE(cdr entsE)
      )
    (write-line "Hatch" outFile)
    (write-line layer outFile)
    (write-line (rtos color 2 0) outFile)
    (while coords
      (write-line (strcat (rtos(car coords)2 15) "\t" (rtos(cadr coords)2 15)) outFile)
      (setq coords(cdr coords)
	    coords(cdr coords)
	    )
      )
    (write-line (strcat (rtos(car(car pini))2 15) "\t" (rtos(cadr(car pini))2 15)) outFile)
    (write-line "Final" outFile)
    )
  )