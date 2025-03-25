(defun r_x (rotate_factor / *error* main acad doc model eobj vlao r_factor rotation rotate180 centerpoint)
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
  
  (defun rotate (ent)
    (
     setq
      vlao(vlax-ename->vla-object ent)
      point (vlax-3d-point(centerpoint vlao))
     )
    (vla-rotate vlao point rotate_factor)
  )
  
  (defun main()
    (princ "\nSelecione os objetos a rotacionar : ")
    (
     setq
      ssset (ssget)
     )
    (foreach x (ssnamex ssset)
      (if (>(car x) 0)
        (rotate (cadr x))
       )
    )
  )
  
  (vla-startundomark doc)
  (main)
  (vla-endundomark doc)
  (princ "...r180/r90/r60/r45/r30/r18/r-90/r-60/r-45/r-30/r-18...")
  (princ)
)

(defun c:r180 () (r_x pi))
(defun c:r90 () (r_x (/ pi 2)))
(defun c:r60 () (r_x (/ pi 3)))
(defun c:r45 () (r_x (/ pi 4)))
(defun c:r30 () (r_x (/ pi 6)))
(defun c:r18 () (r_x (/ pi 10)))
(defun c:r-90 () (r_x (*(/ pi 2)-1)))
(defun c:r-60 () (r_x (*(/ pi 3)-1)))
(defun c:r-45 () (r_x (*(/ pi 4)-1)))
(defun c:r-30 () (r_x (*(/ pi 6)-1)))
(defun c:r-18 () (r_x (*(/ pi 10)-1)))