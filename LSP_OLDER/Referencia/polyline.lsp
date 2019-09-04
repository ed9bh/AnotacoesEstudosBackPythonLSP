(vlax-safearray->list(vlax-variant-value(vla-get-coordinates(vlax-ename->vla-object(car(entsel))))))

(VLA-GET-CONSTANTWIDTH(vlax-ename->vla-object(car(entsel)))





(setq 3dpoly(entsel"\nSelecione a Polylinha: ")
      E3dpoly(vlax-ename->vla-object(car 3dpoly))
      Ecoords(vlax-get E3dpoly 'Coordinates)
      )
(vla-addpolyline
  (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
  (vlax-make-variant
    (vlax-safearray-fill
      (vlax-make-safearray vlax-vbdouble (cons 0 (1-(length Ecoords))))
      Ecoords
      )
    )
  )







(vla-addpolyline (vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
   (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length C))))C))
    )


(vlax-put(vlax-ename->vla-object(entlast))'Elevation H)
(vlax-put(vlax-ename->vla-object(entlast))'Color 250)