(defun c:translateLayers ()
  (setq
    cad (vlax-get-acad-object)
    doc (vla-get-activedocument cad)
    MSpace (vla-get-modelspace doc)
    BLKDataBase (vla-get-blocks doc)
    LayerDataBase (vla-get-layers doc)
    Count(vla-get-count LayerDataBase)
    CountBLK(vla-get-count BLKDataBase)
  )
  ;;; |--- Config ---|
  (setq
    PREFIX ""
    SUFIX ""
    REMOVER ""
    SubsOLD "TL-"
    SubsNeo "EDG-"
  )
  ;;; |--------------|
  (while
    (> (setq Count(1- Count)) 0)
    (setq
      Layer(vla-item LayerDataBase Count)
      LayerName(vla-get-name Layer)
    )
    (if
      (= LayerName "0")
      (princ)
      (progn
        (setq
          LayerName(vl-string-subst "" REMOVER LayerName)
          LayerName(vl-string-subst SubsNeo SubsOLD LayerName)
          LayerName(strcat PREFIX LayerName)
          LayerName(strcat LayerName SUFIX)
        )
        (vla-put-name Layer LayerName)
       )
    )
  )
  ;;; |--------------|
  (while
    (> (setq CountBLK(1- CountBLK)) 0)
    (setq
      BLK(vla-item BLKDataBase CountBLK)
      BLKName(vla-get-name BLK)
    )
    (if
      (= LayerName "0")
      (princ)
      (progn
        (setq
          BLKName(vl-string-subst "" REMOVER BLKName)
          BLKName(vl-string-subst SubsNeo SubsOLD BLKName)
          BLKName(strcat PREFIX BLKName)
          BLKName(strcat BLKName SUFIX)
        )
        (vla-put-name BLK BLKName)
       )
    )
  )
  (princ)
)