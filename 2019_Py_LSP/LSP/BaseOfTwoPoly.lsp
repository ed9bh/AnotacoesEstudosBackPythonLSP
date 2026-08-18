(defun c:BaseOfTwoPoly (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (vla-endundomark doc)
    (princ)
  
  )
    
  ;;; List Coords
  
  (defun ListCoordsGeral (VlaoPoly Factor / l n Coords point)
    (setq
      l (vlax-get VlaoPoly 'LENGTH)
      Factor (/ l Factor)
      n (- 0.0 Factor)
      Coords nil
    )
    (while
      (< n l)
      ;(princ(strcat (rtos n 2 1) ", "))
      (setq
        point(vlax-curve-getpointatdist VlaoPoly (setq n(+ n Factor)))
        Coords(if point (vl-list* point Coords) Coords)
      )
    )
    (setq Coords(vl-list* (vlax-curve-getendpoint VlaoPoly)Coords))
    ;(reverse (cdr Coords))
    ;(princ Coords)
    (reverse Coords)
  )
  
  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (setq
      UserFactor(getreal "\nFator de detalhamento <ENTER> (10) : ")
      UserFactor(if UserFactor UserFactor 10)
      EPoly001(entsel "\nSelecione a primeira Polyline : ")
      EPoly002(entsel "\tSelecione a segunda Polyline : ")
      VlaoPoly001(vlax-ename->vla-object (car EPoly001))
      VlaoPoly002(vlax-ename->vla-object (car EPoly002))
      BiggerLength(max (vlax-get VlaoPoly001 'LENGTH) (vlax-get VlaoPoly002 'LENGTH) )
      Factor (cond
               ((< BiggerLength 1.0) 0.01)
               ((< BiggerLength 10.0) 0.1)
               ((< BiggerLength 100.0) 1.0)
               ((< BiggerLength 1000.0) 10.0)
               ((< BiggerLength 10000.0) 100.0)
               ((< BiggerLength 100000.0) 1000.0)
             )
      ObjName(if
               (=
                 (vlax-get VlaoPoly001 'ObjectName)
                 (vlax-get VlaoPoly002 'ObjectName)
               )
               (setq
                 Type3D(if (=(vlax-get VlaoPoly001 'ObjectName)"AcDb3dPolyline") T nil)
               )
               (progn
                 (alert "Entidades precisam ser do mesmo tipo...")
                 (quit)
               )
             )
      LPointsPoly001(ListCoordsGeral VlaoPoly001 (* Factor UserFactor) )
      LPointsPoly002(ListCoordsGeral VlaoPoly002 (* Factor UserFactor) )
      LPointsPoly002(if
                      (>
                        (distance (car LPointsPoly001) (car LPointsPoly002))
                        (distance (car LPointsPoly001) (last LPointsPoly002))
                      )
                      (reverse LPointsPoly002)
                      LPointsPoly002
                    )
      TempLPointsPoly001 LPointsPoly001
      TempLPointsPoly002 LPointsPoly002
      NewPolyCoords nil
    )
    
    (while
      (setq PointA(car TempLPointsPoly001))
      (setq
        PointB(car TempLPointsPoly002)
      )
      (if (and
            (>(length TempLPointsPoly001)0)
            (>(length TempLPointsPoly002)0)
          )
        (setq
          X(/(+(car PointA)(car PointB))2)
          Y(/(+(cadr PointA)(cadr PointB))2)
          Z(if
             Type3D
             (/(+(caddr PointA)(caddr PointB))2)
             nil
           )
          NewPolyCoords
           (if
             Type3D
             (vl-list* (list X Y Z) NewPolyCoords)
             (vl-list* (list X Y) NewPolyCoords)
           )
        )
      )
      (setq
        TempLPointsPoly001(cdr TempLPointsPoly001)
        TempLPointsPoly002(cdr TempLPointsPoly002)
      )
    )
    
    (if
      Type3D
      (setq
        NewPoly
         (vla-add3DPoly
           MSpace
           (vlax-make-variant
             (vlax-safearray-fill
               (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse NewPolyCoords))))))
               (apply'append(reverse NewPolyCoords))
             )
           )
         )
      )
      (setq
        NewPoly
         (vla-addLightweightPolyline
           MSpace
           (vlax-make-variant
             (vlax-safearray-fill
               (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length (apply'append(reverse NewPolyCoords))))))
               (apply'append(reverse NewPolyCoords))
             )
           )
         )
      ) 
    )
    
  )
  
  ;;; --------------------------------------> Rotina
  
  (setq
    ; AutoCAD
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
    ; Civil 3D
    C3DReg (strcat "HKEY_LOCAL_MACHINE\\" (if vlax-user-product-key (vlax-user-product-key) (vlax-product-key)))
    C3DCode (vl-registry-read C3DReg "Release")
    VerString (substr C3DCode 1 (vl-string-search "." C3DCode (1+(vl-string-search "." C3DCode))))
    ProdutString (strcat "AeccXUiLand.AeccApplication." VerString)
    DataString (strcat "AeccXLand.AeccTinCreationData." VerString)
    C3D (vl-catch-all-apply 'vlax-invoke (list (vlax-get-acad-object) 'GetInterfaceObject ProdutString))
    C3Ddoc (vla-get-activedocument C3D)
    C3DMSpace (vla-get-modelspace C3Ddoc)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)