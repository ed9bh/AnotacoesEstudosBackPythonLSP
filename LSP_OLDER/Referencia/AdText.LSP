(setq txtobj(vla-addtext(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
                        "Teste"
                        (setq pt(vlax-3d-point(list 0 0)))
                        1
                        )

(vla-put-alignment txtobj acAlignmentMiddleCenter)
(vla-put-textalignmentpoint txtobj pt)
(vla-put-rotation txtobj 1.5708)
(vla-put-layer txtobj "TX02")
(vla-put-color txtobj 256)
(vla-put-StyleName txtobj "ROMANS")

(VLA-GET-WIDTH(vlax-ename->vla-object(car(entsel))))

;acAlignmentAligned
;acAlignmentBottomCenter
;acAlignmentBottomLeft
;acAlignmentBottomRight
;acAlignmentCenter
;acAlignmentFit
;acAlignmentLeft
;acAlignmentMiddle
;acAlignmentMiddleCenter
;acAlignmentMiddleLeft
;acAlignmentMiddleRight
;acAlignmentRight
;acAlignmentTopCenter
;acAlignmentTopLeft
;acAlignmentTopRight