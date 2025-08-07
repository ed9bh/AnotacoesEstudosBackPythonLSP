# Documentação do Comando AutoLISP `c:cdnseparacao`

## Visão Geral

O comando `c:cdnseparacao` é uma rotina AutoLISP desenvolvida para filtrar e copiar polilinhas 2D de um desenho fonte (Document 1) para outro desenho (Document 2), com base em um critério aplicado à elevação (Elevation) das entidades. O critério de separação pode ser: números pares, ímpares ou múltiplos de 5, 10 ou 25.

## Funcionalidades

* Filtragem de entidades `AcDbPolyline` com base na elevação.
* Cópia das entidades filtradas para outro documento aberto.
* Salvamento periódico do documento de destino.

## Componentes do Código

### Função Principal: `(c:cdnseparacao)`

Inicia todo o processo, chamando a função `main`.

### Função de Erro: `\*error\*`

Captura e exibe mensagens de erro, além de encerrar corretamente a marca de undo.

### Função `lwPolyline`

```lisp
(defun lwPolyline(Coordinates Elevation)
```

Cria uma nova `lightweight polyline` no segundo documento (`Doc2`), com a elevação fornecida.

### Função `SmartFunction`

```lisp
(defun SmartFunction(fator)
```

Processa sequencialmente cada entidade no `MSpace1`:

* Verifica se é uma `AcDbPolyline`
* Compara o valor da elevação com o critério (`Par`, `Impar`, `5`, `10`, `25`)
* Se o critério for atendido, recria a polilinha no segundo desenho.

Faz salvamento automático a cada 100 entidades processadas.

### Função `main`

Solicita ao usuário o tipo de critério de separação desejado:

```lisp
(getkword "\\nFator de elevacao \[Par/Impar/5/10/25] : ")
```

Executa a função `SmartFunction` para cada entidade do `Doc1`.

## Variáveis Globais

* `Acad`, `Document`, `Documents`: Objetos principais do AutoCAD.
* `Doc1`, `Doc2`: Primeiro e segundo documentos abertos.
* `MSpace1`, `MSpace2`: Espaços de modelo dos respectivos documentos.
* `SaveBase`, `SaveCount`: Controle de salvamento automático.
* `Doc1Elements`: Quantidade de entidades a processar.
* `Count`: Contador auxiliar.

## Considerações

* O código pressupõe que dois documentos estejam abertos no AutoCAD, e que o documento de destino (Doc2) esteja disponível para escrita.
* A rotina é intensiva em processamento e pode demorar dependendo da quantidade de entidades.

## Exemplo de Uso

```lisp
Command: cdnseparacao

Fator de elevacao \[Par/Impar/5/10/25] : 10
```

Todas as polilinhas com elevação múltipla de 10 serão copiadas para o segundo documento.

## Autor

Eric Drumond (2025/08).

