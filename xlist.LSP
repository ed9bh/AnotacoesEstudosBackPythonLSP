;Lista as Coordenadas de uma Polylinha em um Bloco de Notas. Opção para diferenciar eixo de perfil.

(defun c:xlist()
  (vl-load-com)
  (setvar"cmdecho"0)
  (setq plBjt(entsel"\nSelecione a polylinha: ")
	opc(progn(initget 1 "pLanta pErfil")(getkword"\npLanta ou pErfil? "))
	salve(progn(initget 1 "Sim Nao Não")(getkword"\nSalvar lista?[<Sim/Nao>]: "))
	arq+(if(= salve "Sim")
	      (open
		(setq arq-(vl-filename-mktemp nil nil".asc"))
		"w"
		)
	      )
	plEBjt(vlax-ename->vla-object(car plBjt))
	plCoo(progn
		(setq plCoo nil
		      n -1
		      )
		(repeat(/(length(vlax-get plEBjt 'Coordinates))(if(=(vlax-get plEBjt 'ObjectName)"AcDb3dPolyline")3 2))
		  (setq plCoo
			 (vl-list*
			   (trans
			     (list
			       (nth(setq n(1+ n))(vlax-get plEBjt 'Coordinates))
			       (nth(setq n(1+ n))(vlax-get plEBjt 'Coordinates))
			       (if(=(vlax-get plEBjt 'ObjectName)"AcDb3dPolyline")(nth(setq n(1+ n))(vlax-get plEBjt 'Coordinates))(vlax-get plEBjt 'Elevation))
			       )
			     0 1)
			   plCoo)
			)
		  )
		(reverse plCoo)
		)
	n -1
	)
  (textscr)
  (if(= opc "pLanta")
    (repeat(length plCoo)
      (setq txt
	     (strcat
	       "X(E) = "(rtos(car(nth(setq n(1+ n))plCoo))2 4)" Y(N) = "(rtos(cadr(nth n plCoo))2 4)" Z(E) = "(rtos(caddr(nth n plCoo))2 4)
	       (if(= n 0)
		 " - "
		 (strcat" Ang = "(angtos(angle
					  (list(car(nth(1- n)plCoo))(cadr(nth(1- n)plCoo)))
					  (list(car(nth n plCoo))(cadr(nth n plCoo)))
					  )
					1 4))
		 )
	       )
	    )
      (if arq+
	(write-line txt arq+)
	)
      (princ"\n")(princ txt)
      )
    (repeat(length plCoo)
      (setq txt
	     (strcat
	       "X = "(rtos(car(nth(setq n(1+ n))plCoo))2 3)" Elev = "(rtos(cadr(nth n plCoo))2 3)
	       (if(= n 0)
		 " - "
		 (progn
		   (strcat" Dist = "(rtos(distance
					   (list(car(nth(1- n)plCoo))(cadr(nth(1- n)plCoo)))
					   (list(car(nth n plCoo))(cadr(nth n plCoo)))
					   )
					 2 3)
			  " Inc = "(rtos(*(/(-(cadr (nth n plCoo))(cadr(nth(1- n)plCoo)))(distance(nth(1- n)plCoo)(nth n plCoo)))100)2 3)"%"
			  )
		   )
		 )
	       )
	    )
      (if arq+
	(write-line txt arq+)
	)
      (princ"\n")(princ txt)
      )
    )
  (if arq+
    (progn(close arq+)(command"notepad"arq-))
    )
  (setvar"cmdecho"1)
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