(setq
  ucs(vla-get-usercoordinatesystems(setq actdoc(vla-get-activedocument(vlax-get-acad-object))))
  actdocutil(vla-get-utility actdoc)
  ucsAtual(if(=(vlax-variant-value(vla-getvariable actdoc "UCSNAME"))"")
	    (vla-add ucs
		     (vla-getvariable actdoc "UCSORG")
		     (vla-translatecoordinates actdocutil (vla-getvariable actdoc"UCSXDIR") acUCS acWorld :vlax-false)
		     (vla-translatecoordinates actdocutil (vla-getvariable actdoc"UCSYDIR") acUCS acWorld :vlax-false)
		     "OriginalUCS"
		     )
	    (vla-get-activeucs actdoc)
	    )
  )

;Nova UCS
(setq ori(vlax-3d-point 0 0 0);Exemplo
      pa(vlax-3d-point 1 1 0);Exemplo
      pb(vlax-3d-point -1 1 0);Exemplo
      ucsNew(vla-add ucs ori pa pb "Exemplo");Exemplo
      );Exemplo
(vla-put-activeucs actdoc ucsNew);Exemplo


;Voltar
(vla-put-activeucs actdoc ucsAtual);Exemplo


;World
(setq ori(vlax-3d-point 0 0 0);Exemplo
      pa(vlax-3d-point 0 1 0);Exemplo
      pb(vlax-3d-point 1 0 0);Exemplo
      ucsNew(vla-add ucs ori pa pb "Exemplo");Exemplo
      );Exemplo
(vla-put-activeucs actdoc ucsNew);Exemplo