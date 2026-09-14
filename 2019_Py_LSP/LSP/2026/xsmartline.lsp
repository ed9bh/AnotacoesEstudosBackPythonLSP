; =========================================================================================
; INFORMAÇÕES
; Objetivo: Cria polilinha amarrada em 'points' e 'blocks' com deteção automática de 2D/3D.[cite: 1, 2, 4]
; Data Inicial - Elaborador Eric Drumond (ED Serviços & Projetos) - Gemini / 1.0
; Data Revisão / 1
; Exclusividade/Compatibilidade: AutoCAD [x] / Civil 3D [x] / Plant [ ] / Architeture [ ]
; Referencia Externa: Não [x] / AutoLisp / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ]
; DCL: Sim [ ] / Não [ ]
; =========================================================================================

(vl-load-com)

(defun c:xsml () (c:xsmartline))
(defun c:xsmartline ( / *error* acad doc MSpace memo lay pointList space point ss p a pl is3D elev flatList safearray coords)
  
  ;;; --------------------------------------> Funcoes
  
  (defun *error* (msg)
    (if doc (vla-endundomark doc))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nErro: " msg))
    )
    (princ)
  )

  (defun edg:GetCoord (vla_obj / objName pt)
    (setq objName (vlax-get vla_obj 'ObjectName))
    (cond
      ((= objName "AcDbPoint") (vlax-get vla_obj 'Coordinates));[cite: 1]
      ((= objName "AcDbBlockReference") (vlax-get vla_obj 'InsertionPoint));[cite: 1]
      ((= objName "AeccDbCogoPoint") (vlax-get vla_obj 'Location));[cite: 1]
      (t nil)
    )
  )

  ;;; --------------------------------------> Main
  
  (defun ia:main ()
    (if (setq memo (vl-file-size (strcat (getvar "dwgprefix") (getvar "dwgname")))) (alloc (* memo 4)));[cite: 1, 2]
    (princ "\nSomente em pontos e blocos!!!");[cite: 1, 2]
    (initget 128 "Digitar  ");[cite: 1, 2]
    (setq
      lay (entsel "\nFiltrar por layer? [Digitar / Selecione]<Enter para geral>: ");[cite: 1, 2]
      lay (if (and (/= lay "Digitar") (/= lay "")) (vlax-get (vlax-ename->vla-object (car lay)) 'Layer) lay);[cite: 1, 2]
      lay (if (= lay "Digitar") (getstring "\nDigite os layers separados por virgula: " t) lay);[cite: 1, 2]
      lay (if (= lay "") nil lay);[cite: 1, 2]
      pointList nil;[cite: 1, 2]
    )

    (while
      (setq point
        (progn
          (initget 128 "Undo");[cite: 1, 2]
          (if pointList
            (getpoint (car pointList) "\tClique proximo ao ponto<Undo>: ");[cite: 1]
            (getpoint "\tClique proximo ao ponto<Undo>: ");[cite: 1]
          )
        )
      )
      (if (= point "Undo");[cite: 1, 2]
        (if (> (length pointList) 1) (setq pointList (cdr pointList)));[cite: 1, 2]
        (progn
          (setq
            ss (ssget "w"
                 (list (- (car point) 100) (- (cadr point) 100));[cite: 1, 2]
                 (list (+ (car point) 100) (+ (cadr point) 100));[cite: 1, 2]
                 (if lay
                   (list '(0 . "insert,point,AECC_COGO_POINT") (cons 8 lay));[cite: 1]
                   '((0 . "insert,point,AECC_COGO_POINT"));[cite: 1]
                 )
               )
            p (if ss
                (mapcar
                  '(lambda (x)
                     (edg:GetCoord (vlax-ename->vla-object (cadr x)))
                   )
                  (cdr (reverse (ssnamex ss)));[cite: 1, 2]
                )
              )
            p (if ss
                (vl-sort p
                  (function (lambda (a1 a2)
                              (< (distance (list (car point) (cadr point)) (list (car a1) (cadr a1)))
                                 (distance (list (car point) (cadr point)) (list (car a2) (cadr a2)))
                              )
                            )
                  )
                );[cite: 1]
              )
            p (if ss (car p) point);[cite: 1, 2]
          )
        )
      )
      
      (if (= point "Undo");[cite: 1, 2]
        (princ);[cite: 1, 2]
        (if p (setq pointList (vl-list* p pointList)));[cite: 1]
      )
      
      (if (and (> (length pointList) 1)
               (equal (car (car pointList)) (car (cadr pointList)) 0);[cite: 1, 2]
               (equal (cadr (car pointList)) (cadr (cadr pointList)) 0);[cite: 1, 2]
          )
        (setq pointList (cdr pointList));[cite: 1, 2]
      )
      
      (redraw);[cite: 1, 2]
      (if (>= (length pointList) 2)
        (mapcar '(lambda (a b) (grdraw a b 12)) (reverse (cdr (reverse pointList))) (cdr pointList));[cite: 1, 2]
      )
    )

    (if (and pointList (> (length pointList) 1))
      (progn
        ;; Analisar se há variação na cota Z
        (setq 
          is3D nil
          elev (caddr (car pointList))
        )
        (foreach pt pointList
          (if (not (equal (caddr pt) elev 1e-4))
            (setq is3D t)
          )
        )

        (if is3D
          ;; Gerar 3D Polyline
          (progn
            (setq flatList (apply 'append (reverse pointList)));[cite: 1]
            (setq pl (vla-add3DPoly MSpace
                       (vlax-make-variant
                         (vlax-safearray-fill
                           (vlax-make-safearray vlax-vbdouble (cons 0 (1- (length flatList))));[cite: 1]
                           flatList
                         )
                       )
                     )
            );[cite: 1]
          )
          ;; Gerar Lightweight Polyline (2D)
          (progn
            (setq flatList nil)
            (foreach pt (reverse pointList)
              (setq flatList (append flatList (list (car pt) (cadr pt))))
            )
            (setq pl (vla-addLightweightPolyline MSpace
                       (vlax-make-variant
                         (vlax-safearray-fill
                           (vlax-make-safearray vlax-vbdouble (cons 0 (1- (length flatList))));[cite: 2]
                           flatList
                         )
                       )
                     )
            );[cite: 2]
            (vla-put-Elevation pl elev)
          )
        )
        
        (redraw);[cite: 1, 2]
        (if lay (vla-put-layer pl lay));[cite: 1, 2]
        (princ (strcat "\nExtensão = " (rtos (vlax-get pl 'Length) 2) " - Layer = " (vlax-get pl 'Layer) " - Cor = " (rtos (vlax-get pl 'Color) 2 0) "\n"));[cite: 1, 2]
      )
    )
    (gc);[cite: 1, 2]
  )

  ;;; --------------------------------------> Rotina
  
  (setq
    acad (vlax-get-acad-object);[cite: 3]
    doc (vla-get-activedocument acad);[cite: 3]
    MSpace (if(=(getvar "ctab") "Model")
             (vla-get-modelspace doc);[cite: 1, 2]
             (vla-get-paperspace doc);[cite: 1, 2]
           )
  )
  
  (vla-startundomark doc);[cite: 3]
  (setvar 'cmdecho 0);[cite: 3]
  (ia:main)
  (setvar 'cmdecho 1);[cite: 3]
  (vla-endundomark doc);[cite: 3]
  (princ);[cite: 3]
)