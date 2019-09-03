(vl-load-com)

(setq atribs(vlax-ename->vla-object(car(entsel))))
(setq atrlst(mapcar'(lambda(x)(list(vla-get-tagstring x)(vla-get-textstring x))) (vlax-safearray->list(vlax-variant-value(vla-getattributes atribs)))))

;;;(setq at(assoc "0" atrlst))
;;;(vla-put-textstring (car at) '"666")

;;;Mudar Texto e outras propriedades
;vlax-put-property ou vlax-put
(vla-put-textstring(vlax-ename->vla-object(car(entsel)))'"999")
(vlax-put(vlax-ename->vla-object(car(entsel)))'TextString"xxx")
(vlax-put(vlax-ename->vla-object(car(entsel)))'Radius 50)
(vlax-put(vlax-ename->vla-object(car(entsel)))'Color 3)
;;;

;(vlax-get-property (vlax-ename->vla-object(car(entsel)))'TextString)
;(vlax-dump-object(vlax-ename->vla-object(car(entsel))))

;;;"AcDbCircle" Circumference
;;;"AcDbLine" Length
;;;"AcDbPolyline" Length
;;;"AcDbSpline"