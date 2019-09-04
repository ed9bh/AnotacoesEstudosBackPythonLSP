(defun c:1()
  (setq bj1(vlax-ename->vla-object(car(entsel"\n1: ")))
	bj2(vlax-ename->vla-object(car(entsel"\n2: ")))
	)
  (vlax-invoke bj1 'IntersectWith bj2 acExtendNone)
  );;; \o/

;(vlax-invoke bj1 'IntersectWith bj2 acExtendBoth)
;(vlax-invoke bj1 'IntersectWith bj2 acExtents)
;(vlax-invoke bj1 'IntersectWith bj2 acExtendOtherEntity)
;(vlax-invoke bj1 'IntersectWith bj2 acExtendThisEntity)