(defun c:xtalude (/
                  *error* acad doc MSpace main os
                  VlaoRayList EobC EobP VlaoC VlaoP
                  DistTracos PCoordList TracosAcum TotalLength
                  PointCristaStart PointPeStart PointPeEnds
                  D1 D2 MinDist Cursor AngBase
                  TargetTesteA TargetTesteB Direction
                  PontoDeIntersecao MindBlowList TargetList
                  SegmentoInicio TracoProjecao Target TargetAngle SegmentoFim
                  TempPoint TempElev Coord CompAng
                  ang dis half ErMSG DistTest
                  )
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (setvar 'osmode os)
    (setvar 'cmdecho 1)
    (vla-endundomark doc)
    (if VlaoRayList (foreach item VlaoRayList (vla-delete item)))
    (princ)
  
  )
  
  (defun ListCoordsGeral (VlaoPoly Factor / l n Coords point)
    (setq
      l (vlax-get VlaoPoly 'LENGTH)
      n (- Factor)
      Coords nil
    )
    (repeat
      (abs(fix(/ l Factor)))
      (setq
        point(vlax-curve-getpointatdist VlaoPoly (setq n(+ n Factor)))
        Coords(if point (vl-list* point Coords) Coords)
      )
    )
    (setq Coords(vl-list* (vlax-curve-getendpoint VlaoPoly)Coords))
    (if (car Coords)
      (reverse Coords)
      (reverse (cdr Coords))
    )
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
  
  (defun interPoint (Point1 Point2 Point3 Point4)
  (setq
    Point1(list (car Point1) (cadr Point1))
    Point2(list (car Point2) (cadr Point2))
    Point3(list (car Point3) (cadr Point3))
    Point4(list (car Point4) (cadr Point4))
    NeoPoint(inters Point1 Point2 Point3 Point4 t)
  )
  NeoPoint
)

(defun elevPoint (Point Vlao / EPoint)
  (if (=(type Vlao)'VLA-OBJECT)
    (setq EPoint(vlax-curve-getClosestPointTo Vlao Point))
    (if (=(type Vlao)'ENAME)
      (setq EPoint(vlax-curve-getClosestPointTo (vlax-ename->vla-object Vlao) Point))
      (if (=(type Vlao)'LIST)
        (setq EPoint(vlax-curve-getClosestPointTo (vlax-ename->vla-object (car Vlao)) Point))
      )
    )
  )
  (if EPoint EPoint nil)
)
  
  (defun ListCoords3D(VLAO_3DPoly / Coords CoordsSanitized XYZ X Y Z)
    (setq
      Coords(vlax-get VLAO_3DPoly 'Coordinates)
      XYZ 0
      X nil
      Y nil
      Z nil
      CoordsSanitized nil
    )
    (foreach item Coords
      (cond
        ((equal XYZ 0)(setq X item
                            XYZ(1+ XYZ)
                      )
         )
        ((equal XYZ 1)(setq Y item
                            XYZ(1+ XYZ)
                      )
         )
        ((equal XYZ 2)
         (setq
           Z item
           ;CoordsSanitized(vl-list* (princ(list X Y Z)) CoordsSanitized)
           CoordsSanitized(vl-list* (list X Y Z) CoordsSanitized)
           XYZ 0
           X nil
           Y nil
           Z nil
         )
         )
      )
    )
    (reverse CoordsSanitized)
  )
  
  ;;;
  
  (defun main ()
    (add_layer "TL-TALUDES" 252 "Continuous")
    (setq
      ErMSG "Entidade selecionada não suportada\nDeve ser 3D Polyline!"
      DistTracos (getreal "\tDigite a distancia entre tracos <2m>: ")
      EobC(entsel "\nSelecione a Crista do Talude (3D Polyline) : ")
      VlaoC(vlax-ename->vla-object (car EobC))
      EobP(if
            (=(vla-get-objectname VlaoC) "AcDb3dPolyline")
            (entsel "\tSelecione o Pe do Talude (3D Polyline) : ")
            (progn (alert ErMSG) (quit))
          )
      ;| EobP(if
            (=(vla-get-objectname VlaoC) "AcDb3dPolyline")
            (entsel "\tSelecione o Pe do Talude (3D Polyline) : ")
            (if
              (=(vla-get-objectname VlaoC) "AcDbLine")
              (entsel "\tSelecione o Pe do Talude (Line) : ")
              (if
                (=(vla-get-objectname VlaoC) "AcDbPolyline")
                (entsel "\tSelecione o Pe do Talude (Polyline) : ")
                (progn (alert "Entidade selecionada não suportada\nDeve ser Line, Polyline e 3D Polyline") (quit))
              )
            )
          ) |;
      VlaoP(vlax-ename->vla-object (car EobP))
      DistTracos (if DistTracos DistTracos 2.0)
      PCoordList (ListCoordsGeral VlaoP 1)
      ;PCoordList (ListCoords3D VlaoP)
      TracosAcum (- DistTracos)
      TotalLength (vlax-get VlaoC 'Length)
      PointCristaStart(vlax-curve-getstartpoint VlaoC)
      ;PointCristaEnds(vlax-curve-getendpoint VlaoC)
      PointPeStart(vlax-curve-getstartpoint VlaoP)
      PointPeEnds(vlax-curve-getendpoint VlaoP)
      D1(distance PointCristaStart PointPeStart)
      D2(distance PointCristaStart PointPeEnds)
      MinDist(min D1 D2)
      Cursor(vlax-curve-getpointatdist VlaoC 0.01)
      AngBase(angle PointCristaStart Cursor)
      TargetTesteA(polar PointCristaStart (+ AngBase (/ PI 2)) (/ MinDist 2) )
      TargetTesteB(polar PointCristaStart (- AngBase (/ PI 2)) (/ MinDist 2) )
      Direction (if (< (distance PointPeStart TargetTesteA) (distance PointPeStart TargetTesteB) ) t nil)
      VlaoRayList nil
    )
    
    (if
      (and (=(vla-get-objectname VlaoC) "AcDb3dPolyline") (=(vla-get-objectname VlaoP) "AcDb3dPolyline"))
      (princ)
      (progn (alert ErMSG) (quit))
    )
    
    (while
      (< (setq TracosAcum(+ TracosAcum DistTracos)) TotalLength)
      
      (setq
        Cursor (vlax-curve-getpointatdist VlaoC TracosAcum)
        Target (vlax-curve-getpointatdist VlaoC (+ TracosAcum 0.000001))
        TargetAngle (angle Cursor Target)
        TargetAngle (if Direction
                      (+ TargetAngle (/ pi 2))
                      (- TargetAngle (/ pi 2))
                    )
        DistTest(vl-sort PCoordList '(lambda (a b) (< (distance Cursor a) (distance Cursor b))))
        PontoDeIntersecao(polar Cursor TargetAngle (*(distance Cursor (car DistTest))1.05) )
        MindBlowList nil
        TargetList nil
        SegmentoInicio nil
        TracoProjecao nil
      )
      
      (foreach SegmentoFim PCoordList
        (progn
          (if SegmentoInicio
            (setq
              TempPoint(interPoint Cursor PontoDeIntersecao SegmentoInicio SegmentoFim)
              TempElev(if TempPoint
                        (elevPoint TempPoint VlaoP)
                      )
            )
          )
          (if TempElev
            (setq TargetList(vl-list* TempElev TargetList))
          )
          (setq SegmentoInicio SegmentoFim)
        )
      )
      
      (foreach Coord TargetList
        (progn
          (setq
            CompAng(angle Cursor Coord)
            ang(abs(- TargetAngle CompAng))
            dis(distance Cursor Coord)
            MindBlowList(vl-list* (list ang dis coord) MindBlowList)
          )
        )
      )
      
      (setq TargetList
             (vl-sort MindBlowList '(lambda (x1 x2)
                                      (if (/= (car x1) (car x2))
                                        (< (car x1) (car x2) )
                                        (< (cadr x1) (cadr x2) )
                                      )
                                    )
             )
            Target(if TargetList (caddr(car TargetList)) nil)
      )
      
      (setq half(if half nil t))
      
      (if Target
        (progn
          (setq
            pt1 (if
                  (> (caddr Cursor) (caddr Target))
                  Cursor
                  Target
                )
            pt2 (if
                  half
                  (list
                    (/ (+ (car Cursor)   (car Target))   2.0)
                    (/ (+ (cadr Cursor)  (cadr Target))  2.0)
                    (/ (+ (caddr Cursor) (caddr Target)) 2.0)
                  )
                  Target
                )
            TracoProjecao
             (vla-add3dpoly
               MSpace
               (vlax-make-variant
                 (vlax-safearray-fill
                   (vlax-make-safearray vlax-vbDouble '(0 . 5))
                   (append pt1 pt2)
                 )
               )
             )
          )
        )
        ; (setq TracoProjecao(vla-addline MSpace (if
        ;                                          (>(caddr Cursor)(caddr Target))
        ;                                          (vlax-3d-point Cursor)
        ;                                          (vlax-3d-point Target)
        ;                                        )
        ;                                 (if
        ;                                   half
        ;                                   (vlax-3d-point
        ;                                     (list
        ;                                       (/(+(car Cursor)(car Target))2)
        ;                                       (/(+(cadr Cursor)(cadr Target))2)
        ;                                       (/(+(caddr Cursor)(caddr Target))2)
        ;                                     )
        ;                                   )
        ;                                   (vlax-3d-point Target)
        ;                                 )
        ;                    )
        ; )
      )
      
      (if
        TracoProjecao
        (vlax-put TracoProjecao 'Layer "TL-TALUDES")
      )
      
      (princ)
      
    )
    
  )
  
  (setq
    ; AutoCAD
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
    os(getvar 'osmode)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (setvar 'osmode 0)
  (main)
  (setvar 'osmode os)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)

;|EDG(2026)[https://www.linkedin.com/in/ericdrumond]{https://github.com/ed9bh}|;