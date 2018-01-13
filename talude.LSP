;;;----------------------------------------------------------------------------------------------
;;;----------------------------------------------------------------------------------------------
;;;----------------------------------------------------------------------------------------------

(defun c:Talude();;;Talude
  (command"undo""be")
  (setq pline(entsel"\nSelecione POLILINHA de Crista ou Pé: ")
	limite(entsel"\nSelecione o limite 1: ")
	;limiteB(entsel"\nSelecione o limite 2(não obrigatorio): ")
	)
  (princ"\nSelecione o limite 2(não obrigatorio): ")
  (setq limiteB(ssget)
	tdist(getreal "\nDistancia entre traços de talude <2>: ")
	osmode(getvar"osmode")
	)
  
  (initget 1 "Pe Crista")
  (setq tipo(getkword "\nTipo [Pe / Crista]: "))
  
  (setvar"osmode"0)
  (if tdist(princ)(setq tdist 2))
  (setq coords(coordlistdist pline tdist)
	dist(getdist (car coords) "\nMais ou menos distancia mais longa: ")
	ang(angle (car coords) (cadr coords));1.5708
	coordmid(list (/(+ (car(car coords)) (car(cadr coords)))2) (/(+ (cadr(car coords)) (cadr(cadr coords)))2))
	ca(polar coordmid (+ ang 1.5708) (* dist 2))
	cb(polar coordmid (- ang 1.5708) (* dist 2))
	ad 1.5708
	ae -1.5708
	)
  (grdraw coordmid ca 6)
  (grdraw coordmid cb 5)
  (initget 1 "Azul Magenta")
  (setq opc(getkword "\nDireção [Azul / Magenta]: "))
  (command"zoom""o"pline pline"")

  ;;;

  (defun 2a()
    (setq <n> 0
	  meio 0
	  )
    (while(setq co(if(= (nth (1+ <n>) coords) nil)(nth (+ <n> 1) coords) (nth <n> coords)))
      (setq <n>(1+ <n>)
	    ang(+(angle co (nth <n> coords)) (if (= opc "Azul") ae ad))
	    co+(polar co ang dist)
	    tal(entmakex(list(cons 0 "line")(cons 10 co)(cons 11 co+)(cons 8 "talude")))
	    )(assina 1)
      (command"zoom""o"tal"")
      (command"trim"limite""co+"")
      (setq co+(cdr(assoc 11(entget tal))))
      (if limiteB (command"trim"limiteB""co+"")(princ))
      (if (= meio 1) (setq meio 0) (setq meio 1))
      (if (= meio 1) (progn
		       (setq co+(cdr(assoc 11(entget tal)))
			     co+(list (/(+(car co)(car co+))2) (/(+(cadr co)(cadr co+))2))
			     sub(subst (cons 11 co+) (assoc 11 (entget tal)) (entget tal))
			     sub(entmod sub)
			     )
		       )
	)
      )
    )

  (defun 2b()
    (setq <n> 0
	  meio 0
	  )
    (while(setq co(if(= (nth (1+ <n>) coords) nil)(nth (+ <n> 1) coords) (nth <n> coords)))
      (setq <n>(1+ <n>)
	    ang(+(angle co (nth <n> coords)) (if (= opc "Azul") ae ad))
	    co+(polar co ang dist)
	    tal(entmakex(list(cons 0 "line")(cons 10 co)(cons 11 co+)(cons 8 "talude")))
	    )(assina 1)
      (command"zoom""o"tal"")
      (command"trim"limite""co+"")
      (setq co+(cdr(assoc 11(entget tal))))
      (if limiteB (command"trim"limiteB""co+"")(princ))
      (if (= meio 1) (setq meio 0) (setq meio 1))
      (if (= meio 1) (progn
		       (setq co+(cdr(assoc 11(entget tal)))
			     co(list (/(+(car co)(car co+))2) (/(+(cadr co)(cadr co+))2))
			     sub(subst (cons 10 co) (assoc 10 (entget tal)) (entget tal))
			     sub(entmod sub)
			     )
		       )
	)
      )
    )

  ;;;
  ;;;
  ;;;
  ;;;
  
  (if(= tipo "Crista") (2a) (2b))

  (setvar"osmode"osmode)

  (command"undo""e")

  (princ)
  )

;;;----------------------------------------------------------------------------------------------
;;;----------------------------------------------------------------------------------------------
;;;----------------------------------------------------------------------------------------------

(defun coordlistdist(obj dist /)
  (if(=(length obj)2)
    (setq obj(car obj)
	  len(vlax-get(vlax-ename->vla-object obj) 'Length)
	  )
    (setq len(vlax-get(vlax-ename->vla-object obj) 'Length)
	  )
    )
  (setq pontos nil
	<rep>(/ len dist)
	<d> 0
	)
  (repeat(1+(fix <rep>))
    (setq pontos(vl-list*(vlax-curve-getpointatdist obj <d>)pontos)
	  <d>(+ <d> dist)
	  )
    )
  (setq pontos(vl-list*(vlax-curve-getpointatdist obj len)pontos))
  (reverse pontos)
  )

;;;ASSINA ENTIDADE
(defun assina(F /)
  (if(= F 0)
    (princ(assoc -3 (entget(car(entsel"\nSelecione o objeto para verificar a assinatura: "))'("EDG")) ))
    (progn
      (setq assinatura (list(cons -3 (list(list "EDG"
						(cons 1000 (strcat"Criado em: "(rtos(getvar"cdate")2 4)))
						(cons 1000 (strcat"Usuario: "(vl-registry-read "HKEY_CURRENT_USER\\VOLATILE ENVIRONMENT" "USERNAME")))
						(cons 1000 (strcat"Arquivo: "(getvar"dwgname")))
						(cons 1000 (strcat"Pasta: "(getvar"dwgprefix")))
						))))
	    )
      (regapp "EDG")(entmod(append (entget(entlast)) assinatura ))
      )
    )
  (princ)
  )
;;;(assina 0);Para Ler Assinatura
;;;(assina 1);Para Assinar Objeto