; Property values:
;   Application (RO) = #<VLA-OBJECT IAeccApplication 000001ab0464b370>
;   CodeSetStyleName = "Basic"
;   Description = ""
;   DisplayName (RO) = "Acesso.TransicaoPisTalA"
;   Document (RO) = #<VLA-OBJECT IAeccDocument 000001ab0464c8f0>
;   EntityTransparency = "ByLayer"
;   Handle (RO) = "1E0FB"
;   HasExtensionDictionary (RO) = 0
;   Hyperlinks (RO) = #<VLA-OBJECT IAcadHyperlinks 000001a337c10a08>
;   Layer = "0"
;   Linetype = "ByLayer"
;   LinetypeScale = 1.0
;   Lineweight = -1
;   Material = "ByLayer"
;   Name = "Acesso.TransicaoPisTalA"
;   ObjectID (RO) = 52
;   ObjectName (RO) = "AeccDbAssembly"
;   OwnerID (RO) = 43
;   PlotStyleName = "Color_3"
;   Position (RO) = #<VLA-OBJECT IAeccPoint3d 000001ab0464c770>
;   ShowToolTip = -1
;   TrueColor = #<VLA-OBJECT IAcadAcCmColor 000001a337c10ca0>
;   Visible = -1
; Methods supported:
;   ArrayPolar (3)
;   ArrayRectangular (6)
;   Copy ()
;   Delete ()
;   GetBoundingBox (2)
;   GetExtensionDictionary ()
;   GetXData (3)
;   Highlight (1)
;   IntersectWith (2)
;   IsReferenceObject ()
;   IsReferenceStale ()
;   IsReferenceSubObject ()
;   IsReferenceValid ()
;   Mirror (2)
;   Mirror3D (3)
;   Move (2)
;   Rotate (2)
;   Rotate3D (3)
;   ScaleEntity (2)
;   SetXData (2)
;   TransformBy (1)
;   Update ()

;(0 . "AECC_ASSEMBLY")

; IAeccPoint3d: IAeccPoint3d Interface
; Property values:
;   X = 751878.0
;   Y = 7.83731e+06
;   Z = 0.0
; Methods supported:
;   GetPoint (3)
;   SetPoint (3)

;(vlax-dump-object(vlax-get(vlax-ename->vla-object(car(entsel)))'Position)t)

(defun c:tagassembly()
  (setq
    assemblyList(ssget"x"'((0 . "AECC_ASSEMBLY")))
    model(vla-get-modelspace(vla-get-activedocument(vlax-get-acad-object)))
    )
  (foreach x (ssnamex assemblyList)
    (progn
      (setq
	vlao(vlax-ename->vla-object(cadr x))
	name(vlax-get vlao 'Name)
	pX(vlax-get(vlax-get vlao 'Position)'X)
	pY(vlax-get(vlax-get vlao 'Position)'Y)
	pos(vlax-3d-point (list px (+ py 3)))
	)
      (setq vlao(vla-addtext model name pos 1))
      (vla-put-alignment vlao acAlignmentBottomCenter)
      (vla-put-textalignmentpoint vlao pos)
      )
    )
  (princ)
  )