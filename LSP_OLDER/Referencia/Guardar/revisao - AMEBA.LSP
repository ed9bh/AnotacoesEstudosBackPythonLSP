(defun c:ameba()
  (vl-load-com)(setvar"cmdecho"0)(command"undo""be")
  (command"layout""set"(car(layoutlist)))
  (if(tblsearch"layer"(setq lay"REVISÃO"))(command"-layer""set"lay"")(command"-layer""make"lay""))
  (setq pt(getpoint"\nClique no primeiro ponto da revisão: "))
  (while(= 5(car(setq mouse(grread 't 13 0))))
    (redraw)(setq mouse(cadr mouse))
    (grvecs (list
	      4
	      (setq p1(list(min(car pt)(car mouse))(min(cadr pt)(cadr mouse))0))
	      (list(max(car pt)(car mouse))(min(cadr pt)(cadr mouse)))
	      4
	      (setq p2(list(max(car pt)(car mouse))(min(cadr pt)(cadr mouse))0))
	      (list(max(car pt)(car mouse))(max(cadr pt)(cadr mouse)))
	      4
	      (setq p3(list(max(car pt)(car mouse))(max(cadr pt)(cadr mouse))0))
	      (list(min(car pt)(car mouse))(max(cadr pt)(cadr mouse)))
	      4
	      (setq p4(list(min(car pt)(car mouse))(max(cadr pt)(cadr mouse))0))
	      (list(min(car pt)(car mouse))(min(cadr pt)(cadr mouse)))
	      )
	    )
    )
  (vla-addpolyline
    (vla-get-paperspace(vla-get-activedocument(vlax-get-acad-object)))
    (vlax-make-variant(vlax-safearray-fill(vlax-make-safearray vlax-vbdouble(cons 0(1-(length(apply 'Append(list p1 p2 p3 p4 p1))))))(apply 'Append(list p1 p2 p3 p4 p1))))
    )
  (command"revcloud" "a" "10.00" "10.00" "o" (entlast) "")
  (vlax-put(vlax-ename->vla-object(entlast))'Color 10)
  (vla-put-layer(vlax-ename->vla-object(entlast))lay)
  ;;;Bloco com Atributo
  (vla-insertblock(vla-get-paperspace(vla-get-activedocument(vlax-get-acad-object)))
    (vlax-3d-point(list(+(car p3)2)(+(cadr p3)2)))"S:\\Proj\\1014-01-MANABI\\CAD\\WORK AREA\\J\\Checklist\\revisao.dwg"1 1 1 0)
  (vla-put-textstring(setq xxx(nth 0(vlax-safearray->list(vlax-variant-value(vla-getattributes(vlax-ename->vla-object(entlast)))))))"3")
  (vla-update xxx)
  ;;;Bloco com Atributo
  (redraw)
  (command"undo""e")
  (setvar"cmdecho"1)
  (princ)
  )