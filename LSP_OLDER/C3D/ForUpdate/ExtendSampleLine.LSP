(defun c:ExSample()
  (command"undo""be")
  (setq
    sample(entsel"\nSampleLine :")
    vsample(vlax-ename->vla-object(car sample))
    p1 (vlax-get (vlax-invoke (vlax-get vsample 'Vertices) 'Item 0) 'Location)
    p2 (vlax-get (vlax-invoke (vlax-get vsample 'Vertices) 'Item 1) 'Location)
    ang (angle p1 p2)
    dist (distance p1 p2)
    pMid (polar p1 ang (/ dist 2))
    point(getpoint pMid "\tPonto da direção a extender : ")
    d1 (distance p1 point)
    d2 (distance point p2)
    d1X (distance pMid point)
    d2X (distance point pMid)
    )

  (if (< d1 d2)
    (progn
      (setq
	pEx (polar pMid ang (*(abs d1X)-1))
	)
      (vlax-put (vlax-invoke (vlax-get vsample 'Vertices) 'Item 0) 'Location pEx)
      )
    (progn
      (setq
	pEx (polar pMid ang (abs d2X))
	)
      (vlax-put (vlax-invoke (vlax-get vsample 'Vertices) 'Item 1) 'Location pEx)
      )
    )
  (command"undo""e")
  (princ)
  )