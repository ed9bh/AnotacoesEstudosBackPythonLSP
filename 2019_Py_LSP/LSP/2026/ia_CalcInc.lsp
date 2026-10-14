; =========================================================================================
; INFORMAÇÕES
; Objetivo: CALCINC - Greide com inclinação longitudinal limitada a partir das cotas do
;           terreno ao longo de um traçado. Reproduz a aba "Calc. Inc." da planilha
;           PROJETO-GERAL-INFRA_ATUAL.xlsm (função VBA "inctarget"): passada de avanço,
;           passada de retorno e envelope (menor cota das duas). Desenha POLYLINE 3D e grava
;           um CSV de memória de cálculo e TXT "distância cota" (Civil 3D: Profile From File).
; Data Inicial 14/10/2026 - Elaborador Eric Drumond (ED Serviços & Projetos) - Claude Opus 5.5 (Claude Code)
; Data Revisão 14/10/2026 / Rev. 00
; Exclusividade/Compatibilidade: AutoCAD [X] / Civil 3D [X] / Plant [ ] / Architeture [ ]
; Referencia Externa: Não [X] / AutoLisp / DWG(Assets) [ ] / CSV [X] (saída) / TXT [X] (saída) / Excel [ ]
; DCL: Sim [ ] / Não [X]
; -----------------------------------------------------------------------------------------
; USO
;   Comando : CALCINC (interativo)
;   API     : (ia:CalcInc ent imax surfEnt modo passo saida)  -> lista de resultados
;             ent     = ename do traçado (polilinha 3D/2D, linha, spline, feature line)
;             imax    = inclinação máxima em m/m (ex.: 0.20 = 20 %)
;             surfEnt = ename da superfície Civil 3D, ou nil para usar a cota do traçado
;             modo    = "Vertices" ou "Intervalo"   passo = espaçamento em m (modo Intervalo)
;             saida   = "Envelope" (só o envelope) ou "Todas" (avanço, retorno e envelope)
; LIMITAÇÕES / OBSERVAÇÕES
;   - Opção Superficie: exige Civil 3D (método COM FindElevationAtXY). Sem Civil 3D, usar a
;     cota da própria polilinha 3D. Funções vla-/vlax- e entmake: AutoCAD testado no Civil 3D;
;     ZWCAD/IntelliCAD não testados (sem COM do Civil 3D nesses programas).
;   - Correção em relação à planilha: a coluna K (retorno) usa a distância do trecho anterior
;     (E_i) para o trecho i..i+1; aqui usa-se a distância do próprio trecho. No 1º ponto a
;     planilha divide por zero e devolve a cota do terreno sem limitar a rampa.
;   - Distâncias horizontais (planimétricas) entre pontos consecutivos. Os vértices entram na
;     amostragem, para a distância acumulada coincidir com o estaqueamento de um alinhamento
;     criado do mesmo traçado (arcos de polilinha são substituídos por cordas).
;   - Polilinha 3D: o intervalo é medido na distância horizontal. Spline e feature line 3D:
;     o intervalo segue o comprimento da própria curva (3D), levemente menor na horizontal.
;   - O TXT de perfil começa na distância 0,000: se o alinhamento tiver estaca inicial
;     diferente de 0, somar essa estaca antes de importar.
;   - Persistência explícita: os últimos valores digitados ficam na variável global
;     *IA:CALCINC-CFG* (somente durante a sessão do desenho).
;   - Strings exibidas sem acento por compatibilidade de codificação (ANSI/UTF-8).
; =========================================================================================

(vl-load-com)

;;; -------------------------------------------------------------------------> SubFunções

