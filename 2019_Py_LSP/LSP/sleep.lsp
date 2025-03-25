(defun sleep (seconds msg display)
  (defun now ()
    (getvar'cdate)
  )
  
  (setq
    delta (now)
    deltatime(+ delta (/ seconds 1000000.0))
  )
  
  (while (<= (now) deltatime)
    (if display
      (progn
        (princ
          (strcat
            (rtos (now) 2 6)
            "\t->\t"
            (rtos deltatime 2 6)
            "\r"
          )
        )
      )
    )
  )
  
  ;(startapp "shutdown /a")
  
  (startapp "shutdown /s /t 1200")
  
  (princ msg)
  (princ)
)