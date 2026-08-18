;;; ============================================================
;;; CONVERSAO GEOGRAFICA <-> UTM
;;; Datums/elipsoides:
;;; - SIRGAS-2000 / GRS80
;;; - SAD-69 / Internacional 1967
;;; - Corrego Alegre / Hayford 1924
;;;
;;; Entrada geografica em graus decimais:
;;; Latitude Sul negativa, Longitude Oeste negativa.
;;;
;;; Autor: rotina base para AutoCAD/AutoLISP
;;; ============================================================

(defun geo:deg->rad (ang)
  (* pi (/ ang 180.0))
)

(defun geo:rad->deg (ang)
  (* 180.0 (/ ang pi))
)

(defun geo:pow2 (x) (* x x))
(defun geo:pow3 (x) (* x x x))
(defun geo:pow4 (x) (* x x x x))
(defun geo:pow5 (x) (* x x x x x))
(defun geo:pow6 (x) (* x x x x x x))

(defun geo:datum (datum / d a invf f e2 ep2)
  (setq d (strcase datum))

  (cond
    (
      (member d '("SIRGAS2000" "SIRGAS-2000" "SIRGAS 2000" "SIRGAS"))
      (setq a    6378137.0)
      (setq invf 298.257222101)
    )
    (
      (member d '("SAD69" "SAD-69" "SAD 69"))
      (setq a    6378160.0)
      (setq invf 298.25)
    )
    (
      (member d '("CORREGO ALEGRE" "CÓRREGO ALEGRE" "CORREGO" "CÓRREGO"))
      (setq a    6378388.0)
      (setq invf 297.0)
    )
    (
      T
      (alert
        (strcat
          "Datum nao reconhecido: "
          datum
          "\nUse: SIRGAS-2000, SAD-69 ou Corrego Alegre."
        )
      )
      nil
    )
  )

  (if a
    (progn
      (setq f   (/ 1.0 invf))
      (setq e2  (- (* 2.0 f) (* f f)))
      (setq ep2 (/ e2 (- 1.0 e2)))
      (list a f e2 ep2)
    )
  )
)

(defun geo:central-meridian (zone)
  ;; Meridiano central do fuso UTM, em graus.
  ;; Ex.: fuso 23 -> -45 graus
  (- (* 6.0 zone) 183.0)
)

(defun geo:auto-zone (lonDeg)
  ;; Calcula fuso UTM pela longitude decimal.
  ;; Longitude Oeste deve ser negativa.
  (fix (+ (/ (+ lonDeg 180.0) 6.0) 1.0))
)

(defun geo:meridional-arc (a e2 phi / e4 e6 m)
  (setq e4 (* e2 e2))
  (setq e6 (* e4 e2))

  (setq m
    (* a
      (+
        (* (- 1.0 (/ e2 4.0) (/ (* 3.0 e4) 64.0) (/ (* 5.0 e6) 256.0)) phi)
        (* -1.0 (+ (/ (* 3.0 e2) 8.0) (/ (* 3.0 e4) 32.0) (/ (* 45.0 e6) 1024.0)) (sin (* 2.0 phi)))
        (*      (+ (/ (* 15.0 e4) 256.0) (/ (* 45.0 e6) 1024.0)) (sin (* 4.0 phi)))
        (* -1.0 (/ (* 35.0 e6) 3072.0) (sin (* 6.0 phi)))
      )
    )
  )
  m
)

(defun GEO->UTM
  (
    latDeg
    lonDeg
    datum
    zone
    hemis
    /
    el a f e2 ep2 k0 phi lam lon0
    sinphi cosphi tanphi n tt c aa m
    easting northing hemi
  )

  ;; latDeg: latitude em graus decimais. Sul negativo.
  ;; lonDeg: longitude em graus decimais. Oeste negativo.
  ;; datum : "SIRGAS-2000", "SAD-69" ou "Corrego Alegre".
  ;; zone  : fuso UTM. Pode passar nil para calcular automaticamente.
  ;; hemis : "S" ou "N". Pode passar nil para definir pela latitude.

  (setq el (geo:datum datum))

  (if el
    (progn
      (setq a   (nth 0 el))
      (setq f   (nth 1 el))
      (setq e2  (nth 2 el))
      (setq ep2 (nth 3 el))

      (setq k0 0.9996)

      (if (null zone)
        (setq zone (geo:auto-zone lonDeg))
      )

      (if (null hemis)
        (setq hemi (if (< latDeg 0.0) "S" "N"))
        (setq hemi (strcase hemis))
      )

      (setq phi  (geo:deg->rad latDeg))
      (setq lam  (geo:deg->rad lonDeg))
      (setq lon0 (geo:deg->rad (geo:central-meridian zone)))

      (setq sinphi (sin phi))
      (setq cosphi (cos phi))
      (setq tanphi (/ sinphi cosphi))

      (setq n (/ a (sqrt (- 1.0 (* e2 sinphi sinphi)))))
      (setq tt (* tanphi tanphi))
      (setq c (* ep2 cosphi cosphi))
      (setq aa (* cosphi (- lam lon0)))

      (setq m (geo:meridional-arc a e2 phi))

      (setq easting
        (+ 500000.0
          (* k0 n
            (+
              aa
              (* (/ (- 1.0 tt (* -1.0 c)) 6.0) (geo:pow3 aa))
              (* (/ (+ 5.0 (* -18.0 tt) (* tt tt) (* 72.0 c) (* -58.0 ep2)) 120.0) (geo:pow5 aa))
            )
          )
        )
      )

      ;; Correção: expressão 1 - T + C
      (setq easting
        (+ 500000.0
          (* k0 n
            (+
              aa
              (* (/ (+ 1.0 (* -1.0 tt) c) 6.0) (geo:pow3 aa))
              (* (/ (+ 5.0 (* -18.0 tt) (* tt tt) (* 72.0 c) (* -58.0 ep2)) 120.0) (geo:pow5 aa))
            )
          )
        )
      )

      (setq northing
        (* k0
          (+
            m
            (* n tanphi
              (+
                (/ (geo:pow2 aa) 2.0)
                (* (/ (+ 5.0 (* -1.0 tt) (* 9.0 c) (* 4.0 c c)) 24.0) (geo:pow4 aa))
                (* (/ (+ 61.0 (* -58.0 tt) (* tt tt) (* 600.0 c) (* -330.0 ep2)) 720.0) (geo:pow6 aa))
              )
            )
          )
        )
      )

      (if (= hemi "S")
        (setq northing (+ northing 10000000.0))
      )

      ;; Retorno em lista associativa
      (list
        (cons "E" easting)
        (cons "N" northing)
        (cons "FUSO" zone)
        (cons "HEMISFERIO" hemi)
        (cons "DATUM" datum)
      )
    )
  )
)

(defun UTM->GEO
  (
    easting
    northing
    zone
    hemis
    datum
    /
    el a f e2 ep2 k0 x y lon0
    e1 m mu phi1
    sin1 cos1 tan1 n1 r1 tt1 c1 d
    lat lon
  )

  ;; easting : coordenada Este UTM.
  ;; northing: coordenada Norte UTM.
  ;; zone    : fuso UTM.
  ;; hemis   : "S" ou "N".
  ;; datum   : "SIRGAS-2000", "SAD-69" ou "Corrego Alegre".

  (setq el (geo:datum datum))

  (if el
    (progn
      (setq a   (nth 0 el))
      (setq f   (nth 1 el))
      (setq e2  (nth 2 el))
      (setq ep2 (nth 3 el))

      (setq k0 0.9996)
      (setq x (- easting 500000.0))
      (setq y northing)

      (if (= (strcase hemis) "S")
        (setq y (- y 10000000.0))
      )

      (setq lon0 (geo:deg->rad (geo:central-meridian zone)))

      (setq m (/ y k0))

      (setq mu
        (/ m
          (* a
            (- 1.0
               (/ e2 4.0)
               (/ (* 3.0 (geo:pow2 e2)) 64.0)
               (/ (* 5.0 (geo:pow3 e2)) 256.0)
            )
          )
        )
      )

      (setq e1
        (/ (- 1.0 (sqrt (- 1.0 e2)))
           (+ 1.0 (sqrt (- 1.0 e2)))
        )
      )

      (setq phi1
        (+
          mu
          (* (- (/ (* 3.0 e1) 2.0) (/ (* 27.0 (geo:pow3 e1)) 32.0)) (sin (* 2.0 mu)))
          (* (- (/ (* 21.0 (geo:pow2 e1)) 16.0) (/ (* 55.0 (geo:pow4 e1)) 32.0)) (sin (* 4.0 mu)))
          (* (/ (* 151.0 (geo:pow3 e1)) 96.0) (sin (* 6.0 mu)))
          (* (/ (* 1097.0 (geo:pow4 e1)) 512.0) (sin (* 8.0 mu)))
        )
      )

      (setq sin1 (sin phi1))
      (setq cos1 (cos phi1))
      (setq tan1 (/ sin1 cos1))

      (setq n1 (/ a (sqrt (- 1.0 (* e2 sin1 sin1)))))
      (setq r1 (/ (* a (- 1.0 e2))
                  (expt (- 1.0 (* e2 sin1 sin1)) 1.5)
               )
      )
      (setq tt1 (* tan1 tan1))
      (setq c1 (* ep2 cos1 cos1))
      (setq d (/ x (* n1 k0)))

      (setq lat
        (-
          phi1
          (*
            (/ (* n1 tan1) r1)
            (+
              (/ (geo:pow2 d) 2.0)
              (* -1.0 (/ (+ 5.0 (* 3.0 tt1) (* 10.0 c1) (* -4.0 c1 c1) (* -9.0 ep2)) 24.0) (geo:pow4 d))
              (* (/ (+ 61.0 (* 90.0 tt1) (* 298.0 c1) (* 45.0 tt1 tt1) (* -252.0 ep2) (* -3.0 c1 c1)) 720.0) (geo:pow6 d))
            )
          )
        )
      )

      (setq lon
        (+
          lon0
          (/
            (+
              d
              (* -1.0 (/ (+ 1.0 (* 2.0 tt1) c1) 6.0) (geo:pow3 d))
              (* (/ (+ 5.0 (* -2.0 c1) (* 28.0 tt1) (* -3.0 c1 c1) (* 8.0 ep2) (* 24.0 tt1 tt1)) 120.0) (geo:pow5 d))
            )
            cos1
          )
        )
      )

      ;; Retorno em graus decimais
      (list
        (cons "LATITUDE"  (geo:rad->deg lat))
        (cons "LONGITUDE" (geo:rad->deg lon))
        (cons "FUSO" zone)
        (cons "HEMISFERIO" (strcase hemis))
        (cons "DATUM" datum)
      )
    )
  )
)
;;; Help
;;; (GEO->UTM -19.916681 -43.934493 "SIRGAS-2000" 23 "S")
;;; (UTM->GEO 611400.0 7796500.0 23 "S" "SIRGAS-2000")