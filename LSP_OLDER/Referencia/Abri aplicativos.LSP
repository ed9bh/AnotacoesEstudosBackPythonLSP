;;;Abrir um aplicativo

;Explorer
(vl-catch-all-apply'vlax-invoke(list(setq app(vla-getInterfaceObject(vlax-get-acad-object)"Shell.Application"))'Explore"C:\\Users\\Eric\\SkyDrive\\2 - Work"))
(vlax-release-object app)

;DWG
(vl-catch-all-apply'vlax-invoke(list(setq app(vla-getInterfaceObject(vlax-get-acad-object)"Shell.Application"))'open"C:\\Users\\Eric\\SkyDrive\\2 - Work\\DWG\\hypercube.dwg"))
(vlax-release-object app)