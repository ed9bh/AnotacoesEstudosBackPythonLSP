(defun c:ListPolylines ( / main *error* WriteText ListCoordsGeral)
  
  (vl-load-com)
  
  (defun ListCoordsGeral (VlaoPoly Factor / l n Coords point)
    (setq
      l (vlax-get VlaoPoly 'LENGTH)
      Factor (/ l Factor)
      n (- 0.0 Factor)
      Coords nil
    )
    (while
      (< n l)
      (setq
        point(vlax-curve-getpointatdist VlaoPoly (setq n(+ n Factor)))
        Coords(if point (vl-list* point Coords) Coords)
      )
    )
    (setq Coords(vl-list* (vlax-curve-getendpoint VlaoPoly)Coords))
    (reverse (cdr Coords))
  )
  
  (defun WriteText(FileName New LineTextStrings)
    (setq
      FilePath(strcat(getvar 'dwgprefix) FileName ".txt")
    )
    (setq LogFileOpened(open FilePath (if New "w+" "a+")))
    (princ (strcat LineTextStrings "\n") LogFileOpened)
    (close LogFileOpened)
  )
  
  (defun *error* (msg)
    (vla-endundomark doc)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nErro: " msg))
    )
    (princ)
  )
  
  (defun Eixo ()
    (setq
      EixoEname(entsel "\tSelecione o Eixo do Projeto:> ")
      EixoVlao(if EixoEname (vlax-ename->vla-object(car EixoEname)) (exit))
      Distancia(getreal "\tDigite a distancia entre pontos:<5.0> ")
      Distancia(if Distancia Distancia 5.)
      CoordsLista(ListCoordsGeral EixoVlao Distancia)
      NameOfBaseLineFile (strcat
                           (vl-string-right-trim ".dxf" (vl-string-right-trim ".dwg" (getvar 'dwgname) ))
                           "BaseLine"
                         )
    )
    (foreach point CoordsLista
      (setq
        X(car point)
        y(cadr point)
        z(caddr point)
      )
      (WriteText NameOfBaseLineFile nil (strcat (rtos x 2 6)";"(rtos y 2 6)";"(rtos z 2 6) ) )
    )
  )
  
  (defun CurvasDeNivel ()
    "..."
  )
  
  (defun main ()
    "..."
  )
  
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (setvar 'cmdecho 1)
  (vla-endundomark doc)

  (princ)
  
)