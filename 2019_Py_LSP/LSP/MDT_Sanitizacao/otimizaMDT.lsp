(defun c:otimizaMDT (/ *error* cad doc MSpace C3DReg C3DCode VerString ProdutString C3D C3Ddoc C3DMSpace BlockDataBase oldCmdecho oldRegen)
  
  (vl-load-com)

  (defun LogReport(fileNew msg)
    (setq
      FileNameMem (if FileNameMem FileNameMem nil)
      FileNameMem (if fileNew nil FileNameMem)
    )
    (if 
      (= fileNew t)
      (setq
        LogFilePath(strcat(getvar 'dwgprefix)"LogReport("(vl-string-right-trim ".dwg" (getvar 'dwgname))")-"(vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) )".log")
        FileNameMem LogFilePath
      )
      (setq
        LogFilePath FileNameMem
      )
    )
    (setq LogFileOpened(open LogFilePath "a+"))
    (princ
      (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6) ) "]:> " (if msg msg "...") "\n" )
      LogFileOpened
    )
    (close LogFileOpened)
  )

  (defun *error* (msg)
    (if oldCmdecho (setvar 'cmdecho oldCmdecho))
    (if oldRegen (setvar 'regenmode oldRegen))
    (vla-endundomark doc)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (progn
        (princ (strcat "\nErro: " msg))
        (LogReport nil (strcat "Erro: " msg))
      )
        (LogReport nil (strcat "Cancelado..."))
    )
    (princ)
  )
  
  (defun DigitalTerrainModelCreator (BLK /
                                     polylineSetList BlockSpace DataString C3DSurfaces tinCreationData
                                     DataString C3DSurfaces tinCreationData OtimizedSurf BlockSpace
                                     )
    (LogReport nil (strcat "Iniciando MDT do Quadrante:" BLK))
    ; Start
    (setq
      BlockSpace
       (vla-item BlockDataBase BLK)
    )
    
    ; Selection Set
    (setq
      polylineSetList
       nil
    )
    
    (vlax-for item BlockSpace
      (if
        (and
          (=(vla-get-objectname item)"AcDbPolyline")
          (=(vla-get-layer item)"OtimizedContourn")
        )
        (progn
          (setq
            polylineSetList
             (vl-list*
               item
               polylineSetList
             )
          )
        )
      )
    )    
    ; Civil 3D Modelo Digital do Terreno
    (setq
      DataString
       (strcat "AeccXLand.AeccTinCreationData." VerString)
      C3DSurfaces
       (vlax-get C3Ddoc 'Surfaces)
      tinCreationData
       (vla-getinterfaceobject C3D DataString)
      Descricao
       (strcat "Automatizado via Lisp, Data[" (rtos (getvar 'Cdate) 2 6 ) "], Armazenado na pasta [" (getvar 'dwgprefix) "], Nome Original do Arquivo [" (getvar 'dwgname) "]" )
      SurfStyle
       nil
    )
    (vlax-for item (vlax-get C3Ddoc 'SurfaceStyles) (setq SurfStyle (vl-list* (vla-get-name item) SurfStyle) ))
    (if
      (member "_INVISÍVEL" SurfStyle)
      (setq SurfStyle "_INVISÍVEL")
      (if
        (member "BORDA" SurfStyle)
        (setq SurfStyle "BORDA")
        (setq SurfStyle (car(reverse SurfStyle)))
      )
    )
    ;
    (vlax-put tinCreationData 'BaseLayer "0")
    (vlax-put tinCreationData 'Layer "0")
    (vlax-put tinCreationData 'Description Descricao)
    (vlax-put tinCreationData 'Name (strcat "MDT-" (vl-string-subst "" ".dwg" (getvar 'dwgname)) "-" BLK) )
    (vlax-put tinCreationData 'Style SurfStyle )
    ;
    (setq
      OtimizedSurf
       (vlax-invoke-method
         C3DSurfaces
         'AddTinSurface
         tinCreationData
        )
    )
    ;(vlax-invoke (vlax-get OtimizedSurf 'Contours) 'Add polylineSetList "By Lisp" 0. 15. 1. 0.05)
    (setq MDTCreationReport(vl-catch-all-apply 'vlax-invoke (list(vlax-get OtimizedSurf 'Contours) 'Add polylineSetList "By Lisp" 0. 15. 1. 0.05)))
    (if
      (=(vl-catch-all-error-p MDTCreationReport)t)
      (progn
        (LogReport nil (vl-catch-all-error-message MDTCreationReport) )
        (vl-catch-all-apply 'vla-delete (list tinCreationData))
      )
    )
    ; Reset
    (vl-catch-all-apply 'vlax-release-object (list DataString))
    (vl-catch-all-apply 'vlax-release-object (list C3DSurfaces))
    (vl-catch-all-apply 'vlax-release-object (list tinCreationData))
    (vl-catch-all-apply 'vlax-release-object (list OtimizedSurf))
    (vl-catch-all-apply 'vlax-release-object (list BlockSpace))
    ;
    (LogReport nil (strcat "MDT Criada:" "[MDT-" (getvar 'dwgname) "-" BLK "]" ) )
    (princ)
  )
  
  (defun ContourDraw (BlockSpace CoordinateList Elevation / ContournPline safearrayData variantData)
    (if (>= (length CoordinateList) 4)
      (progn
        (setq CoordinateList (apply 'append (reverse CoordinateList)))
        (setq safearrayData (vlax-make-safearray vlax-vbdouble (cons 0 (1- (length CoordinateList)))))
        (vlax-safearray-fill safearrayData CoordinateList)
        (setq variantData (vlax-make-variant safearrayData))
        
        (setq ContournPline (vla-addlightweightpolyline BlockSpace variantData))
        (vla-put-elevation ContournPline Elevation)
        (vla-put-layer ContournPline "OtimizedContourn")
        
        (vlax-release-object ContournPline) ;; Libera memória do ponteiro criado
      )
    )
    (LogReport nil (strcat "Polylinha de Curva de Nivel criada..."))
  )
  
  (defun PolylineMDTCreation (BlockSpace SS LimMenorX LimMenorY LimMaiorX LimMaiorY / Vlao Count Elevation CoordinateList reg OutPoint item Point ptX ptY)
    (LogReport nil (strcat "Analizando grupo de Polylinhas..."))
    (foreach item (ssnamex SS)
      (if (>= (car item) 0)
        (progn
          (setq
            Vlao      (vlax-ename->vla-object (cadr item))
            Count     (/ (length (vlax-get Vlao 'Coordinates)) 2)
            Elevation (vla-get-elevation Vlao)
            CoordinateList nil
            reg       -1
          )
          (repeat Count
            ;; CORRIGIDO: Parênteses alinhados para englobar todas as variáveis do setq
            (setq
              Point    (vlax-safearray->list (vlax-variant-value (vlax-get-property Vlao 'Coordinate (setq reg (1+ reg)))))
              ptX      (car Point)
              ptY      (cadr Point)
              OutPoint nil
            )
            
            (if (and (>= ptX LimMenorX) (<= ptX LimMaiorX) (>= ptY LimMenorY) (<= ptY LimMaiorY))
              (setq CoordinateList (vl-list* Point CoordinateList))
              (setq OutPoint t)
            )
            
            (if OutPoint
              (progn
                (if CoordinateList 
                  (vl-catch-all-apply 'ContourDraw (list BlockSpace CoordinateList Elevation))
                )
                (setq CoordinateList nil)
              )
            )
          )
          
          (if CoordinateList
            (vl-catch-all-apply 'ContourDraw (list BlockSpace CoordinateList Elevation))
          )
          
          (vlax-release-object Vlao) ;; Libera a polilinha original analisada
        )
      )
    )
    (LogReport nil (strcat "Grupo de Polylinhas Analizadas..."))
  )
  
  (defun main (/ mdt layerList layerListSanitized layers XList YList DX DY QuadranteX QuadranteY 
                 item vlao boundBox point_A point_B XMin YMin XMax YMax XDelta YDelta DXCount DYCount 
                 XPoints YPoints QuadranteList BLKList XA YA XB YB BlockName PLinePoint CrossSelect 
                 CDNSelection BlockSpace LwPoly BLK DimQuadrante)
    
    (LogReport nil (strcat "Definições iniciais..."))
    
    (setq
      DimQuadrante  (getint "\nDigite o comprimento do quadrante <250>: ")
      DimQuadrante  (if DimQuadrante DimQuadrante 250.)
      DX            (fix DimQuadrante)
      DY            (fix DimQuadrante)
      mdt           (ssget "x" '((0 . "lwpolyline")))
      layerList     nil
      layers        ""
      BLKList       nil
    )
    
    (if mdt
      (progn
        (foreach item (ssnamex mdt)
          (if (>= (car item) 0)
            (progn
              (setq vlao (vlax-ename->vla-object (cadr item)))
              (vla-GetBoundingBox vlao 'point_A 'point_B)
              (setq
                XList (vl-list* (car (vlax-safearray->list point_A)) XList)
                XList (vl-list* (car (vlax-safearray->list point_B)) XList)
                YList (vl-list* (cadr (vlax-safearray->list point_A)) YList)
                YList (vl-list* (cadr (vlax-safearray->list point_B)) YList)
                layerList (vl-list* (vlax-get vlao 'Layer) layerList)
              )
              (vlax-release-object vlao)
            )
          )
        )
        
        (foreach item layerList
          (if (not (vl-string-search (strcat item ",") layers))
            (setq layers (strcat layers item ","))
          )
        )
        (setq layers (substr layers 1 (1- (strlen layers))))
        (setq mdt nil)
        
        (setq
          XMin (apply 'min XList)
          YMin (apply 'min YList)
          XMax (apply 'max XList)
          YMax (apply 'max YList)
          
          XMin (- XMin (rem XMin DX))
          YMin (- YMin (rem YMin DY))
          XMax (+ XMax (- DX (rem XMax DX)))
          YMax (+ YMax (- DY (rem YMax DY)))
          
          XDelta (- XMax XMin)
          YDelta (- YMax YMin)
          
          QuadranteX    -1
        )
        
        (setq
          DXCount (* DX -1)
          DYCount (* DY -1)
          XPoints nil
          YPoints nil
        )
        
        (repeat (fix (/ XDelta DX))
          (setq XPoints (vl-list* (+ (setq DXCount (+ DXCount DX)) XMin) XPoints))
        )
        (repeat (fix (/ YDelta DY))
          (setq YPoints (vl-list* (+ (setq DYCount (+ DYCount DY)) YMin) YPoints))
        )
        
        (setq XPoints (reverse XPoints)
              YPoints (reverse YPoints))
        
        (foreach XA XPoints
          (setq QuadranteX (1+ QuadranteX)
                QuadranteY -1)
          (foreach YA YPoints
            (setq
              QuadranteY (1+ QuadranteY)
              BlockName  (strcat "Q" (rtos QuadranteX 2 0) "-" (rtos QuadranteY 2 0))
              XB         (+ XA DX)
              YB         (+ YA DY)
              PLinePoint (list XA YA XB YA XB YB XA YB)
              CrossSelect (list (list XA YA) (list XB YA) (list XB YB) (list XA YB))
              CDNSelection (ssget "_CP" CrossSelect (list '(0 . "LWPolyline") (cons 8 layers)))
            )
            
            (LogReport nil (strcat "Iniciando o Quadrante: [" BlockName "]"))
            
            (if CDNSelection
              (progn
                (setq
                  BlockSpace (vla-add BlockDataBase (vlax-3d-point 0. 0. 0.) BlockName)
                  BLKList    (vl-list* BlockName BLKList)
                )
                ; Moldura
                (setq LwPoly (vla-addlightweightpolyline
                               BlockSpace
                               (vlax-make-variant
                                 (vlax-safearray-fill
                                   (vlax-make-safearray vlax-vbdouble (cons 0 (1- (length PLinePoint))))
                                   PLinePoint
                                 )
                               )
                             )
                )
                (vla-put-elevation LwPoly 0.0)
                (vla-put-closed LwPoly :vlax-true)
                ; Texto
                (setq
                  Texto
                   (vla-addtext
                     BlockSpace
                     BlockName
                     (vlax-3d-point (/(+ XA XB)2) (/(+ YA YB)2) 0)
                     (/ (/ (+ DX DY) 2) 10)
                    )
                )
                (vla-put-color Texto 2)
                (vla-put-alignment Texto acAlignmentMiddleCenter)
                (vla-put-textalignmentpoint Texto (vlax-3d-point (/(+ XA XB)2) (/(+ YA YB)2) 0))
                ;
                (setq BLK (vla-insertblock C3DMSpace (vlax-3d-point 0. 0. 0.) BlockName 1 1 1 0))
                
                (PolylineMDTCreation BlockSpace CDNSelection XA YA XB YB)
                
                (vlax-release-object Texto)
                (vlax-release-object LwPoly)
                (vlax-release-object BLK)
                (vlax-release-object BlockSpace)
                (LogReport nil (strcat "Finalizado o Quadrante: [" BlockName "]"))
              )
            )
            (gc) ;; Limpa resíduos de memória do interpretador por quadrante
          )
        )
        
        (LogReport nil (strcat "Iniciado processo geral de criação de MDT..."))
        
        (foreach item (reverse BLKList)
          (DigitalTerrainModelCreator item)
        )
        
        (LogReport nil (strcat "Finalizado processo geral de criação de MDT..."))
        
      )
    )
  )

  (LogReport t (strcat "Inicio do processo a " (rtos (getvar 'cdate) 2 6) ) )
  
  (setq
    cad            (vlax-get-acad-object)
    doc            (vla-get-activedocument cad)
    MSpace         (vla-get-modelspace doc)
    BlockDataBase  (vla-get-blocks doc)
    VlaoLayer      (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object ) ) ) "OtimizedContourn")
  )
  
  (vla-put-color VlaoLayer 1)
  
  (setq
    C3DReg         (strcat "HKEY_LOCAL_MACHINE\\" (if vlax-user-product-key (vlax-user-product-key) (vlax-product-key)))
    C3DCode        (vl-registry-read C3DReg "Release")
    VerString      (substr C3DCode 1 (vl-string-search "." C3DCode (1+ (vl-string-search "." C3DCode))))
    ProdutString   (strcat "AeccXUiLand.AeccApplication." VerString)
    C3D            (vl-catch-all-apply 'vlax-invoke (list cad 'GetInterfaceObject ProdutString))
  )
  
  (if (not (vl-catch-all-error-p C3D))
    (progn
      (setq C3Ddoc        (vla-get-activedocument C3D)
            C3DMSpace     (vla-get-modelspace C3Ddoc)
            oldCmdecho    (getvar 'cmdecho)
            oldRegen      (getvar 'regenmode))
      
      (vla-startundomark doc)
      (setvar 'cmdecho 0)
      (setvar 'regenmode 0)
      
      (main)
      
      (setvar 'cmdecho oldCmdecho)
      (setvar 'regenmode oldRegen)
      (vla-endundomark doc)
    )
    (progn
      (princ "\nErro: Não foi possível conectar ao Civil 3D.")
      (exit)
    )
  )
  
  (LogReport nil (strcat "Final do processo a " (rtos (getvar 'cdate) 2 6) ))
  (princ "\nOtimização Concluída!")
  (princ)
)