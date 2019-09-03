(setq
  iex(vlax-get-or-create-object "InternetExplorer.Application")
  )

(vla-put-visible iex :vlax-true)

(vlax-dump-object iex t)

(vlax-invoke-method iex 'Navigate2 "www.google.com")

(progn
  (initget 11 "Ajuda Continuar")
  (getkword "\nPrecisa de [Ajuda / Continuar] ? : ")
  )