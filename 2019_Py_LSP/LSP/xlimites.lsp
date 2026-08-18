(defun c:xlimites (/ *error* acad doc model)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    
    (princ msg)
    (vla-endundomark doc)
    (princ)
  
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
  
  ;;; --------------------------------------> Main
  
  (defun main (/ VlaoEntity)
    
    (prompt "\tSelecione as entidades : ")
    
    (setq
      ss(ssnamex(ssget))
      lista_de_pontos_X nil
      lista_de_pontos_Y nil
      lista_de_pontos_Z nil
      AreaFinal '(0.)
    )
    
    (foreach x ss
      (if (>= (car x) 0)
        (progn
          (setq
            VlaoEntity(vlax-ename->vla-object (cadr x))
            coordenadas_box(Get_Bounding_Box VlaoEntity)
            lista_de_pontos_X(vl-list* (car(car coordenadas_box)) lista_de_pontos_X)
            lista_de_pontos_X(vl-list* (car(cadr coordenadas_box)) lista_de_pontos_X)
            lista_de_pontos_Y(vl-list* (cadr(car coordenadas_box)) lista_de_pontos_Y)
            lista_de_pontos_Y(vl-list* (cadr(cadr coordenadas_box)) lista_de_pontos_Y)
            lista_de_pontos_Z(vl-list* (caddr(car coordenadas_box)) lista_de_pontos_Z)
            lista_de_pontos_Z(vl-list* (caddr(cadr coordenadas_box)) lista_de_pontos_Z)
          )
          (vl-cmdf "area" "object" (cadr x))
          (setq AreaFinal (append AreaFinal (list (getvar 'Area)) ) )
          (vlax-release-object VlaoEntity)
        )
      )
    )
    
    (setq
      x_maior(apply 'max lista_de_pontos_X)
      x_menor(apply 'min lista_de_pontos_X)
      y_maior(apply 'max lista_de_pontos_y)
      y_menor(apply 'min lista_de_pontos_y)
      Z_maior(apply 'max lista_de_pontos_Z)
      Z_menor(apply 'min lista_de_pontos_Z)
    )
    
    (princ (strcat
             "\nArea Total: " (rtos (apply '+ (append AreaFinal) ) 2)
             "\n"
             "Elev. Maior: "(rtos Z_maior 2)
             " | "
             "Elev. Menor: "(rtos Z_menor 2)
             "\nDelta X: " (rtos (- X_maior x_menor) 2) " - Delta Y: " (rtos (- Y_maior y_menor) 2) " - Delta Z: " (rtos (- Z_maior Z_menor) 2)
           )
    )
    
        
  )
  
  ;;; --------------------------------------> Rotina
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    model (if (= (getvar 'ctab) "Model") (vla-get-modelspace doc) (vla-get-paperspace doc))
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (main)
  (vla-endundomark doc)
  (setvar 'cmdecho 1)
  (princ)
  
)