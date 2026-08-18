(defun c:renlayers()

  (defun renLayer (LayerVlao pattern NewString)
    (if
      (= (type (vl-string-search pattern (vlax-get LayerVlao 'Name) ) ) 'INT)
      (progn
        (setq NewName (vl-string-subst NewString pattern (vlax-get LayerVlao 'Name) ) )
        (princ (strcat "\n" (vlax-get LayerVlao 'Name) " - " NewName "\n"))
        (vl-catch-all-apply 'vlax-put (list VlaoLayer 'Name NewName) )
      )
    )
  )
  
  (setq
    C3DReg (strcat "HKEY_LOCAL_MACHINE\\" (if vlax-user-product-key (vlax-user-product-key) (vlax-product-key)))
    C3DCode (vl-registry-read C3DReg "Release")
    VerString (substr C3DCode 1 (vl-string-search "." C3DCode (1+(vl-string-search "." C3DCode))))
    ProdutString (strcat "AeccXUiLand.AeccApplication." VerString)
    DataString (strcat "AeccXLand.AeccTinCreationData." VerString)
    C3D (vl-catch-all-apply 'vlax-invoke (list (vlax-get-acad-object) 'GetInterfaceObject ProdutString))
    C3Ddoc (vla-get-activedocument C3D)
    C3DMSpace (vla-get-modelspace C3Ddoc)
    LayerDataBase (vla-get-layers C3Ddoc )
    Total (vlax-get LayerDataBase 'Count)
    N -1
  )
  
  (while
    (< (setq N(1+ N)) Total)
    (princ ".")
    (setq
      VlaoLayer (vlax-invoke LayerDataBase 'Item N)
      NameLayer (vlax-get VlaoLayer 'Name)
    )
    ; --- Layers a Renomear /// TextoAntigo TextoNovo ---
    (renLayer VlaoLayer "-GE-" "-GER-")
    (renLayer VlaoLayer "-GG-" "-SGI-")
    (renLayer VlaoLayer "-TC-HM-" "-MDT-")
    (renLayer VlaoLayer "-TC-" "-MDT-")
    (renLayer VlaoLayer "-TR-" "-MDT-")
    (renLayer VlaoLayer "-GM-" "-GER-")
    (renLayer VlaoLayer "-SI-" "-GER-")
    (renLayer VlaoLayer "-DR-" "-DRE-")
    (renLayer VlaoLayer "-DS-" "-GER-")
    ; --- Fim da tradução ---
  )
  
  (princ)
  
)