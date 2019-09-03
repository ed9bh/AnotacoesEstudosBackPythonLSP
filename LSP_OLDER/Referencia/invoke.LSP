(vlax-invoke(vlax-ename->vla-object(car(entsel)))'Explode)

(vlax-dump-object(vlax-ename->vla-object(car(entsel)))t)

(vlax-get(vlax-ename->vla-object(car(entsel)))'GetBoundingBox)

(setq obj(vlax-ename->vla-object(car(entsel))))

(vlax-invoke-method obj 'GetBoundingBox 'boxmin 'boxmax)(list boxmin boxmax)

(vla-getboundingbox obj 'boxmin 'boxmax)(list boxmin boxmax)