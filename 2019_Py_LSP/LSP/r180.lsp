(defun c:r180 (/ *error* main acad doc model eobj vlao r_factor rotation rotate180 centerpoint)
  (
   setq
    acad(vlax-get-acad-object)
    doc(vla-get-activedocument acad)
    model(vla-get-modelspace doc)
   )
  
  (defun *error* (msg)
    (vla-endundomark doc)
    (princ msg)
  )
  
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
  
  (defun rotate180 (ent)
    (
     setq
      vlao(vlax-ename->vla-object ent)
      point (vlax-3d-point(centerpoint vlao))
     )
    (vla-rotate vlao point pi)
  )
  
  (defun main()
    (princ "\nSelecione os objetos a rotacionar : ")
    (
     setq
      ssset (ssget)
     )
    (foreach x (ssnamex ssset)
      (if (>(car x) 0)
        (rotate180 (cadr x))
       )
    )
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ)
)


; 90
(defun c:r90 (/ *error* main acad doc model eobj vlao r_factor rotation rotate90 centerpoint)
  (
   setq
    acad(vlax-get-acad-object)
    doc(vla-get-activedocument acad)
    model(vla-get-modelspace doc)
   )
  
  (defun *error* (msg)
    (vla-endundomark doc)
    (princ msg)
  )
  
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
  
  (defun rotate90 (ent)
    (
     setq
      vlao(vlax-ename->vla-object ent)
      point (vlax-3d-point(centerpoint vlao))
     )
    (vla-rotate vlao point (/ pi 2))
  )
  
  (defun main()
    (princ "\nSelecione os objetos a rotacionar : ")
    (
     setq
      ssset (ssget)
     )
    (foreach x (ssnamex ssset)
      (if (>(car x) 0)
        (rotate90 (cadr x))
       )
    )
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ)
)


; 45
(defun c:r45 (/ *error* main acad doc model eobj vlao r_factor rotation rotate45 centerpoint)
  (
   setq
    acad(vlax-get-acad-object)
    doc(vla-get-activedocument acad)
    model(vla-get-modelspace doc)
   )
  
  (defun *error* (msg)
    (vla-endundomark doc)
    (princ msg)
  )
  
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
  
  (defun rotate45 (ent)
    (
     setq
      vlao(vlax-ename->vla-object ent)
      point (vlax-3d-point(centerpoint vlao))
     )
    (vla-rotate vlao point (/ pi 4))
  )
  
  (defun main()
    (princ "\nSelecione os objetos a rotacionar : ")
    (
     setq
      ssset (ssget)
     )
    (foreach x (ssnamex ssset)
      (if (>(car x) 0)
        (rotate45 (cadr x))
       )
    )
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ)
)