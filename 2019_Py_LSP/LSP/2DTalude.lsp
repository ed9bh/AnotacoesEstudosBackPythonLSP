(defun c:2Dtalude (/ *error* main *InvalidSelectionException* cad doc MSpace)
  
  (setq *InvalidSelectionException* "Selecione uma entidade valida...")
  
  (defun *error* (msg)
    (setvar 'osmode Os)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nErro: " msg))
    )
    (princ)
  )
  
  (defun add_layer(name color ltype / vlayer)
    (setq
      vlayer (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ) ) ) name)
     )

    (if color
        (vla-put-color vlayer color)
        (vla-put-color vlayer 250)
        )

    (if ltype
        (vla-put-linetype vlayer ltype)
        (vla-put-linetype vlayer "continuous")
        )
    (vlax-release-object vlayer)
  )
  
  (defun ListCoords2D(VLAO_2DPoly / Coords CoordsSanitized XY X Y)
    (setq
      Coords(vlax-get VLAO_2DPoly 'Coordinates)
      XY 0
      X nil
      Y nil
      CoordsSanitized nil
    ); (vlax-dump-object(vlax-ename->vla-object(car(entsel))))
    (foreach item Coords
      (cond
        ((equal XY 0)(setq X item
                           XY(1+ XY)
                     )
         )
        ((equal XY 1)
         (setq
           Y item
           CoordsSanitized(vl-list* (princ(list X Y)) CoordsSanitized)
           XYZ 0
           X nil
           Y nil
         )
        )
      )
    )
    (reverse CoordsSanitized)
  )
  
  (defun SideAngle (VlaoPolyBase VlaoPolyCompare)
    (setq
      RefPoint1
       (vlax-curve-getstartpoint VlaoPolyBase)
      RefPoint2
       (vlax-curve-getpointatdist VlaoPolyBase 0.01)
      RefPoint3
       (vlax-curve-getstartpoint VlaoPolyCompare)
      RefAlignedAngle
       (angle RefPoint1 RefPoint2)
      RefAngle
       (angle RefPoint1 RefPoint3)
      RefDist
       (distance RefPoint1 RefPoint3)
    )
    (if
      (<
        (distance RefPoint1 (polar RefPoint1 (+ RefAngle (/ pi 2)) RefDist))
        (distance RefPoint1 (polar RefPoint1 (- RefAngle (/ pi 2)) RefDist))
      )
      +
      -
    )
  )
  
  
  (defun main (/
               EobjCristaPolyline VlaoCristaPolyline EobjPePolyline VlaoPePolyline DayLightLengthRepresentation
               Rep Prog FullHalf Side PointTop PointTopVirtual TempAng PointTemp VlaoTempLine TempDist PointDawn DayLightLine
               )
    
    (setq EobjCristaPolyline(entsel "\tSelecione a polylinha de crista : ") )
    (if EobjCristaPolyline (setq VlaoCristaPolyline (vlax-ename->vla-object (car EobjCristaPolyline)) ) (progn (alert *InvalidSelectionException*) (exit)))
    (setq ElevTop (vla-get-elevation VlaoCristaPolyline))
    
    (setq EobjPePolyline(entsel "\tSelecione a polylinha de pe : ") )
    (if EobjPePolyline (setq VlaoPePolyline (vlax-ename->vla-object (car EobjPePolyline)) ) (progn (alert *InvalidSelectionException*) (exit)))
    (setq ElevDawn (vla-get-elevation VlaoPePolyline))
    
    (if
      (>
        (distance (vlax-curve-getstartpoint VlaoCristaPolyline) (vlax-curve-getstartpoint VlaoPePolyline))
        (distance (vlax-curve-getstartpoint VlaoCristaPolyline) (vlax-curve-getendpoint VlaoPePolyline))
      )
      (vl-cmdf "reverse" (car EobjPePolyline) "")
    )
    
    (initget 6)
    (setq
      DayLightLengthRepresentation (getreal "\nDigite a distancia entre linhas de representação de taludes: ")
      Rep (fix (abs (/ (vla-get-length VlaoCristaPolyline) DayLightLengthRepresentation) ))
    )
    
    (vla-put-elevation VlaoPePolyline ElevTop)
    
    (setq
      Prog 0.
      FullHalf t
      Side (SideAngle VlaoCristaPolyline VlaoPePolyline)
    )
    
    (repeat
      Rep
      (setq
        PointTop (vlax-curve-getpointatdist VlaoCristaPolyline Prog)
        PointTopVirtual (vlax-curve-getpointatdist VlaoCristaPolyline (+ Prog 0.01))
        Prog (+ Prog DayLightLengthRepresentation)
        TempAng nil PointTemp nil VlaoTempLine nil
        TempDist nil PointDawn nil DayLightLine nil
        TempAng(angle PointTop PointTopVirtual)
        PointTemp(polar PointTop (side TempAng (/ pi 2.)) 1.)
        VlaoTempLine(vla-addline MSpace (vlax-3d-point PointTop) (vlax-3d-point PointTemp))
        PointDawn(vlax-invoke VlaoTempLine 'IntersectWith VlaoPePolyline acExtendThisEntity)
      )
      (if
        (> (length PointDawn) 3)
        (if
          (<
            (distance PointTop (list (nth 0 PointDawn) (nth 1 PointDawn) (nth 2 PointDawn)))
            (distance PointTop (list (nth 3 PointDawn) (nth 4 PointDawn) (nth 5 PointDawn)))
          )
          (setq
            PointDawn (list (nth 0 PointDawn) (nth 1 PointDawn) (nth 2 PointDawn))
          )
          (setq
            PointDawn (list (nth 3 PointDawn) (nth 4 PointDawn) (nth 5 PointDawn))
          )
        )
      )
      (if PointDawn
        (progn
          (setq
            TempAng(angle PointTop (list (car PointDawn) (cadr PointDawn) (caddr PointDawn)) )
            TempDist(/(distance PointTop (list (car PointDawn) (cadr PointDawn) (caddr PointDawn)) )(if FullHalf 1. 2.))
            PointDawn(polar PointTop TempAng TempDist)
            DayLightLine(vla-addline MSpace (vlax-3d-point PointTop) (vlax-3d-point (list (car PointDawn) (cadr PointDawn) (if FullHalf ElevDawn (/(+ ElevTop ElevDawn)2.)) ) ) )
            FullHalf(if FullHalf nil t)
          )
          (vlax-put DayLightLine 'Layer "TL-GER-TLD")
        )
      )
      
      (if VlaoTempLine (vla-delete VlaoTempLine))
    )
    
    (vla-put-elevation VlaoPePolyline ElevDawn)
    
  )
  
  (setq
    ; AutoCAD
    cad (vlax-get-acad-object)
    doc (vla-get-activedocument cad)
    MSpace (vla-get-modelspace doc)
    Os (getvar 'osmode)
  )
  
  (add_layer "TL-GER-TLD" 250 nil)
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (setvar 'osmode 0)
  (main)
  (setvar 'osmode Os)
  (setvar 'cmdecho 1)
  (vla-endundomark doc)
  (princ)
  
)