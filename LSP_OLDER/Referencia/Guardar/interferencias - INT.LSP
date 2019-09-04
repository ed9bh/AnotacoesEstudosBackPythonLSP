(defun c:int()
  (vl-load-com)
  (initget 0 "Não Sim")(if(= EixBas nil)(princ)(setq Ask(getkword"\nDeseja Reconfigurar o perfil?[Sim/Não] <Não>: ")))
  (if(or(= EixBas nil)(= Ask "Sim"))
    (setq EixBas(entsel"\nSelecione o Eixo: ")
	  PtoIni(getpoint"\nPonto inicial do eixo[<Primeiro Ponto>]: ")
	  PerBas(entsel"\nSelecione a linha do terreno no perfil: ")
	  )
    )
  (setq	EixCoo(vlax-get(vlax-ename->vla-object(car EixBas))'Coordinates)
	EixLen(vlax-get(vlax-ename->vla-object(car EixBas))'Length)
	PtoIbs(list(nth 0 EixCoo)(nth 1 EixCoo))
	PtoFbs(list(nth 1 (reverse EixCoo))(nth 0 (reverse EixCoo)))
	PtoIni(if(= PtoIni nil)PtoIbs PtoIni)
	PerPTi(vlax-get(vlax-ename->vla-object(car PerBas))'Coordinates)
	PerPTf(list(nth 1(reverse PerPTi))(nth 0(reverse PerPTi)))
	PerPTi(list(nth 0 PerPTi)(nth 1 PerPTi))
	DisIni(vlax-curve-getDistAtPoint(car EixBas)(vlax-curve-getClosestPointTo(car EixBas)PtoIni))
	;DisTot(- EixLen DisIni)
	)
  (while(setq PtoInt(getpoint"\nClique no ponto da interferencia: "))
    (setq PtoDis(-(vlax-curve-getDistAtPoint(car EixBas)(vlax-curve-getClosestPointTo(car EixBas)PtoInt))DisIni)
	  LayInt(cdr(assoc 8(entget(car(entsel"\nSelecione entidade de Interferencia: ")))))
	  TxtInt(getstring(strcat"\nDigite o texto da interferencia ou continue["LayInt"]: "))
	  PtoInt(polar PerPTi (angle PerPTi(list(car PerPTf)(cadr PerPTi))) PtoDis)
	  PtoInt+(cons 10(list(car PtoInt)(+(cadr PtoInt)500)))
	  PtoInt-(cons 11(list(car PtoInt)(-(cadr PtoInt)500)))
	  )
    (if(> PtoDis(distance PerPTi(list(car PerPTf)(cadr PerPTi))))
      (princ"\nDistancia Superior ao perfil! Ponto invalido!")
      (progn
	(entmake(list'(0 . "line")'(62 . 256)(cons 8 LayInt)PtoInt+ PtoInt-))
	(entmake(list'(0 . "text")'(62 . 256)(cons 8 LayInt)PtoInt+ '(40 . 1.5) '(50 . 1.5708) (cons 1 LayInt)))
	)
      )
    )
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