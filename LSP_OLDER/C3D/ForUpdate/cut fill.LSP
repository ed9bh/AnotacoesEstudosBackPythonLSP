(setq
  mlhTrnglr(entsel"\nMalha Triangular : ")
  EmlhTrnglr(entget(car mlhTrnglr))
  VmlhTrnglr(vlax-ename->vla-object(car mlhTrnglr))
  )

(vlax-dump-object VmlhTrnglr t)
(vlax-dump-object (vlax-get VmlhTrnglr 'SurfaceAnalysis) t)
(vlax-dump-object (vlax-get VmlhTrnglr 'Statistics) t)
(vlax-get(vlax-get VmlhTrnglr 'Statistics)'CutVolume)
(vl-catch-all-error-message (vl-catch-all-apply 'vlax-get (List VmlhTrnglr 'CutVolume) ))


(foreach x (ssnamex(ssget"x"'((0 . "AECC_TIN_SURFACE"))))
  (progn
    (setq
      v(vlax-ename->vla-object(cadr x))
      ;Cuterro(vl-catch-all-apply 'vlax-get (list v 'CutVolume) )
      )
    ;(princ Cuterro)
    ;(vlax-dump-object (vlax-get v 'Statistics))
    ;(princ (VLAX-METHOD-APPLICABLE-P (vlax-get v 'Statistics)'CutVolume) )
    ;(princ (VLAX-PROPERTY-AVAILABLE-P (vlax-get v 'Statistics)'CutVolume) )
    (if (=(VLAX-PROPERTY-AVAILABLE-P (vlax-get v 'Statistics)'CutVolume)t)
      ;(/= (vl-catch-all-error-message Cuterro) "ActiveX Server returned the error: unknown name: \"CUTVOLUME\"" )
      ;(princ"\t..Erro..\n")
      (progn
	(princ(vlax-get(vlax-get v 'Statistics)'CutVolume))
	(princ" <= Cut || Fill => ")
	(princ(vlax-get(vlax-get v 'Statistics)'FillVolume))
	(princ"\n")
	(princ)
	)
      )
    (setq Cuterro nil)
    )
  (princ)
  )

(setq
  skp(vlax-get-or-create-object "Skype4COM.Skype")
  sapi(vlax-get-or-create-object "SAPI.SpVoice")
  )
(vlax-dump-object sapi t)
(vlax-invoke sapi 'Speak "Teste")
