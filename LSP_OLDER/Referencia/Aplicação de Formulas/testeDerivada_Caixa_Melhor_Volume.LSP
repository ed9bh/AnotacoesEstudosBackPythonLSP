(vl-load-com)
(defun c:dbox()
  (setq
    Larg(getdist"\nDigite a largura: ")
    Comp(getdist"\tDigite o comprimento: ")
    ;Bordas Para Alcançar o Melhor Volume
    ;V = x (40 - 2x) (60 - 2x)
    ;V = x (2400 - 80x - 120x + 4x^2)
    ;V = 4x^3 - 200x^2 + 2400x
    x 1
    a(*(expt(* 2 x)2)3);4x^3
    b(*(+(*(* 2 Comp)-1)(*(* 2 Larg)-1))2);(2 * Larg) - (2 * Comp)
    c(* Larg Comp);(Larg * Comp)
    Delta(-(expt b 2)(* 4 a c))
    x1(/(-(* b -1)(sqrt Delta))(* a 2))
    x2(/(+(* b -1)(sqrt Delta))(* a 2))
    xMin(min x1 x2)
    ;Volume
    ;
    Vol(+
	 (*(expt(* 2 x)2)(expt xMin 3))
	 (*(+(*(* 2 Comp)-1)(*(* 2 Larg)-1))(expt xMin 2))
	 (*(* Larg Comp)(expt xMin 1))
	 )
    point(getpoint"\nClique no ponto para inserção da caixa: ")
    xDist(- Larg (* xMin 2))
    yDist(- Comp (* xMin 2))
    zDist xMin
    xA(car point)
    xB(+(car point)xDist)
    yA(cadr point)
    yB(+(cadr point)yDist)
    zA(caddr point)
    zB(+(caddr point)zDist)
    model(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    )
  ;Box
  (vla-addline model (vlax-3d-point(list xA yA zA)) (vlax-3d-point(list xA yB zA)))
  (vla-addline model (vlax-3d-point(list xA yA zB)) (vlax-3d-point(list xA yB zB)))
  (vla-addline model (vlax-3d-point(list xA yB zA)) (vlax-3d-point(list xB yB zA)))
  (vla-addline model (vlax-3d-point(list xA yB zB)) (vlax-3d-point(list xB yB zB)))
  (vla-addline model (vlax-3d-point(list xA yA zA)) (vlax-3d-point(list xB yA zA)))
  (vla-addline model (vlax-3d-point(list xA yA zB)) (vlax-3d-point(list xB yA zB)))
  (vla-addline model (vlax-3d-point(list xB yA zA)) (vlax-3d-point(list xB yB zA)))
  (vla-addline model (vlax-3d-point(list xB yA zB)) (vlax-3d-point(list xB yB zB)))
  (vla-addline model (vlax-3d-point(list xA yA zA)) (vlax-3d-point(list xA yA zB)))
  (vla-addline model (vlax-3d-point(list xA yB zA)) (vlax-3d-point(list xA yB zB)))
  (vla-addline model (vlax-3d-point(list xB yA zA)) (vlax-3d-point(list xB yA zB)))
  (vla-addline model (vlax-3d-point(list xB yB zA)) (vlax-3d-point(list xB yB zB)))
  (princ(strcat"\nO Volume é igual a: "(rtos Vol 2 3)" Unid. Vol."))
  (princ)
  )