; =========================================================================================
; INFORMAÇÕES
; Objetivo: Exportar e Importar entidades nativas e Blocos para/de formato JSON via DXF[cite: 1].
; Data Inicial - Elaborador Eric Drumond (ED Serviços & Projetos) - Gemini IA
; Data Revisão / Número da Revisão: 01
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [X] / Architeture [X] / ZWCAD [X] / BricsCAD [X]
; Referencia Externa: Não [ ] / AutoLisp [ ] / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ] / JSON [X]
; DCL: Sim [ ] / Não [X]
; Limitações: ZWCAD/IntelliCAD são totalmente suportados pois usam chamadas nativas LISP entget/entmake, sem ActiveX complexo[cite: 2].
; Observações: O erro de leitura de chaves DXF (onde o grupo 100 se transformava em 10) foi corrigido
; através do recálculo de offset de strings na função ia:ParseJsonDxfLine.
; =========================================================================================

(vl-load-com) ;[cite: 2]

(defun c:IO_JSON ( / iedg:*error* iedg:LogReport ia:EscapeJSON ia:UnescapeJSON ia:ParseJsonDxfLine 
                     ia:Val->Str ia:ParseStr ia:Dxf->Json ia:ExportEntityAndSub ia:JsonGetAllEntities 
                     ia:EnsureLayer ia:EnsureLinetype ia:EnsureTextStyle ia:ExportEntities 
                     ia:ImportEntities ia:Main acad doc MSpace old-cmdecho old-dimzin 
                     FileNameMem LogFilePath LogFileOpened ) ;[cite: 2]

  ;;; --------------------------------------> Tratamento de Erro & Log
  
  ; Sub-Função 1.0 - Captura de erros customizada
  (defun iedg:*error* (msg) ;[cite: 3]
    (if doc (vla-endundomark doc))
    (if old-cmdecho (setvar 'cmdecho old-cmdecho))
    (if old-dimzin (setvar 'dimzin old-dimzin))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (progn
        (princ (strcat "\nErro: " msg))
        (iedg:LogReport t (strcat "ERR-" msg))
      )
    )
    (princ)
  )

  ; Sub-Função 1.1 - Registro de Logs no diretório
  (defun iedg:LogReport (fileNew msg) ;[cite: 3]
    (setq
      FileNameMem (if FileNameMem FileNameMem nil)
      FileNameMem (if fileNew nil FileNameMem)
    )
    (if 
      (= fileNew t)
      (setq
        LogFilePath (strcat (getvar 'dwgprefix) "LogReport(" (vl-string-right-trim ".dwg" (getvar 'dwgname)) ")-" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) ".log")
        FileNameMem LogFilePath
      )
      (setq LogFilePath (if FileNameMem FileNameMem (strcat (vl-filename-mktemp "" "" "") "LogReport-" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) ".log")))
    )
    (setq LogFileOpened (open LogFilePath "a+"))
    (if LogFileOpened
      (progn
        (princ (strcat "Log[" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) "]:> " (if msg msg "...") "\n") LogFileOpened)
        (close LogFileOpened)
      )
    )
  )

  ;;; --------------------------------------> Tratamento de Strings & JSON

  ; Sub-Função 2.0 - Adiciona escapes para formatação JSON válida
  (defun ia:EscapeJSON (str / i char res)
    (setq res "" i 1)
    ; Loop 2.0.1 - Escaneamento de caracteres
    (while (<= i (strlen str))
      (setq char (substr str i 1))
      (cond
        ((= char "\\") (setq res (strcat res "\\\\")))
        ((= char "\"") (setq res (strcat res "\\\"")))
        ((= char "\n") (setq res (strcat res "\\n")))
        ((= char "\r") (setq res (strcat res "\\r")))
        ((= char "\t") (setq res (strcat res "\\t")))
        (t (setq res (strcat res char)))
      )
      (setq i (1+ i))
    )
    res
  )

  ; Sub-Função 2.1 - Remove escapes ao trazer de volta para LISP
  (defun ia:UnescapeJSON (str / res pair)
    (setq res str)
    ; Loop 2.1.1 - Reversão de string
    (foreach pair '(("\\\\" . "\\") ("\\\"" . "\"") ("\\n" . "\n") ("\\r" . "\r") ("\\t" . "\t"))
      (while (vl-string-search (car pair) res)
        (setq res (vl-string-subst (cdr pair) (car pair) res))
      )
    )
    res
  )

  ; Sub-Função 3.0 - Val->Str: Converte tipos LISP para String
  (defun ia:Val->Str (val / lstStr v) ;[cite: 1]
    (cond
      ((= (type val) 'STR) val)
      ((= (type val) 'INT) (itoa val))
      ((= (type val) 'REAL) (rtos val 2 8))
      ((= (type val) 'LIST)
       (setq lstStr "")
       ; Loop 3.0.1 - Tratamento de Coordenadas
       (foreach v val
         (setq lstStr (strcat lstStr " " (if (numberp v) (rtos (float v) 2 8) (vl-prin1-to-string v))))
       )
       (vl-string-trim " " lstStr)
      )
      (t (vl-prin1-to-string val))
    )
  )

  ; Sub-Função 3.1 - Converte String textual para o tipo LISP correspondente
  (defun ia:ParseStr (str vType / readVal) ;[cite: 1]
    (cond
      ((= vType "STR") str)
      ((= vType "INT") (atoi str))
      ((= vType "REAL") (atof (vl-string-translate "," "." str)))
      ((= vType "LIST")
       (setq readVal (read (strcat "(" str ")")))
       (if (listp readVal)
         (mapcar '(lambda (v) (if (numberp v) (float v) 0.0)) readVal)
         (list 0.0 0.0 0.0)
       )
      )
      (t str)
    )
  )

  ;;; --------------------------------------> Serialização e Parser JSON

  ; Sub-Função 4.0 - CORRIGIDA: Extrai chaves e valores com offsets absolutos precisos.
  (defun ia:ParseJsonDxfLine (line / cPos tPos vPos cStr tStr vStr)
    (setq cPos (vl-string-search "\"c\":" line))
    (if cPos
      (progn
        (setq tPos (vl-string-search ",\"t\":\"" line cPos))
        (if tPos
          (progn
            (setq vPos (vl-string-search "\",\"v\":\"" line tPos))
            (if vPos
              (progn
                ; Correção de Índices Matemáticos em Substr (Offsets corrigidos)
                (setq cStr (substr line (+ cPos 5) (- tPos (+ cPos 4))))
                (setq tStr (substr line (+ tPos 7) (- vPos (+ tPos 6))))
                
                ; A partir de vPos, o valor inicia exatamente 8 posições à frente
                (setq vStr (substr line (+ vPos 8)))
                
                ; Limpeza final das aspas de fechamento e vírgula, sem usar offset hardcoded quebrado
                (if (= (substr vStr (strlen vStr) 1) ",")
                  (setq vStr (substr vStr 1 (- (strlen vStr) 3))) ; Limpa `"},`
                  (setq vStr (substr vStr 1 (- (strlen vStr) 2))) ; Limpa `"}`
                )
                
                (list cStr tStr (ia:UnescapeJSON vStr))
              )
            )
          )
        )
      )
    )
  )

  ; Sub-Função 5.0 - Dxf->Json: Converte as Entidades LISP em Arrays JSON
  (defun ia:Dxf->Json (ename / elist jsonLines code val vType valStr tag pairs i tot) ;[cite: 1]
    (setq elist (entget ename '("*")) pairs nil)
    ; Loop 5.0.1 - Itera pares DXF
    (foreach pair elist
      (setq code (car pair) val (cdr pair))
      (if (not (member code '(-1 -2 -3 5 330 360 340 390 410)))
        (progn
          (setq vType (vl-symbol-name (type val)))
          (setq valStr (ia:EscapeJSON (ia:Val->Str val)))
          (setq tag (strcat "        {\"c\":" (itoa code) ",\"t\":\"" vType "\",\"v\":\"" valStr "\"}"))
          (setq pairs (cons tag pairs))
        )
      )
    )
    (setq pairs (reverse pairs) jsonLines (list "      [") i 0 tot (length pairs))
    ; Loop 5.0.2 - Aplica a formatação e vírgulas finais da notação JSON
    (foreach tag pairs
      (if (< i (1- tot))
        (setq jsonLines (cons (strcat tag ",") jsonLines))
        (setq jsonLines (cons tag jsonLines))
      )
      (setq i (1+ i))
    )
    (setq jsonLines (cons "      ]" jsonLines))
    (reverse jsonLines)
  )

  ; Sub-Função 6.0 - Processa entidade e sub-entidades encadeadas (Vertices)
  (defun ia:ExportEntityAndSub (ename fp firstEnt / elist entSub lines l) ;[cite: 1]
    (if (not firstEnt) (write-line "      ," fp))
    (foreach l (ia:Dxf->Json ename) (write-line l fp))
    
    (setq elist (entget ename))
    (if (= (cdr (assoc 66 elist)) 1)
      (progn
        (setq entSub (entnext ename))
        ; Loop 6.0.1 - Adiciona Vertices Polylines/Blocos à pilha JSON
        (while (and entSub (/= (cdr (assoc 0 (entget entSub))) "SEQEND"))
          (write-line "      ," fp)
          (foreach l (ia:Dxf->Json entSub) (write-line l fp))
          (setq entSub (entnext entSub))
        )
        (if entSub
          (progn
            (write-line "      ," fp)
            (foreach l (ia:Dxf->Json entSub) (write-line l fp))
          )
        )
      )
    )
  )

  ; Sub-Função 7.0 - Lê e Agrupa todo o JSON num grande Dicionário (Lista de Associação)
  (defun ia:JsonGetAllEntities (filePath / fp line inEntity entityList currentEntity parsedPair codeStr typeStr valStr) ;[cite: 1]
    (setq entityList nil currentEntity nil inEntity nil)
    (if (setq fp (open filePath "r"))
      (progn
        ; Loop 7.0.1 - Varre as linhas extraindo propriedades
        (while (setq line (read-line fp))
          (setq line (vl-string-trim " \t\r\n" line))
          (cond
            ((= line "[") (setq inEntity t currentEntity nil))
            ((or (= line "]") (= line "],"))
             (if (and inEntity currentEntity)
               (setq entityList (cons (reverse currentEntity) entityList))
             )
             (setq inEntity nil currentEntity nil)
            )
            ((and inEntity (vl-string-search "{\"c\":" line))
             (setq parsedPair (ia:ParseJsonDxfLine line))
             (if parsedPair
               (progn
                 (setq codeStr (car parsedPair) typeStr (cadr parsedPair) valStr (caddr parsedPair))
                 (setq currentEntity (cons (cons (atoi codeStr) (ia:ParseStr valStr typeStr)) currentEntity))
               )
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

  ;;; --------------------------------------> Exportação e Importação

  ; Sub-Função 8.0 - Gestor de Exportação JSON
  (defun ia:ExportEntities ( / ss i ename fp fPath total blockNamesList exportedBlocksList isFirstGlobal ia:ProcessBlock ) ;[cite: 1]
    (princ "\nSelecione os objetos para exportar para JSON: ")
    (if (setq ss (ssget))
      (progn
        (setq fPath (getfiled "Salvar Arquivo JSON" (strcat (getvar 'dwgprefix) "Desenho_Export.json") "json" 1))
        (if fPath
          (progn
            (if (setq fp (open fPath "w"))
              (progn
                (write-line "{" fp)
                (write-line "  \"AUTOCAD_DRAWING\": {" fp)
                (write-line "    \"ENTITIES\": [" fp)
                
                (setq total (sslength ss) i 0 blockNamesList nil)
                ; Loop 8.0.1 - Busca identificadores de INSERT (Blocos)
                (while (< i total)
                  (setq ename (ssname ss i))
                  (if (= (cdr (assoc 0 (entget ename))) "INSERT")
                    (setq blockNamesList (cons (cdr (assoc 2 (entget ename))) blockNamesList))
                  )
                  (setq i (1+ i))
                )
                
                (setq exportedBlocksList nil isFirstGlobal t)
                
                ; Sub-Função 8.1 - Processa hierarquia de Blocos recursivamente[cite: 1]
                (defun ia:ProcessBlock (bName / bEnt subEnt bList l)
                  (if (and bName (not (member bName exportedBlocksList)))
                    (progn
                      (setq exportedBlocksList (cons bName exportedBlocksList))
                      (setq bEnt (tblobjname "BLOCK" bName))
                      (if bEnt
                        (progn
                          (setq subEnt (entnext bEnt))
                          ; Loop 8.1.1 - Recursão em SubBlocos (aninhamento)
                          (while subEnt
                            (setq bList (entget subEnt))
                            (if (= (cdr (assoc 0 bList)) "INSERT") (ia:ProcessBlock (cdr (assoc 2 bList))))
                            (setq subEnt (entnext subEnt))
                          )
                          
                          (if (not isFirstGlobal) (write-line "      ," fp))
                          (foreach l (ia:Dxf->Json bEnt) (write-line l fp))
                          (setq isFirstGlobal nil)
                          
                          (setq subEnt (entnext bEnt))
                          ; Loop 8.1.2 - Entidades internas
                          (while subEnt
                            (ia:ExportEntityAndSub subEnt fp nil)
                            (setq subEnt (entnext subEnt))
                          )
                          ; Finalização das Definições do Bloco
                          (write-line "      ," fp)
                          (write-line "      [" fp)
                          (write-line "        {\"c\":0,\"t\":\"STR\",\"v\":\"ENDBLK\"}," fp)
                          (write-line "        {\"c\":8,\"t\":\"STR\",\"v\":\"0\"}" fp)
                          (write-line "      ]" fp)
                        )
                      )
                    )
                  )
                )
                
                (foreach b blockNamesList (ia:ProcessBlock b))
                
                ; Loop 8.0.2 - Gravação principal das entidades desenhadas (ModelSpace)
                (setq i 0)
                (while (< i total)
                  (setq ename (ssname ss i))
                  (ia:ExportEntityAndSub ename fp isFirstGlobal)
                  (setq isFirstGlobal nil i (1+ i))
                )
                
                (write-line "    ]" fp)
                (write-line "  }" fp)
                (write-line "}" fp)
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

  ; Sub-Função 9.0 - Gestor de Importação
  (defun ia:ImportEntities ( / fPath entities created count dxfList entRes lay entType vtx idx tot bName skipBlock ) ;[cite: 1]
    (setq fPath (getfiled "Selecionar Arquivo JSON para Importar" (getvar 'dwgprefix) "json" 0))
    (if (and fPath (findfile fPath))
      (progn
        (setq entities (ia:JsonGetAllEntities fPath))
        (setq count 0 created 0 idx 0 tot (length entities))
        
        ; Loop 9.0.1 - Recria Entidades Lidas iterativamente
        (while (< idx tot)
          (setq dxfList (nth idx entities) entType (cdr (assoc 0 dxfList)))
          
          (setq lay (cdr (assoc 8 dxfList)))
          (if lay (ia:EnsureLayer lay))
          (setq dxfList (ia:EnsureLinetype dxfList) dxfList (ia:EnsureTextStyle dxfList))
          
          (cond
            ((= entType "BLOCK")
             (setq bName (cdr (assoc 2 dxfList)))
             (if (tblsearch "BLOCK" bName)
               (progn
                 (setq skipBlock t)
                 (while (and (< idx tot) skipBlock)
                   (setq idx (1+ idx))
                   (if (or (>= idx tot) (= (cdr (assoc 0 (nth idx entities))) "ENDBLK"))
                     (setq skipBlock nil)
                   )
                 )
               )
               (progn (setq entRes (entmake dxfList)) (if entRes (setq created (1+ created))))
             )
            )
            ((= entType "ENDBLK")
             (setq entRes (entmake '((0 . "ENDBLK") (8 . "0"))))
             (if entRes (setq created (1+ created)))
            )
            ((and (= entType "POLYLINE") (= (cdr (assoc 70 dxfList)) 8))
             (entmake '((0 . "POLYLINE") (70 . 8)))
             (setq idx (1+ idx))
             (while (and (< idx tot) (= (cdr (assoc 0 (nth idx entities))) "VERTEX"))
               (setq vtx (nth idx entities))
               (entmake (list '(0 . "VERTEX") (cons 10 (cdr (assoc 10 vtx))) '(70 . 32)))
               (setq idx (1+ idx))
             )
             (if (and (< idx tot) (= (cdr (assoc 0 (nth idx entities))) "SEQEND"))
               (progn (entmake '((0 . "SEQEND"))) (setq idx (1+ idx)))
             )
             (setq idx (1- idx) created (1+ created))
            )
            (t
             ; Com o offset do ia:ParseJsonDxfLine corrigido, o entmake roda livremente agora
             (setq entRes (vl-catch-all-apply 'entmake (list dxfList)))
             (if (vl-catch-all-error-p entRes)
               (iedg:LogReport t (strcat "Falha entmake JSON: " (vl-prin1-to-string dxfList)))
               (setq created (1+ created))
             )
            )
          )
          (setq count (1+ count) idx (1+ idx))
        )
        (princ (strcat "\n[SUCESSO] Processamento concluído: " (itoa created) " seções DXF recriadas."))
      )
      (princ "\nArquivo não selecionado ou inexistente.")
    )
  )

  ;;; --------------------------------------> Main

  (defun ia:Main ( / opt )
    (initget "Exportar Importar")
    (setq opt (getkword "\nEscolha uma opção [Exportar / Importar] <Exportar>: "))
    (if (or (null opt) (= opt "") (= opt "Exportar"))
      (ia:ExportEntities)
      (ia:ImportEntities)
    )
  )

  ;;; --------------------------------------> Definições Iniciais e Execução
  
  (setq
    acad (vlax-get-acad-object)
    doc (vla-get-activedocument acad)
    MSpace (vla-get-modelspace doc)
    old-cmdecho (getvar 'cmdecho)
    old-dimzin (getvar 'dimzin)
  )
  
  (vla-startundomark doc)
  (setvar 'cmdecho 0)
  (setvar 'dimzin 0)
  
  (setq iedg:*error* *error*)
  (ia:Main)
  
  (setvar 'cmdecho old-cmdecho)
  (setvar 'dimzin old-dimzin)
  (vla-endundomark doc)
  (princ)
)