Objetivo: [Será escrito no Prompt]

Limite e Referências: 
1. Use o conteúdo do arquivo "___Exemplo.txt" (fornecido em anexo/abaixo) como base estrutural.
2. Utilize os padrões de programação limpa e funções Visual LISP do site "https://www.lee-mac.com/programs.html".
3. Referência "https://github.com/ed9bh/AnotacoesEstudosBackPythonLSP/tree/master/2019_Py_LSP/LSP"

Requisitos Estritos:
- O código DEVE declarar todas as variáveis como locais ( / var1 var2 ) para evitar vazamentos na sessão.
- Comente e faça uma pequena descrição do que será feito por aquela função ou loop(repeat, for, foreach, while, lambda, etc.) e enumere os comentários para facilitar o debug; Sub-Função "1.0", Loop "1.1..2..3..".
- Quando usar formulas matematicas de uma intstrução teorica dela em um bloco de comentários("\n" = proxima linha); ";|\n x = x^2-1x*2 \n|;"
- Incluir "(vl-load-com)" na linha seguinte à função principal de chamada.
- Quando não for um AutoLISP exclusivo para Civil 3D, Aplicar compatibilidade total garantida com o ZWCAD / InteliCAD [*Caso não seja possivel, adicionar no Cabeçalho as Limitações*].
- Sub-funções do AutoLISP:
	+ Quando forem totalmente dos meus Exemplos; (defun edg:...
	+ Quando forem totalmente do LeeMac; (defun lm:...
	+ Quando forem totalmente criadas pela IA;
 		* Gemini = (defun iaG:...
   		* ChatGPT = (defun iaCG:...
     	* Claude = (defun iaC:...
	+ Quando for modificação, melhoria, correção, adaptação de uma função minha pela IA; (defun iedg:...
	+ Quando for modificação, melhoria, correção, adaptação de uma função do LeeMac pela IA; (defun ilm:...
	+ Quando forem encontradas totalmente ou parcialmente na internet; (defun iweb:...
- Quando usar comentarios ou '[cite:...]' lembre-se sempre de usar ";" antes.

Saída: Apenas o bloco de código do arquivo ".lsp".

Estrutura Lisp (Algoritmo Base):

	; =====================================================================================================
	; INFORMAÇÕES
	; Objetivo: [Descrição curta]
	; [AAAA/MM/DD] - Elaborador Eric Drumond (ED Serviços & Projetos) - Nome da IA/Versão
	; [Data Revisão] / [Número da Revisão]
	; Exclusividade/Compatibilidade: AutoCAD [ ] / ZWCad [ ] / Civil 3D [ ] / Plant [ ] / Architeture [ ]
	; Referencia Externa: Não [ ] / AutoLisp / DWG(Assets) [ ] / CSV [ ] / TXT [ ] / Excel [ ]
	; DCL: Sim [ ] / Não [ ]
	; =====================================================================================================
	
	(vl-load-com)
	
	Nome do Comando Principal (c:[NOME_DO_LISP])
	      |
	      |
	    *error* (Função de erro customizada. Gerar IDs Alfanuméricos com Data/Hora e registro do sistema. Tentar gerar log na pasta do DWG atual; se não houver permissão de escrita, usar a pasta %TEMP% do sistema).
	      |
	      |
	    SubFunções ; (Com observações e descrições curtas da lógica matemática/geométrica).
	      |
	      |
	    Main ; (Opções, Loops, Repeats, Foreachs, seleção de objetos e Execução de SubFunções).
	      |
	      |
	 Definições iniciais ; (Definir CAD/DOC/Space atuais).
	 Start Undo Mark
	  (Salvar variáveis de ambiente)
	  (Main)
	  (Restauração de Variáveis de ambiente)
	 End Undo Mark
	 Fim (princ)
