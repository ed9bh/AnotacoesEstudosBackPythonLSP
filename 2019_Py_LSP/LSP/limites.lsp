(defun c:limites (/ *error* acad doc model)
  
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
             "\n"
             "Elev. Maior: "(rtos Z_maior 2)
             "\n"
             "Elev. Menor: "(rtos Z_menor 2)
             "\n"
           )
    )
    
    (vla-addline model
                 (vlax-3d-point (list x_menor y_menor))
                 (vlax-3d-point (list x_menor y_maior))
    )
    
    (vla-addline model
                 (vlax-3d-point (list x_menor y_maior))
                 (vlax-3d-point (list x_maior y_maior))
    )
    
    (vla-addline model
                 (vlax-3d-point (list x_maior y_maior))
                 (vlax-3d-point (list x_maior y_menor))
    )
    
    (vla-addline model
                 (vlax-3d-point (list x_menor y_menor))
                 (vlax-3d-point (list x_maior y_menor))
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