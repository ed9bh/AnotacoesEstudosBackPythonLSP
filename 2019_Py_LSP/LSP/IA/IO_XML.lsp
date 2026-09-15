; =========================================================================================
; INFORMAÇÕES
; Objetivo: Exportar e Importar entidades nativas do AutoCAD para/de formato XML via DXF[cite: 3]
; Data Inicial - 01/09/2026 - Elaborador Eric Drumond (ED Serviços & Projetos) - Gemini[cite: 3]
; Data Revisão / Número da Revisão: 09/09/2026 / Rev. 04
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [X] / Architeture [X] / ZWCAD [X] / BricsCAD [X][cite: 3]
; Referencia Externa: Não [ ] / AutoLisp [ ] / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ] / XML [X][cite: 3]
; DCL: Sim [ ] / Não [X][cite: 3]
; =========================================================================================

(vl-load-com) ;[cite: 3]

(defun c:IO_XML ( / *error* LogReport EscapeXML UnescapeXML GetXmlAttr GetTagValue 
                    Val->Str ParseStr Dxf->Xml ExportEntityAndSub XmlGetAllBlocks 
                    EnsureLayer EnsureLinetype EnsureTextStyle ExportEntities 
                    ImportEntities Main acad doc MSpace old-cmdecho
                    FileNameMem ) ; Todas as variáveis como locais[cite: 3]

  ;;; --------------------------------------> Tratamento de Erro & Log
  
  ; Função de erro customizada[cite: 3]
  (defun *error* (msg / LogFilePath LogFileOpened) ;[cite: 2]
    (if doc (vla-endundomark doc))
    (if old-cmdecho (setvar 'cmdecho old-cmdecho))
    (if (not (member msg '("Function cancelled" "quit / exit abort"))) ;[cite: 2]
      (progn
        (princ (strcat "\nErro: " msg)) ;[cite: 2]
        (LogReport t (strcat "ERR-" msg))
      )
    )
    (princ) ;[cite: 2]
  )

  ; Gerar IDs Alfanuméricos com Data/Hora e registro do sistema na pasta do DWG atual[cite: 3]
  ;
  ; Rev. 04 - FileNameMem NÃO é mais local desta função. Sendo local, nascia nil
  ; a cada chamada: o ramo (fileNew = nil) montava LogFilePath nil e o
  ; (open nil "a+") falhava. Todas as chamadas da Rev. 03 passavam t, o que
  ; mascarava o defeito criando um log novo por evento. Agora a variável vive no
  ; escopo de c:IO_XML e uma execução inteira cai num arquivo só.
  (defun LogReport (fileNew msg / LogFilePath LogFileOpened) ;[cite: 2]
    (if (or fileNew (null FileNameMem))
      (setq FileNameMem
        (strcat (getvar 'dwgprefix) "LogReport(" (vl-string-right-trim ".dwg" (getvar 'dwgname)) ")-" (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)) ".log") ;[cite: 2]
      )
    )
    (setq LogFilePath FileNameMem) ;[cite: 2]
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

  (defun EscapeXML (str / i char res)
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

  (defun UnescapeXML (str / res)
    (setq res str)
    (foreach pair '(("&amp;" . "&") ("&lt;" . "<") ("&gt;" . ">") ("&quot;" . "\"") ("&apos;" . "'"))
      (while (vl-string-search (car pair) res)
        (setq res (vl-string-subst (cdr pair) (car pair) res))
      )
    )
    res
  )

  (defun GetXmlAttr (attr line / pStart pEnd)
    (setq pStart (vl-string-search (strcat attr "=\"") line))
    (if pStart
      (progn
        (setq pStart (+ pStart (strlen attr) 2))
        (setq pEnd (vl-string-search "\"" line pStart))
        (if pEnd (substr line (1+ pStart) (- pEnd pStart)))
      )
    )
  )

  (defun GetTagValue (tag line / pStart pEnd len)
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

  (defun Val->Str (val / )
    (cond
      ((= (type val) 'STR) val)
      ((= (type val) 'INT) (itoa val))
      ((= (type val) 'REAL) (vl-prin1-to-string val)) 
      ((= (type val) 'LIST) (vl-string-trim "()" (vl-prin1-to-string val)))
      (t (vl-prin1-to-string val))
    )
  )

  (defun ParseStr (str vType / readVal)
    (cond
      ((= vType "STR") (UnescapeXML str))
      ((= vType "INT") (atoi str))
      ((= vType "REAL") (atof (vl-string-translate "," "." str)))
      ((= vType "LIST")
       (setq readVal (read (strcat "(" str ")")))
       (if (listp readVal)
         (mapcar '(lambda (v) (if (numberp v) (float v) 0.0)) readVal)
         (list 0.0 0.0 0.0)
       )
      )
      (t (UnescapeXML str))
    )
  )

  ;;; --------------------------------------> SubFunções de Serialização e Parser

  (defun Dxf->Xml (ename / elist xmlLines code val tag vType)
    (setq elist (entget ename '("*")))
    (setq xmlLines (list "  <ENTITY>"))
    (foreach pair elist
      (setq code (car pair))
      (setq val (cdr pair))
      (if (not (member code '(-1 -2 -3 5 330 360 340 390 410)))
        (progn
          (setq vType (vl-symbol-name (type val)))
          (setq tag (strcat "    <DXF code=\"" (itoa code) "\" type=\"" vType "\">" (EscapeXML (Val->Str val)) "</DXF>"))
          (setq xmlLines (cons tag xmlLines))
        )
      )
    )
    (setq xmlLines (cons "  </ENTITY>" xmlLines))
    (reverse xmlLines)
  )

  (defun ExportEntityAndSub (ename / lines elist entSub)
    (setq lines (Dxf->Xml ename))
    (setq elist (entget ename))
    (if (= (cdr (assoc 66 elist)) 1)
      (progn
        (setq entSub (entnext ename))
        (while (and entSub (/= (cdr (assoc 0 (entget entSub))) "SEQEND"))
          (setq lines (append lines (Dxf->Xml entSub)))
          (setq entSub (entnext entSub))
        )
        (if entSub
          (setq lines (append lines (Dxf->Xml entSub)))
        )
      )
    )
    lines
  )

  (defun XmlGetAllBlocks (filePath / fp line inEntity entityList currentEntity codeStr typeStr valStr)
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
             (setq codeStr (GetXmlAttr "code" line))
             (setq typeStr (GetXmlAttr "type" line))
             (setq valStr (GetTagValue "DXF" line))
             (if (and codeStr typeStr valStr)
               (setq currentEntity (cons (cons (atoi codeStr) (ParseStr valStr typeStr)) currentEntity))
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

  (defun EnsureLayer (layerName / )
    (if (not (tblsearch "LAYER" layerName))
      (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                     (cons 2 layerName) '(70 . 0) '(62 . 7) '(6 . "Continuous")))
    )
  )

  (defun EnsureLinetype (dxfList / lt)
    (setq lt (cdr (assoc 6 dxfList)))
    (if (and lt (not (tblsearch "LTYPE" lt)))
      (vl-remove-if '(lambda (x) (= (car x) 6)) dxfList)
      dxfList
    )
  )

  (defun EnsureTextStyle (dxfList / st)
    (setq st (cdr (assoc 7 dxfList)))
    (if (and st (not (tblsearch "STYLE" st)))
      (vl-remove-if '(lambda (x) (= (car x) 7)) dxfList)
      dxfList
    )
  )

  ;;; --------------------------------------> SubFunções de Exportação e Importação

  (defun ExportEntities ( / ss i ename fp fPath total lines l )
    (princ "\nSelecione os objetos para exportar para XML: ")
    (if (setq ss (ssget))
      (progn
        (setq fPath (getfiled "Salvar Arquivo XML" (strcat (getvar 'dwgprefix) "Desenho_Export.xml") "xml" 1))
        (if fPath
          (progn
            (if (setq fp (open fPath "w"))
              (progn
                ; O AutoLISP grava em ANSI (cp1252), não em UTF-8. Declarar UTF-8
                ; produzia arquivo que mente sobre si e que qualquer leitor XML de
                ; fora recusa no primeiro acento. O ImportEntities não olha a
                ; declaração, então a mudança não afeta o round-trip interno.
                (write-line "<?xml version=\"1.0\" encoding=\"windows-1252\"?>" fp)
                (write-line "<AUTOCAD_DRAWING>" fp)
                (write-line " <ENTITIES>" fp)
                (setq total (sslength ss) i 0)
                (while (< i total)
                  (setq ename (ssname ss i))
                  (setq lines (ExportEntityAndSub ename))
                  (foreach l lines (write-line l fp))
                  (setq i (1+ i))
                )
                (write-line " </ENTITIES>" fp)
                (write-line "</AUTOCAD_DRAWING>" fp)
                (close fp)
                (princ (strcat "\n[SUCESSO] " (itoa total) " entidades principais exportadas para: " fPath))
              )
              (princ "\n[ERRO] Não foi possível abrir o arquivo para gravação.")
            )
          )
        )
      )
      (princ "\nNenhum objeto selecionado.")
    )
  )

  (defun ImportEntities ( / fPath entities created count dxfList entRes lay entType sub idx tot )
    (setq fPath (getfiled "Selecionar Arquivo XML para Importar" (getvar 'dwgprefix) "xml" 0))
    (if (and fPath (findfile fPath))
      (progn
        (setq entities (XmlGetAllBlocks fPath))
        (setq count 0 created 0 idx 0 tot (length entities))
        
        (while (< idx tot)
          (setq dxfList (nth idx entities))
          (setq entType (cdr (assoc 0 dxfList)))
          
          (setq lay (cdr (assoc 8 dxfList)))
          (if lay (EnsureLayer lay))
          (setq dxfList (EnsureLinetype dxfList))
          (setq dxfList (EnsureTextStyle dxfList))
          
          (cond
            ;; Procedimento Especial: qualquer entidade complexa
            ;;
            ;; Rev. 04 - o teste passou a ser (assoc 66) = 1, "seguem
            ;; sub-entidades", que é EXATAMENTE o mesmo que o ExportEntityAndSub
            ;; usa para exportar. Com isso a importação fica simétrica à
            ;; exportação e passam a entrar, além da polilinha 3D: polilinha 2D
            ;; (o gabarito ACAD-templateIA.dxf tem 290, nenhuma 3D), malha
            ;; poliface e poligonal, e INSERT com ATTRIB.
            ;;
            ;; A Rev. 03 disparava só para POLYLINE com flag 70 = 8; todo o
            ;; resto caía no ramo genérico, que criava o cabeçalho e depois
            ;; tentava criar cada VERTEX como entidade solta.
            ((= (cdr (assoc 66 dxfList)) 1)
             ;; 1º - Cabeçalho, com a lista DXF inteira
             ;;
             ;; A Rev. 03 reconstruía '((0 . "POLYLINE") (70 . 8)) e perdia
             ;; camada, cor, elevação e o próprio tipo de malha (70 = 8, 16, 64).
             (setq entRes (entmake dxfList))
             (setq idx (1+ idx))

             ;; 2º - Sub-entidades, também com a lista DXF INTEIRA
             ;;
             ;; A Rev. 03 recriava o vértice só com (10 ...) e (70 . 32).
             ;; Descartava bulge (42) - polilinha com arco voltava reta -,
             ;; larguras (40/41), camada e, no caso da malha poliface, os
             ;; índices de face (71/72/73), sem os quais não há malha nenhuma.
             (while (and (< idx tot)
                         (member (cdr (assoc 0 (nth idx entities)))
                                 '("VERTEX" "ATTRIB")))
               (setq sub (nth idx entities))
               (setq lay (cdr (assoc 8 sub)))
               (if lay (EnsureLayer lay))
               (setq sub (EnsureLinetype sub))
               (setq sub (EnsureTextStyle sub))
               (if (not (entmake sub))
                 (LogReport nil (strcat "Falha entmake sub: " (vl-prin1-to-string sub)))
               )
               (setq idx (1+ idx))
             )

             ;; 3º - SEQEND
             ;;
             ;; Se o arquivo não trouxer o SEQEND, fecha-se assim mesmo: uma
             ;; entidade complexa deixada em aberto derruba todo entmake
             ;; seguinte, e o usuário veria falhar a entidade errada.
             (if (and (< idx tot) (= (cdr (assoc 0 (nth idx entities))) "SEQEND"))
               (progn
                 (entmake (nth idx entities))
                 (setq idx (1+ idx))
               )
               (entmake '((0 . "SEQEND")))
             )
             ;; Compensação do índice final do loop para não pular a próxima entidade externa
             (setq idx (1- idx))
             (if entRes
               (setq created (1+ created))
               (LogReport nil (strcat "Falha entmake complexa: " (vl-prin1-to-string dxfList)))
             )
            )
            
            ;; Criação Padrão de Entidade
            (t
             (setq entRes (entmake dxfList))
             (if entRes
               (setq created (1+ created))
               (LogReport nil (strcat "Falha entmake: " (vl-prin1-to-string dxfList)))
             )
            )
          )
          
          (setq count (1+ count))
          (setq idx (1+ idx))
        )
        (princ (strcat "\n[SUCESSO] Processamento concluído: " (itoa created) " blocos/entidades DXF processados."))
      )
      (princ "\nArquivo não selecionado ou inexistente.")
    )
  )

  ;;; --------------------------------------> Main

  (defun Main ( / opt ) ;[cite: 3]
    (initget "Exportar Importar")
    (setq opt (getkword "\nEscolha uma opção [Exportar / Importar] <Exportar>: "))
    (if (or (null opt) (= opt "") (= opt "Exportar"))
      (ExportEntities)
      (ImportEntities)
    )
  )

  ;;; --------------------------------------> Definições Iniciais e Execução
  
  (setq
    acad (vlax-get-acad-object) ;[cite: 2]
    doc (vla-get-activedocument acad) ;[cite: 2]
    MSpace (vla-get-modelspace doc) ;[cite: 2]
    old-cmdecho (getvar 'cmdecho)
  )
  
  (vla-startundomark doc) ;[cite: 2, 3]
  (setvar 'cmdecho 0) ;[cite: 2]
  
  (Main) ;[cite: 2, 3]
  
  (setvar 'cmdecho old-cmdecho) ;[cite: 2]
  (vla-endundomark doc) ;[cite: 2, 3]
  (princ) ;[cite: 2, 3]
)

;; Alias simplificados para acesso direto via prompt de comando
(defun c:EXPORTXML () (c:IO_XML))
(defun c:IMPORTXML () (c:IO_XML))

(princ "\n[Carregado com sucesso - Rev. 04] Comandos disponíveis: IO_XML, EXPORTXML, IMPORTXML\n")
(princ) ;[cite: 3]