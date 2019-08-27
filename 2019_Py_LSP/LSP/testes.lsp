;; FeatureLine
(vlax-invoke-method (vlax-ename->vla-object(car(entsel))) 'GetPoints 0)
(vlax-variant-value (vlax-invoke-method (vlax-ename->vla-object(car(entsel))) 'GetPoints 0) )
(safearray-value (vlax-variant-value(vlax-invoke-method (vlax-ename->vla-object(car(entsel))) 'GetPoints 0)))

 
(vlax-invoke (vlax-ename->vla-object(car(entsel))) 'GetPoints)


;;; IntersectWith
(vlax-variant-value (vla-IntersectWith (vlax-ename->vla-object(car(entsel))) (vlax-ename->vla-object(car(entsel))) acExtendNone))