;;; 1.0 Pasta de saída: pasta do DWG se já salvo e gravável; senão %TEMP%
(defun ia:CalcInc-Pasta ( / dir tst f)
  ;; 1.1 Testa escrita na pasta do DWG com arquivo temporário (apagado em seguida)
  (if (= 1 (getvar 'dwgtitled))
    (progn
      (setq dir (getvar 'dwgprefix)
            tst (strcat dir "~calcinc.tmp"))
      (if (setq f (open tst "w"))
        (progn (close f) (vl-file-delete tst))
        (setq dir nil)
      )
    )
  )
  ;; 1.2 Alternativa: %TEMP% do sistema
  (if (null dir)
    (setq dir (strcat (vl-string-right-trim "\\" (getenv "TEMP")) "\\"))
  )
  dir
)

;;; 2.0 Carimbo de data/hora (AAAAMMDD_HHMMSS) a partir de CDATE
(defun ia:CalcInc-Carimbo ( / dz s)
  (setq dz (getvar 'dimzin))
  (setvar 'dimzin 0)
  (setq s (vl-string-translate "." "_" (rtos (getvar 'cdate) 2 6)))
  (setvar 'dimzin dz)
  s
)

;;; 3.0 Log (adaptação de LogReport de Eric: arquivo por desenho, fallback %TEMP%)
(defun iedg:LogReport (msg / arq f)
  (setq arq (strcat (ia:CalcInc-Pasta)
                    "LogReport(" (vl-filename-base (getvar 'dwgname)) ")-CALCINC.log"))
  (if (setq f (open arq "a"))
    (progn
      (write-line (strcat "Log[" (ia:CalcInc-Carimbo) "]:> " (if msg msg "...")) f)
      (close f)
      arq
    )
  )
)

;;; 4.0 Layer (adaptação de add_layer de Eric: não altera a cor de layer já existente)
(defun iedg:add_layer (nome cor / novo lay)
  (setq novo (null (tblsearch "LAYER" nome))
        lay  (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) nome))
  ;; 4.1 Cor somente em layer novo, para preservar a padronização do desenho
  (if novo (vla-put-color lay cor))
  nome
)

;;; 5.0 Verifica se a entidade é um traçado aceito (tipo + vlax-curve + comprimento > 0)
;;;     Obs.: superfícies Civil 3D respondem a vlax-curve-getEndParam; por isso o filtro por tipo.
(defun ia:CalcInc-CurvaValida (ent / ed tipo r)
  (if ent
    (setq ed   (entget ent)
          tipo (cdr (assoc 0 ed)))
  )
  (and ent
       ;; 5.1 Tipos aceitos; POLYLINE de malha (flags 16/64) é recusada
       (member tipo '("LINE" "LWPOLYLINE" "POLYLINE" "SPLINE" "ARC" "AECC_FEATURE_LINE"))
       (or (/= tipo "POLYLINE") (zerop (logand 80 (cdr (assoc 70 ed)))))
       ;; 5.2 Curva com comprimento positivo
       (not (vl-catch-all-error-p
              (setq r (vl-catch-all-apply
                        '(lambda () (vlax-curve-getDistAtParam ent (vlax-curve-getEndParam ent)))))))
       (numberp r)
       (> r 1e-6)
  )
)

;;; 5.5 Nome de arquivo livre: acrescenta _2, _3... se já existir (execuções no mesmo segundo)
(defun ia:CalcInc-NomeLivre (base / nome i)
  (setq nome base i 1)
  (while (findfile (strcat nome ".csv"))
    (setq i (1+ i) nome (strcat base "_" (itoa i)))
  )
  nome
)

;;; 6.0 Porte da função VBA "inctarget" da planilha (macro Calculos.bas)
;|
 Limita a cota do ponto seguinte à rampa máxima a partir do ponto anterior:
 \n d    = distância horizontal entre os pontos (m)
 \n e1   = cota já calculada do ponto anterior (m)
 \n e2   = cota do terreno no ponto atual (m)
 \n i    = |e2 - e1| / d   (inclinação do trecho, m/m)
 \n se i > imax e e2 < e1 : e = e1 - d * imax   (desce no máximo imax)
 \n se i > imax e e2 > e1 : e = e1 + d * imax   (sobe no máximo imax)
 \n caso contrário        : e = e2              (segue o terreno)
 \n d <= 0 (pontos coincidentes): devolve e2, como o tratamento de erro do VBA
|;
(defun iedg:IncTarget (d e1 e2 imax / dz)
  (setq dz (- e2 e1))
  (cond
    ((or (null d) (<= d 1e-9)) e2)
    ((and (< dz 0.0) (> (/ (abs dz) d) imax)) (- e1 (* d imax)))
    ((and (> dz 0.0) (> (/ (abs dz) d) imax)) (+ e1 (* d imax)))
    (t e2)
  )
)

;;; 7.0 Passada de avanço (coluna J da planilha): do 1º ao último ponto
(defun ia:CalcInc-Avanco (zs segs imax / res)
  ;; 7.1 Primeiro ponto fica na cota do terreno; cada ponto seguinte é limitado pelo anterior
  (setq res (list (car zs)))
  (mapcar
    '(lambda (z d) (setq res (cons (iedg:IncTarget d (car res) z imax) res)))
    (cdr zs)
    segs
  )
  (reverse res)
)

;;; 8.0 Passada de retorno (coluna K, corrigida): do último ao 1º ponto
;|
 Mesma regra do avanço aplicada à lista invertida:
 \n K(n) = Z(n)
 \n K(i) = inctarget( d(i,i+1), K(i+1), Z(i), imax )
|;
(defun ia:CalcInc-Retorno (zs segs imax)
  (reverse (ia:CalcInc-Avanco (reverse zs) (reverse segs) imax))
)

;;; 9.0 Pontos de amostragem ao longo do traçado (adaptação de ListCoordsGeral de Eric:
;;;     a entrada é o espaçamento em metros, os vértices entram e os extremos não duplicam)
;|
 Polilinha 3D (segmentos retos): intervalo medido na distância HORIZONTAL acumulada,
 \n igual ao estaqueamento de um alinhamento criado da mesma polilinha:
 \n H(0) = 0 ;  H(i+1) = H(i) + sqrt( (X(i+1)-X(i))^2 + (Y(i+1)-Y(i))^2 )
 \n ponto na estaca s do trecho i:  t = (s - H(i)) / (H(i+1) - H(i)) ;  P = V(i) + t * (V(i+1) - V(i))
 \n Demais curvas (planas ou feature line/spline): distância ao longo da própria curva (vlax-curve).
|;
(defun iedg:ListCoordsGeral (ent passo modo / ed tipo flag is3d L lst vd n i d res ant V H s a b ha hb tol)
  ;; 9.0.1 Estaca a menos de "tol" de um vértice é descartada (o vértice prevalece)
  (setq tol (max 0.001 (* 0.02 passo)))
  (setq ed   (entget ent)
        tipo (cdr (assoc 0 ed))
        flag (if (assoc 70 ed) (cdr (assoc 70 ed)) 0)
        is3d (and (= tipo "POLYLINE") (= 8 (logand 8 flag)) (zerop (logand 6 flag))))
  (if is3d
    ;; 9.1 Polilinha 3D: vértices + estacas horizontais múltiplas do passo
    (progn
      (setq n (fix (+ (vlax-curve-getEndParam ent) 1e-9)) i 0)
      (repeat (1+ n)
        (setq V (cons (vlax-curve-getPointAtParam ent i) V) i (1+ i))
      )
      (setq V (reverse V) H (list 0.0))
      (mapcar '(lambda (p q) (setq H (cons (+ (car H) (ia:CalcInc-Dist2D p q)) H))) V (cdr V))
      (setq H (reverse H) res (list (car V)))
      ;; 9.1.1 Em cada trecho: estacas internas (se Intervalo) e o vértice final
      (mapcar
        '(lambda (a b ha hb)
           (if (and (= modo "Intervalo") (> (- hb ha) 1e-9))
             (progn
               (setq s (* passo (1+ (fix (/ (+ ha tol) passo)))))
               (while (< s (- hb tol))
                 (setq res (cons (mapcar '(lambda (u w) (+ u (* (/ (- s ha) (- hb ha)) (- w u)))) a b) res)
                       s   (+ s passo))
               )
             )
           )
           (if (> (ia:CalcInc-Dist2D b (car res)) 0.001) (setq res (cons b res)))
         )
        V (cdr V) H (cdr H)
      )
      (reverse res)
    )
    ;; 9.2 Outras curvas: distâncias ao longo da curva
    (progn
      (setq L (vlax-curve-getDistAtParam ent (vlax-curve-getEndParam ent)))
      ;; 9.2.1 Vértices: polilinhas planas sem ajuste de curva/spline e linhas
      (cond
        ((= tipo "LINE") (setq lst (list 0.0 L)))
        ((or (= tipo "LWPOLYLINE") (and (= tipo "POLYLINE") (zerop (logand 6 flag))))
         (setq n (fix (+ (vlax-curve-getEndParam ent) 1e-9)) i 0)
         (repeat (1+ n)
           (setq lst (cons (vlax-curve-getDistAtParam ent i) lst) i (1+ i))
         )
        )
      )
      ;; 9.2.2 Intervalo regular (ou fallback quando a curva não tem vértices)
      (if (or (= modo "Intervalo") (null lst))
        (progn
          (if (and (= modo "Vertices") (null lst))
            (princ "\n[CALCINC] Objeto sem vertices: usando intervalo regular.")
          )
          (setq vd lst d 0.0)
          (while (< d (- L 1e-6))
            ;; 9.2.2.1 Só acrescenta a estaca se não houver vértice a menos de tol
            (if (not (vl-some '(lambda (v) (< (abs (- v d)) tol)) vd))
              (setq lst (cons d lst))
            )
            (setq d (+ d passo))
          )
          (setq lst (cons L lst))
        )
      )
      ;; 9.2.3 Ordena, remove repetidas (1 mm) e converte em pontos
      (foreach d (vl-sort lst '<)
        (if (or (null ant) (> (- d ant) 0.001))
          (setq res (cons d res) ant d)
        )
      )
      (mapcar '(lambda (d) (cond ((vlax-curve-getPointAtDist ent d)) ((vlax-curve-getEndPoint ent))))
              (reverse res))
    )
  )
)

;;; 10.0 Cota da superfície Civil 3D em (x,y); nil fora da superfície
(defun ia:CalcInc-CotaSuperficie (sobj x y / r)
  (setq r (vl-catch-all-apply 'vlax-invoke (list sobj 'FindElevationAtXY x y)))
  (if (or (vl-catch-all-error-p r) (not (numberp r))) nil r)
)

;;; 11.0 Distância horizontal entre dois pontos 3D
(defun ia:CalcInc-Dist2D (p q)
  (distance (list (car p) (cadr p)) (list (car q) (cadr q)))
)

;;; 12.0 Maior inclinação absoluta de uma sequência de cotas (m/m)
(defun ia:CalcInc-InclMax (zs segs / m)
  (setq m 0.0)
  (mapcar
    '(lambda (z1 z2 d) (if (> d 1e-9) (setq m (max m (/ (abs (- z2 z1)) d)))))
    zs (cdr zs) segs
  )
  m
)

;;; 13.0 Desenha POLYLINE 3D por entmake (compatível com AutoCAD/ZWCAD/IntelliCAD)
(defun ia:CalcInc-Desenha3DPoly (pts zs layer / )
  (entmake (list '(0 . "POLYLINE") '(100 . "AcDbEntity") (cons 8 layer)
                 '(100 . "AcDb3dPolyline") '(66 . 1) '(10 0.0 0.0 0.0) '(70 . 8)))
  ;; 13.1 Um VERTEX por ponto (flag 32 = vértice de polilinha 3D)
  (mapcar
    '(lambda (p z)
       (entmake (list '(0 . "VERTEX") '(100 . "AcDbEntity") (cons 8 layer)
                      '(100 . "AcDbVertex") '(100 . "AcDb3dPolylineVertex")
                      (list 10 (car p) (cadr p) z) '(70 . 32)))
     )
    pts zs
  )
  (entmake (list '(0 . "SEQEND") (cons 8 layer)))
  (entlast)
)

;;; 14.0 Grava TXT "distancia cota" (ponto decimal, separador espaço) para Profile From File
(defun ia:CalcInc-GravaPerfil (arq acum zs / f)
  (if (setq f (open arq "w"))
    (progn
      ;; 14.1 Uma linha por ponto
      (mapcar '(lambda (a z) (write-line (strcat (rtos a 2 4) " " (rtos z 2 4)) f)) acum zs)
      (close f)
      arq
    )
  )
)

;;; 15.0 Grava CSV de memória de cálculo (separador ";", decimal ",")
;|
 Convenção: dz = cota_envelope - cota_terreno  (positivo = aterro, negativo = corte)
 \n Inc_Real(%) = 100 * (Z(i) - Z(i-1)) / d(i-1,i)
|;
(defun ia:CalcInc-GravaCSV (arq pts zs segs acum J K E imax / f i br)
  (setq br (lambda (x p) (vl-string-translate "." "," (rtos x 2 p))))
  (if (setq f (open arq "w"))
    (progn
      (write-line (strcat "Ponto;Este;Norte;Cota_Terreno;Distancia;Dist_Acum;Desnivel;"
                          "Inc_Real(%);Inc_Max(%);Cota_Avanco;Cota_Retorno;Cota_Envelope;"
                          "dz_Envelope(+aterro/-corte)") f)
      (setq i 0)
      ;; 15.1 Uma linha por ponto; o 1º ponto tem distância e desnível zero
      (mapcar
        '(lambda (p z s a zp jj kk ee)
           (setq i (1+ i))
           (write-line
             (strcat (itoa i) ";" (br (car p) 4) ";" (br (cadr p) 4) ";" (br z 4) ";"
                     (br s 4) ";" (br a 4) ";" (br (- z zp) 4) ";"
                     (br (if (> s 1e-9) (* 100.0 (/ (- z zp) s)) 0.0) 3) ";"
                     (br (* 100.0 imax) 3) ";" (br jj 4) ";" (br kk 4) ";" (br ee 4) ";"
                     (br (- ee z) 4))
             f)
         )
        pts zs (cons 0.0 segs) acum (cons (car zs) zs) J K E
      )
      (close f)
      arq
    )
  )
)

;;; 16.0 Núcleo (API): amostra, calcula, desenha e grava. Devolve lista de pares
(defun ia:CalcInc (ent imax surfEnt modo passo saida
                   / oldDz pts sobj zs nfora segs acum a J K E incT incP dzs
                     pasta base arqCsv txts ents lay)
  ;; 16.1 Validação das entradas
  (cond
    ((not (ia:CalcInc-CurvaValida ent)) (list (cons "ERRO" "Tracado invalido")))
    ((not (and (numberp imax) (> imax 0.0))) (list (cons "ERRO" "Inclinacao maxima invalida")))
    (t
     (if (not (and (numberp passo) (> passo 0.0))) (setq passo 5.0))
     (if (/= modo "Vertices") (setq modo "Intervalo"))
     (if (/= saida "Todas") (setq saida "Envelope"))
     (setq oldDz (getvar 'dimzin))
     (setvar 'dimzin 0)
     ;; 16.2 Amostragem: pontos ao longo do traçado
     (setq pts (iedg:ListCoordsGeral ent passo modo))
     ;; 16.3 Cota do terreno: superfície Civil 3D ou cota do próprio traçado
     (if surfEnt
       (progn
         (setq sobj  (vlax-ename->vla-object surfEnt)
               zs    (mapcar '(lambda (p) (ia:CalcInc-CotaSuperficie sobj (car p) (cadr p))) pts)
               nfora (length (vl-remove-if 'numberp zs)))
       )
       (setq zs (mapcar 'caddr pts) nfora 0)
     )
     (if (> nfora 0)
       (progn
         (setvar 'dimzin oldDz)
         (list (cons "ERRO" (strcat (itoa nfora) " ponto(s) fora da superficie")))
       )
       (progn
         ;; 16.4 Distâncias horizontais por trecho e acumuladas (colunas E e F)
         (setq segs (mapcar 'ia:CalcInc-Dist2D pts (cdr pts))
               a    0.0
               acum (cons 0.0 (mapcar '(lambda (s) (setq a (+ a s))) segs)))
         ;; 16.5 Passadas e envelope (colunas J, K e L)
         (setq J (ia:CalcInc-Avanco zs segs imax)
               K (ia:CalcInc-Retorno zs segs imax)
               E (mapcar 'min J K))
         ;; 16.6 Conferência: inclinações máximas e dz extremos
         (setq incT (ia:CalcInc-InclMax zs segs)
               incP (ia:CalcInc-InclMax E segs)
               dzs  (mapcar '- E zs))
         ;; 16.7 Desenho das POLYLINE 3D
         (setq lay  (iedg:add_layer "IA-CALCINC-ENVELOPE" 2)
               ents (list (cons "ENVELOPE" (cdr (assoc 5 (entget (ia:CalcInc-Desenha3DPoly pts E lay)))))))
         (if (= saida "Todas")
           (progn
             (setq lay  (iedg:add_layer "IA-CALCINC-AVANCO" 4)
                   ents (cons (cons "AVANCO" (cdr (assoc 5 (entget (ia:CalcInc-Desenha3DPoly pts J lay))))) ents)
                   lay  (iedg:add_layer "IA-CALCINC-RETORNO" 6)
                   ents (cons (cons "RETORNO" (cdr (assoc 5 (entget (ia:CalcInc-Desenha3DPoly pts K lay))))) ents))
           )
         )
         ;; 16.8 Arquivos de saída
         (setq pasta  (ia:CalcInc-Pasta)
               base   (ia:CalcInc-NomeLivre
                        (strcat pasta (vl-filename-base (getvar 'dwgname)) "_CALCINC_" (ia:CalcInc-Carimbo)))
               arqCsv (ia:CalcInc-GravaCSV (strcat base ".csv") pts zs segs acum J K E imax)
               txts   (list (ia:CalcInc-GravaPerfil (strcat base "_Envelope.txt") acum E)))
         (if (= saida "Todas")
           (setq txts (append txts
                              (list (ia:CalcInc-GravaPerfil (strcat base "_Avanco.txt") acum J)
                                    (ia:CalcInc-GravaPerfil (strcat base "_Retorno.txt") acum K))))
         )
         (setvar 'dimzin oldDz)
         ;; 16.9 Resultado
         (list (cons "PONTOS" (length pts))
               (cons "EXTENSAO" (last acum))
               (cons "INC_TERRENO" incT)
               (cons "INC_PROJETO" incP)
               (cons "ATERRO_MAX" (apply 'max (cons 0.0 dzs)))
               (cons "CORTE_MAX" (apply 'min (cons 0.0 dzs)))
               (cons "HANDLES" ents)
               (cons "CSV" arqCsv)
               (cons "TXT" txts))
       )
     )
    )
  )
)

;;; -------------------------------------------------------------------------> Comando

(defun c:CALCINC ( / *error* main doc undoAberto oldCmdecho oldDimzin)
  (vl-load-com)

  ;;; 17.0 Tratamento de erro: ID com data/hora, log na pasta do DWG ou %TEMP%, restauração
  (defun *error* (msg / id arq)
    (if (and msg (not (wcmatch (strcase msg t) "*cancel*,*quit*,*exit*")))
      (progn
        (setq id (strcat "CALCINC-" (vl-string-subst "" "_" (ia:CalcInc-Carimbo)) "-"
                         (itoa (fix (rem (cond ((getvar 'millisecs)) (0)) 100000)))))
        (princ (strcat "\n[CALCINC] Erro " id ": " msg))
        (if (setq arq (iedg:LogReport (strcat id " | " msg)))
          (princ (strcat "\n[CALCINC] Log: " arq))
        )
      )
      (princ "\n[CALCINC] Cancelado.")
    )
    (if oldDimzin (setvar 'dimzin oldDimzin))
    (if oldCmdecho (setvar 'cmdecho oldCmdecho))
    (if undoAberto (progn (vla-endundomark doc) (setq undoAberto nil)))
    (princ)
  )

  ;;; 18.0 Main: opções, seleção e execução
  (defun main ( / cfg sel ent imax fonte surf modo passo saida r e)
    ;; 18.1 Padrões da sessão (persistência explícita em *IA:CALCINC-CFG*)
    (setq cfg (cond (*IA:CALCINC-CFG*)
                    ((list (cons "INC" 20.0) (cons "FONTE" "Polilinha") (cons "MODO" "Intervalo")
                           (cons "PASSO" 5.0) (cons "SAIDA" "Envelope")))))
    ;; 18.2 Seleção do traçado (Enter vazio encerra)
    (while (null ent)
      (setvar 'errno 0)
      (setq sel (entsel "\nSelecione o tracado (polilinha 3D/2D, linha, spline, feature line): "))
      (cond
        ((and (null sel) (= 52 (getvar 'errno))) (exit))
        ((null sel) (princ "\nNada selecionado."))
        ((not (ia:CalcInc-CurvaValida (car sel))) (princ "\nObjeto nao e uma curva valida."))
        (t (setq ent (car sel)))
      )
    )
    ;; 18.3 Inclinação máxima em %
    (initget 6)
    (setq imax (getreal (strcat "\nInclinacao maxima (%) <" (rtos (cdr (assoc "INC" cfg)) 2 2) ">: ")))
    (if (null imax) (setq imax (cdr (assoc "INC" cfg))))
    ;; 18.4 Fonte da cota do terreno
    (initget "Polilinha Superficie")
    (setq fonte (getkword (strcat "\nCota do terreno [Polilinha/Superficie] <" (cdr (assoc "FONTE" cfg)) ">: ")))
    (if (null fonte) (setq fonte (cdr (assoc "FONTE" cfg))))
    ;; 18.5 Seleção da superfície (somente Civil 3D)
    (if (= fonte "Superficie")
      (while (null surf)
        (setvar 'errno 0)
        (setq sel (entsel "\nSelecione a superficie Civil 3D: "))
        (cond
          ((and (null sel) (= 52 (getvar 'errno))) (exit))
          ((null sel) (princ "\nNada selecionado."))
          ((not (vlax-method-applicable-p (vlax-ename->vla-object (car sel)) 'FindElevationAtXY))
           (princ "\nObjeto nao e uma superficie Civil 3D."))
          (t (setq surf (car sel)))
        )
      )
    )
    ;; 18.6 Amostragem
    (initget "Vertices Intervalo")
    (setq modo (getkword (strcat "\nAmostragem [Vertices/Intervalo] <" (cdr (assoc "MODO" cfg)) ">: ")))
    (if (null modo) (setq modo (cdr (assoc "MODO" cfg))))
    (setq passo (cdr (assoc "PASSO" cfg)))
    (if (= modo "Intervalo")
      (progn
        (initget 6)
        (setq r (getreal (strcat "\nIntervalo (m) <" (rtos passo 2 2) ">: ")))
        (if r (setq passo r))
      )
    )
    ;; 18.7 Polilinhas a desenhar
    (initget "Envelope Todas")
    (setq saida (getkword (strcat "\nDesenhar [Envelope/Todas] <" (cdr (assoc "SAIDA" cfg)) ">: ")))
    (if (null saida) (setq saida (cdr (assoc "SAIDA" cfg))))
    ;; 18.8 Guarda os padrões da sessão
    (setq *IA:CALCINC-CFG*
           (list (cons "INC" imax) (cons "FONTE" fonte) (cons "MODO" modo)
                 (cons "PASSO" passo) (cons "SAIDA" saida)))
    ;; 18.9 Execução e relatório
    (setq r (ia:CalcInc ent (/ imax 100.0) surf modo passo saida))
    (if (setq e (cdr (assoc "ERRO" r)))
      (princ (strcat "\n[CALCINC] " e))
      (progn
        (princ (strcat "\n[CALCINC] Pontos: " (itoa (cdr (assoc "PONTOS" r)))
                       " | Extensao: " (rtos (cdr (assoc "EXTENSAO" r)) 2 3) " m"))
        (princ (strcat "\n[CALCINC] Inclinacao max. terreno: " (rtos (* 100 (cdr (assoc "INC_TERRENO" r))) 2 2)
                       " % | envelope: " (rtos (* 100 (cdr (assoc "INC_PROJETO" r))) 2 2)
                       " % (limite " (rtos imax 2 2) " %)"))
        (princ (strcat "\n[CALCINC] Aterro max.: " (rtos (cdr (assoc "ATERRO_MAX" r)) 2 3)
                       " m | Corte max.: " (rtos (cdr (assoc "CORTE_MAX" r)) 2 3) " m"))
        ;; 18.9.1 Aviso: traçado sem variação de cota (ex.: polilinha 2D sem superfície)
        (if (< (cdr (assoc "INC_TERRENO" r)) 1e-9)
          (princ "\n[CALCINC] AVISO: cotas do terreno constantes. Use a opcao Superficie para polilinha 2D.")
        )
        (princ (strcat "\n[CALCINC] CSV: " (cdr (assoc "CSV" r))))
        (foreach t1 (cdr (assoc "TXT" r)) (princ (strcat "\n[CALCINC] Perfil: " t1)))
      )
    )
  )

  ;;; 19.0 Definições iniciais, Undo, variáveis, Main e restauração
  (setq doc        (vla-get-activedocument (vlax-get-acad-object))
        oldCmdecho (getvar 'cmdecho)
        oldDimzin  (getvar 'dimzin))
  (vla-startundomark doc)
  (setq undoAberto t)
  (setvar 'cmdecho 0)
  (main)
  (setvar 'dimzin oldDimzin)
  (setvar 'cmdecho oldCmdecho)
  (vla-endundomark doc)
  (setq undoAberto nil)
  (princ)
)

(princ "\nCALCINC carregado. Digite CALCINC para executar.")
(princ)
