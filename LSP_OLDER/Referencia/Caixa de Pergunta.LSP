(setq resposta(vl-catch-all-apply'vlax-invoke-method(list(setq box(vlax-create-object"wscript.shell"))'popup"Sim ou Nao?"0"Teste"(+ 3 32 4096))))
(vlax-release-object box)
resposta

;|
Buttons

Value	Description
0	Display OK button
1	Display OK and Cancel buttons
2	Display Abort, Retry, and Ignore buttons.
3	Display Yes, No, and Cancel buttons.
4	Display Yes and No buttons.
5	Display Retry and Cancel buttons.
6	Display Cancel, Try Again, and Continue buttons.

Icons

Value	Description
16	Display Stop Mark icon.
32	Display Question Mark icon.
48	Display Exclamation Mark icon.
64	Display Information Mark icon.

Other

Value	Description
256	The second button is the default button.
512	The third button is the default button.
4096	The message box is a system modal message box and appears in a topmost window.
524288	The text is right-justified.
1048576	The message and content text display in right-to-left reading order.
|;

;>>>>>>>>>>>>>>>>>>>>>Respostas
;|
Return Values

The following table lists the integer value returned when the associated button is pressed to dismiss the message box.

Value	Description
1	OK button
2	Cancel button
3	Abort button
4	Retry button
5	Ignore button
6	Yes button
7	No button
10	Try Again button
11	Continue button
|;