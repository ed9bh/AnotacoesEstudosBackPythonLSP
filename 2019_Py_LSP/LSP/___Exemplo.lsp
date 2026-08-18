(defun c:LispName (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    (vla-endundomark doc)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nErro: " msg))
    )
    (princ)
  )
  
  ; Log
  (defun LogReport(fileNew msg)
    (setq
      FileNameMem (if FileNameMem FileNameMem nil)
      FileNameMem (if fileNew nil FileNameMem)
    )
    (if 
      (= fileNew t)
      (setq
        LogFilePath(strcat(getvar 'dwgprefix)"LogReport("(vl-string-right-trim ".dwg" (getvar 'dwgname))")-"(vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) )".log")
        FileNameMem LogFilePath
      )
      (setq
        LogFilePath FileNameMem
      )
    )
    (setq LogFileOpened(open LogFilePath "a+"))
    (princ
      (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) ) "]:> " (if msg msg "...") "\n" )
      LogFileOpened
      )
    (close LogFileOpened)
  )
  
  ; Listar Corrdenadas de Polyline 3D
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
           CoordsSanitized(vl-list* (princ(list X Y Z)) CoordsSanitized)
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
  
  ; Listar Corrdenadas de Polyline 2D
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
  
  ; Listar Coordenadas de X em X distância
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
    (reverse (cdr Coords))
  )
  
  ;;; Sleep Time
  (defun sleep (seconds msg display)
    (defun now ()
      (getvar'cdate)
    )
    
    (setq
      delta (now)
      deltatime(+ delta (/ seconds 1000000.0))
    )
    
    (while (<= (now) deltatime)
      (if display
        (progn
          (princ
            (strcat
              (rtos (now) 2 6)
              "\t->\t"
              (rtos deltatime 2 6)
              "\r"
            )
          )
        )
      )
    )
    
    (princ msg)
    (princ)
  )
  
  (defun info_to_clipBoard(info)
    (vlax-invoke
      (vlax-get
        (vlax-get
          (setq htmlfile (vlax-create-object "htmlfile"))
          'ParentWindow
        )
        'ClipBoardData
      )
      'SetData
      "Text"
      info
    )
    (vlax-release-object htmlfile)
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
  
  ;;; Draworder - Send to Back
  (defun send_to_back(vlao)
    (vlax-invoke
     (vla-addobject
       (vla-GetExtensionDictionary
        (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
        )
      "ACAD_SORTENTS" "AcDbSortentsTable"
      )
     'MoveToBottom
     (list vlao)
     )
    (vlax-release-object vlao)
  )

  ;;; Draworder - Bring to Front
  (defun bring_to_front(vlao)
    (vlax-invoke
     (vla-addobject
       (vla-GetExtensionDictionary
        (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
        )
      "ACAD_SORTENTS" "AcDbSortentsTable"
      )
     'MoveToTop
     (list vlao)
     )
    (vlax-release-object vlao)
  )

  ;;; Append content in file text
  (defun add->to_file(filename inplace content / file_open)
    (if (= inplace t)
        (setq file_open(open (strcat (getvar'dwgprefix) filename) "a"))
        (setq file_open(open filename "a"))
        )
    (write-line content file_open)
    (close file_open)
  )

  ;;; Get Bound Box
  (defun Get_Bounding_Box(vlao / point_list point_min point_max)
    (setq
     point_list(vlax-invoke-method vlao 'GetBoundingBox 'point_min 'point_max)
     point_min(vlax-safearray->list point_min)
     point_max(vlax-safearray->list point_max)
     )
    (list point_min point_max)
  )
  
  ;;; Seleciona maior ponto e menor ponto de uma lista SSGET
  (defun select_points_min_max(ss_list / x_list y_list s e)
      (setq x_list nil y_list nil)
      (foreach s (ssnamex ss_list)
          (if (< (car s) 0)
              (foreach e (cdr s)
                  (setq
                      point(cadr e)
                      x_list(vl-list* (car point) x_list)
                      y_list(vl-list* (cadr point) y_list)
                      )
                  )
              )
          )
    (list (list (apply 'min x_list) (apply 'min y_list) ) (list (apply 'max x_list) (apply 'max y_list) ) )
  )
  
  ;;; Center Point
  (defun centerpoint(vlao / point_list point_min point_max x_center y_center)
    (setq
     point_list(vlax-invoke-method vlao 'GetBoundingBox 'point_min 'point_max)
     point_min(vlax-safearray->list point_min)
     point_max(vlax-safearray->list point_max)
     x_center(/(+(car point_min)(car point_max))2)
     y_center(/(+(cadr point_min)(cadr point_max))2)
     )
    (list x_center y_center)
  )
  
  ;;; Mover Pelo Centro
  (defun xmove(vlao destine_point / min_point max_point center_x center_y center_z)
    (vl-catch-all-apply 'vla-GetBoundingBox (list vlao 'min_point 'max_point))
    (if (= min_point nil)
        (progn (print "Error : Ponto não encontrado...") (quit))
        )
    (setq
     min_point(vlax-safearray->list min_point)
     max_point(vlax-safearray->list max_point)
     center_x(/ (+(car min_point)(car max_point)) 2)
     center_y(/ (+(cadr min_point)(cadr max_point)) 2)
     center_z(/ (+(caddr min_point)(caddr max_point)) 2)
     )
    (vla-move vlao (vlax-3d-point (list center_x center_y center_z)) (vlax-3d-point destine_point) )
  )
  
  ;;; String to List
  (defun string->list ( String delimiter / len lst pos )
    (setq len (1+ (strlen delimiter)))
    (while (setq pos (vl-string-search delimiter String))
        (setq lst (cons (substr String 1 pos) lst)
              String (substr String (+ pos len))
        )
    )
    (reverse (cons String lst))
  )
  
  ;;; Angulo Central
  (defun AnguloCentral ( p1 p2 p3 )
    (   (lambda ( a ) (min a (- (+ pi pi) a)))
        (rem (+ pi pi (- (angle p2 p1) (angle p2 p3))) (+ pi pi))
    )
  )
  
  ;;; Azimute
  (defun Azimute (ponto_a ponto_b)
    (setq
      dx(-(car ponto_b)(car ponto_a))
      dy(-(cadr ponto_b)(cadr ponto_a))
      azim (atan dx dy)
    )
    (if (< azim 0)
      (setq azim (+ azim (* pi 2)))
    )
    azim
  )

  ;;; --------------------------------------> Main
  
  (defun main ()
    
    (princ "Não desenvolvido ainda...")
    
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
  (setvar 'cmdecho 1)
  (vla-endundomark doc)
  (princ)
  
)