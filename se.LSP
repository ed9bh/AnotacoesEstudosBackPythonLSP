(defun c:se()
  (vl-load-com)
  (vlax-put
    (vlax-ename->vla-object(car(entsel"\nSelecione a polyline a receber a nova elevação: ")))
    'Elevation
    (vlax-get(vlax-ename->vla-object(car(entsel"\tSelecione a polylinha com a elevação: ")))'Elevation)
    )
  )