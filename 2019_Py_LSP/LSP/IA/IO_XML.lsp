; =========================================================================================
; INFORMAÇÕES
; Objetivo: Exportar e Importar entidades nativas e Blocos para/de formato XML via DXF[cite: 3]
; Data Inicial - 01/09/2026 - Elaborador Eric Drumond (ED Serviços & Projetos) - Gemini[cite: 3]
; Data Revisão / Número da Revisão: 03/09/2026 / Rev. 05
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [X] / Architeture [X] / ZWCAD [X] / BricsCAD [X][cite: 3]
; Referencia Externa: Não [ ] / AutoLisp [ ] / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ] / XML [X][cite: 3]
; DCL: Sim [ ] / Não [X][cite: 3]
; Observações: Aplicado o mapeamento e regras de prefixos nas subfunções (iedg:, ia:).
; Implementada recursividade para identificação e exportação de definições de Blocos (BLOCK)
; e seus sub-objetos aninhados, reconstruindo-os no entmake durante a importação.
; =========================================================================================

(vl-load-com) ;[cite: 3]

(defun c:IO_XML ( / iedg:*error* iedg:LogReport ia:EscapeXML ia:UnescapeXML ia:GetXmlAttr 
                    ia:GetTagValue ia:Val->Str ia:ParseStr ia:Dxf->Xml ia:ExportEntityAndSub 
                    ia:XmlGetAllBlocks ia:EnsureLayer ia:EnsureLinetype ia:EnsureTextStyle 
                    ia:ExportEntities ia:ImportEntities ia:Main 
                    acad doc MSpace old-cmdecho old-dimzin 
                    FileNameMem LogFilePath LogFileOpened ) ;[cite: 3]

  ;;; --------------------------------------> Tratamento de Erro & Log
  
  (defun iedg:*error* (msg) ;[cite: 2]
    (if doc (vla-endundomark doc)) ;[cite: 2]
    (if old-cmdecho (setvar 'cmdecho old-cmdecho))
    (if old-dimzin (setvar 'dimzin old-dimzin))
    (if (not (member msg '("Function cancelled" "quit / exit abort"))) ;[cite: 2]
      (progn
        (princ (strcat "\nErro: " msg)) ;[cite: 2]
        (iedg:LogReport t (strcat "ERR-" msg))
      )
    )
    (princ) ;[cite: 2]
  )

  (defun iedg:LogReport (fileNew msg) ;[cite: 2]
    (setq
      FileNameMem (if FileNameMem FileNameMem nil) ;[cite: 2]
      FileNameMem (if fileNew nil FileNameMem) ;[cite: 2]
    )
    (if 
      (= fileNew t) ;[cite: 2]
      (setq
        LogFilePath (strcat (getvar 'dwgprefix) "LogReport(" (vl-string-right-trim ".dwg" (getvar 'dwgname)) ")-" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) ".log") ;[cite: 2]
        FileNameMem LogFilePath ;[cite: 2]
      )
      (setq
        LogFilePath FileNameMem ;[cite: 2]
      )
    )
    (setq LogFileOpened (open LogFilePath "a+")) ;[cite: 2]
    (if LogFileOpened
      (progn
        (princ
          (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) "]:> " (if msg msg "...") "\n") ;[cite: 2]
          LogFileOpened ;[cite: 2]
        )
        (close LogFileOpened) ;[cite: 2]
      )
    )
  )

  ;;; --------------------------------------> SubFunções Auxiliares de Tratamento de Strings & XML

  (defun ia:EscapeXML (str / i char res)
    (setq res "" i 1)
    (while (<= i (strlen str))
      (setq char (substr str i 1))
      (cond
        ((= char "&") (setq res (strcat res "&amp;")))
        ((= char "<") (setq res (strcat res "&lt;")))
        ((= char ">") (setq res (strcat res "&gt;")))
        ((= char "\"") (setq res (strcat res "&quot;")))
        ((= char "'") (setq res (strcat res "&apos;")))
        (t (setq res (strcat res char)))
      )
      (setq i (1+ i))
    )
    res
  )

  (defun ia:UnescapeXML (str / res)
    (setq res str)
    (foreach pair '(("&amp;" . "&") ("&lt;" . "<") ("&gt;" . ">") ("&quot;" . "\"") ("&apos;" . "'"))
      (while (vl-string-search (car pair) res)
        (setq res (vl-string-subst (cdr pair) (car pair) res))
      )
    )
    res
  )

  (defun ia:GetXmlAttr (attr line / pStart pEnd)
    (setq pStart (vl-string-search (strcat attr "=\"") line))
    (if pStart
      (progn
        (setq pStart (+ pStart (strlen attr) 2))
        (setq pEnd (vl-string-search "\"" line pStart))
        (if pEnd (substr line (1+ pStart) (- pEnd pStart)))
      )
    )
  )

  (defun ia:GetTagValue (tag line / pStart pEnd len)
    (setq pStart (vl-string-search (strcat "<" tag) line))
    (if pStart
      (progn
        (setq pStart (vl-string-search ">" line pStart))
        (if pStart
          (progn
            (setq pStart (1+ pStart))
            (setq pEnd (vl-string-search (strcat "</" tag ">") line pStart))
            (if pEnd
              (progn
                (setq len (- pEnd pStart))
                (if (> len 0) (substr line (1+ pStart) len) "")
              )
            )
          )
        )
      )
    )
  )

  (defun ia:Val->Str (val / lstStr v) 
    (cond
      ((= (type val) 'STR) val)
      ((= (type val) 'INT) (itoa val))
      ((= (type val) 'REAL) (rtos val 2 8)) ;[cite: 2]
      ((= (type val) 'LIST)
       (setq lstStr "")
       (foreach v val
         (setq lstStr (strcat lstStr " " (if (numberp v) (rtos (float v) 2 8) (vl-prin1-to-string v)))) ;[cite: 2]
       )
       (vl-string-trim " " lstStr)
      )
      (t (vl-prin1-to-string val))
    )
  )

  (defun ia:ParseStr (str vType / readVal)
    (cond
      ((= vType "STR") (ia:UnescapeXML str))
      ((= vType "INT") (atoi str))
      ((= vType "REAL") (atof (vl-string-translate "," "." str)))
      ((= vType "LIST")
       (setq readVal (read (strcat "(" str ")")))
       (if (listp readVal)
         (mapcar '(lambda (v) (if (numberp v) (float v) 0.0)) readVal)
         (list 0.0 0.0 0.0)
       )
      )
      (t (ia:UnescapeXML str))
    )
  )

  ;;; --------------------------------------> SubFunções de Serialização e Parser

  (defun ia:Dxf->Xml (ename / elist xmlLines code val tag vType)
    (setq elist (entget ename '("*")))
    (setq xmlLines (list "  <ENTITY>"))
    (foreach pair elist
      (setq code (car pair))
      (setq val (cdr pair))
      (if (not (member code '(-1 -2 -3 5 330 360 340 390 410)))
        (progn
          (setq vType (vl-symbol-name (type val)))
          (setq tag (strcat "    <DXF code=\"" (itoa code) "\" type=\"" vType "\">" (ia:EscapeXML (ia:Val->Str val)) "</DXF>"))
          (setq xmlLines (cons tag xmlLines))
        )
      )
    )
    (setq xmlLines (cons "  </ENTITY>" xmlLines))
    (reverse xmlLines)
  )

  (defun ia:ExportEntityAndSub (ename / lines elist entSub)
    (setq lines (ia:Dxf->Xml ename))
    (setq elist (entget ename))
    (if (= (cdr (assoc 66 elist)) 1)
      (progn
        (setq entSub (entnext ename))
        (while (and entSub (/= (cdr (assoc 0 (entget entSub))) "SEQEND"))
          (setq lines (append lines (ia:Dxf->Xml entSub)))
          (setq entSub (entnext entSub))
        )
        (if entSub
          (setq lines (append lines (ia:Dxf->Xml entSub)))
        )
      )
    )
    lines
  )

  (defun ia:XmlGetAllBlocks (filePath / fp line inEntity entityList currentEntity codeStr typeStr valStr)
    (setq entityList nil currentEntity nil inEntity nil)
    (if (setq fp (open filePath "r"))
      (progn
        (while (setq line (read-line fp))
          (setq line (vl-string-trim " \t\r\n" line))
          (cond
            ((vl-string-search "<ENTITY>" line)
             (setq inEntity t currentEntity nil)
            )
            ((vl-string-search "</ENTITY>" line)
             (if currentEntity
               (setq entityList (cons (reverse currentEntity) entityList))
             )
             (setq inEntity nil currentEntity nil)
            )
            ((and inEntity (vl-string-search "<DXF" line))
             (setq codeStr (ia:GetXmlAttr "code" line))
             (setq typeStr (ia:GetXmlAttr "type" line))
             (setq valStr (ia:GetTagValue "DXF" line))
             (if (and codeStr typeStr valStr)
               (setq currentEntity (cons (cons (atoi codeStr) (ia:ParseStr valStr typeStr)) currentEntity))
             )
            )
          )
        )
        (close fp)
      )
    )
    (reverse entityList)
  )

  ;;; --------------------------------------> SubFunções de Sanitização

  (defun ia:EnsureLayer (layerName / )
    (if (not (tblsearch "LAYER" layerName))
      (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                     (cons 2 layerName) '(70 . 0) '(62 . 7) '(6 . "Continuous")))
    )
  )

  (defun ia:EnsureLinetype (dxfList / lt)
    (setq lt (cdr (assoc 6 dxfList)))
    (if (and lt (not (tblsearch "LTYPE" lt)))
      (vl-remove-if '(lambda (x) (= (car x) 6)) dxfList)
      dxfList
    )
  )

  (defun ia:EnsureTextStyle (dxfList / st)
    (setq st (cdr (assoc 7 dxfList)))
    (if (and st (not (tblsearch "STYLE" st)))
      (vl-remove-if '(lambda (x) (= (car x) 7)) dxfList)
      dxfList
    )
  )

  ;;; --------------------------------------> SubFunções de Exportação e Importação

  (defun ia:ExportEntities ( / ss i ename fp fPath total lines l blockNamesList exportedBlocksList blockXmlLines ia:ProcessBlock )
    (princ "\nSelecione os objetos para exportar para XML: ")
    (if (setq ss (ssget))
      (progn
        (setq fPath (getfiled "Salvar Arquivo XML" (strcat (getvar 'dwgprefix) "Desenho_Export.xml") "xml" 1))
        (if fPath
          (progn
            (if (setq fp (open fPath "w"))
              (progn
                (write-line "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" fp)
                (write-line "<AUTOCAD_DRAWING>" fp)
                (write-line " <ENTITIES>" fp)
                
                ;; 1. Mapear todas as instâncias de blocos (INSERT) selecionados
                (setq total (sslength ss) i 0 blockNamesList nil)
                (while (< i total)
                  (setq ename (ssname ss i))
                  (if (= (cdr (assoc 0 (entget ename))) "INSERT")
                    (setq blockNamesList (cons (cdr (assoc 2 (entget ename))) blockNamesList))
                  )
                  (setq i (1+ i))
                )
                
                ;; 2. Função Recursiva para processar a Definição de Blocos e Sub-Blocos
                (setq exportedBlocksList nil blockXmlLines nil)
                (defun ia:ProcessBlock (bName / bEnt subEnt bList)
                  (if (and bName (not (member bName exportedBlocksList)))
                    (progn
                      (setq exportedBlocksList (cons bName exportedBlocksList))
                      (setq bEnt (tblobjname "BLOCK" bName))
                      (if bEnt
                        (progn
                          ;; Rastreia e processa blocos aninhados primeiro
                          (setq subEnt (entnext bEnt))
                          (while subEnt
                            (setq bList (entget subEnt))
                            (if (= (cdr (assoc 0 bList)) "INSERT")
                              (ia:ProcessBlock (cdr (assoc 2 bList)))
                            )
                            (setq subEnt (entnext subEnt))
                          )
                          ;; Serializa o Header do Bloco (0 . "BLOCK")
                          (setq blockXmlLines (append blockXmlLines (ia:Dxf->Xml bEnt)))
                          ;; Serializa todas as entidades internas
                          (setq subEnt (entnext bEnt))
                          (while subEnt
                            (setq blockXmlLines (append blockXmlLines (ia:ExportEntityAndSub subEnt)))
                            (setq subEnt (entnext subEnt))
                          )
                          ;; Finaliza o Bloco com (0 . "ENDBLK")
                          (setq blockXmlLines (append blockXmlLines (list "  <ENTITY>" "    <DXF code=\"0\" type=\"STR\">ENDBLK</DXF>" "    <DXF code=\"8\" type=\"STR\">0</DXF>" "  </ENTITY>")))
                        )
                      )
                    )
                  )
                )
                
                ;; Processa as Definições de Blocos (Eles devem ser declarados ANTES das entidades principais no XML)
                (foreach b blockNamesList (ia:ProcessBlock b))
                (foreach l blockXmlLines (write-line l fp))
                
                ;; 3. Exporta as Entidades Principais Selecionadas
                (setq i 0)
                (while (< i total)
                  (setq ename (ssname ss i))
                  (setq lines (ia:ExportEntityAndSub ename))
                  (foreach l lines (write-line l fp))
                  (setq i (1+ i))
                )
                
                (write-line " </ENTITIES>" fp)
                (write-line "</AUTOCAD_DRAWING>" fp)
                (close fp)
                (princ (strcat "\n[SUCESSO] " (itoa total) " entidades e seus blocos exportados para: " fPath))
              )
              (princ "\n[ERRO] Não foi possível abrir o arquivo para gravação.")
            )
          )
        )
      )
      (princ "\nNenhum objeto selecionado.")
    )
  )

  (defun ia:ImportEntities ( / fPath entities created count dxfList entRes lay entType vtx idx tot bName skipBlock )
    (setq fPath (getfiled "Selecionar Arquivo XML para Importar" (getvar 'dwgprefix) "xml" 0))
    (if (and fPath (findfile fPath))
      (progn
        (setq entities (ia:XmlGetAllBlocks fPath))
        (setq count 0 created 0 idx 0 tot (length entities))
        
        (while (< idx tot)
          (setq dxfList (nth idx entities))
          (setq entType (cdr (assoc 0 dxfList)))
          
          (setq lay (cdr (assoc 8 dxfList)))
          (if lay (ia:EnsureLayer lay))
          (setq dxfList (ia:EnsureLinetype dxfList))
          (setq dxfList (ia:EnsureTextStyle dxfList))
          
          (cond
            ;; 1º - Processamento de Header de BLOCOS (BLOCK)
            ((= entType "BLOCK")
             (setq bName (cdr (assoc 2 dxfList)))
             (if (tblsearch "BLOCK" bName)
               (progn
                 ;; Proteção: Se o bloco já existe no desenho, ignoramos a re-criação iterando até achar ENDBLK
                 (setq skipBlock t)
                 (while (and (< idx tot) skipBlock)
                   (setq idx (1+ idx))
                   (if (or (>= idx tot) (= (cdr (assoc 0 (nth idx entities))) "ENDBLK"))
                     (setq skipBlock nil)
                   )
                 )
               )
               (progn
                 (setq entRes (entmake dxfList))
                 (if entRes (setq created (1+ created)))
               )
             )
            )
            
            ;; 2º - Processamento de Encerramento de BLOCOS (ENDBLK)
            ((= entType "ENDBLK")
             (setq entRes (entmake '((0 . "ENDBLK") (8 . "0"))))
             (if entRes (setq created (1+ created)))
            )
            
            ;; 3º - Procedimento Especial: Polyline 3D e seus Vértices
            ((and (= entType "POLYLINE") (= (cdr (assoc 70 dxfList)) 8))
             (entmake '((0 . "POLYLINE") (70 . 8)))
             (setq idx (1+ idx))
             
             (while (and (< idx tot) (= (cdr (assoc 0 (nth idx entities))) "VERTEX"))
               (setq vtx (nth idx entities))
               (entmake (list '(0 . "VERTEX") (cons 10 (cdr (assoc 10 vtx))) '(70 . 32)))
               (setq idx (1+ idx))
             )
             
             (if (and (< idx tot) (= (cdr (assoc 0 (nth idx entities))) "SEQEND"))
               (progn
                 (entmake '((0 . "SEQEND")))
                 (setq idx (1+ idx))
               )
             )
             (setq idx (1- idx))
             (setq created (1+ created))
            )
            
            ;; 4º - Criação Padrão de Entidade ou Sub-Entidades (LINE, ARC, INSERT, TEXT, etc)
            (t
             (setq entRes (entmake dxfList))
             (if entRes
               (setq created (1+ created))
               (iedg:LogReport t (strcat "Falha entmake: " (vl-prin1-to-string dxfList)))
             )
            )
          )
          
          (setq count (1+ count))
          (setq idx (1+ idx))
        )
        (princ (strcat "\n[SUCESSO] Processamento concluído: " (itoa created) " seções DXF recriadas."))
      )
      (princ "\nArquivo não selecionado ou inexistente.")
    )
  )

  ;;; --------------------------------------> Main

  (defun ia:Main ( / opt )[cite: 3]
    (initget "Exportar Importar")
    (setq opt (getkword "\nEscolha uma opção [Exportar / Importar] <Exportar>: "))
    (if (or (null opt) (= opt "") (= opt "Exportar"))
      (ia:ExportEntities)
      (ia:ImportEntities)
    )
  )

  ;;; --------------------------------------> Definições Iniciais e Execução
  
  (setq
    acad (vlax-get-acad-object) ;[cite: 2]
    doc (vla-get-activedocument acad) ;[cite: 2]
    MSpace (vla-get-modelspace doc) ;[cite: 2]
    old-cmdecho (getvar 'cmdecho)
    old-dimzin (getvar 'dimzin) ;[cite: 2]
  )
  
  (vla-startundomark doc) ;[cite: 3]
  (setvar 'cmdecho 0) ;[cite: 2]
  (setvar 'dimzin 0)  ;[cite: 2]
  
  (ia:Main) ;[cite: 3]
  
  (setvar 'cmdecho old-cmdecho) ;[cite: 2]
  (setvar 'dimzin old-dimzin)   ;[cite: 2]
  (vla-endundomark doc) ;[cite: 3]
  (princ) ;[cite: 3]
)

;; Alias simplificados para acesso direto via prompt de comando
(defun c:EXPORTXML () (c:IO_XML))
(defun c:IMPORTXML () (c:IO_XML))

(princ "\n[Carregado com sucesso] Comandos disponíveis: IO_XML, EXPORTXML, IMPORTXML\n")
(princ) ;[cite: 3]