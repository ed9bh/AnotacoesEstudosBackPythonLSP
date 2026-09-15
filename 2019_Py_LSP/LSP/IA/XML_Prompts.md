---
Empresa: ED Serviços & Projetos LTDA
Documento: Prompts de XML/DXF — devolver geometria ao CAD sem o Civil 3D
Versão: 1.0 — Setembro/2026
Companheiro de: `.agents/.draftmaster/Saida_DXF_XML.md` e `cad/IO_XML.lsp`
Alinhamento: Bloco Base cobre as 15 regras medidas do canal do `IO_XML.lsp`
---

# Prompts de XML do `IO_XML.lsp`

Biblioteca de prompts prontos para **gerar e ler** o dialeto XML do
`IO_XML.lsp` — o canal de volta para o CAD que não depende da API .NET e por
isso vale também em ZWCAD e BricsCAD.

O `LandXML_Prompts.md` te faz independente do Civil 3D para produzir o modelo.
O `IFC_Prompts.md` te faz independente para entregar o BIM. **Este te faz
independente para colocar a geometria de volta no desenho** — que é onde o
trabalho de projeto de fato acontece.

**Cada prompt é autossuficiente.** Todos carregam o Bloco Base (§1), que contém
as regras que, se ignoradas, produzem arquivo errado e plausível. Isso é de
propósito: um prompt colado num chat novo, com um modelo que nunca viu este
repositório, tem de funcionar mesmo assim.

Se o agente **tiver** o repositório, comece mandando ler os dois documentos
longos — eles têm as medições e o porquê de cada regra:

> Leia `.agents/.draftmaster/Saida_DXF_XML.md` e o próprio `cad/IO_XML.lsp`
> antes de começar. Eles são a especificação deste trabalho.

---

## 0. O que este canal faz — e o que não faz

O `IO_XML.lsp` é um round-trip genérico de códigos DXF: exporta com
`entget`/`ssget`, importa com `entmake`. A consequência define tudo:

> **O que o `entmake` cria, este canal transporta. E só isso.**

| Quero | Sai? |
| --- | --- |
| LINE, LWPOLYLINE, POLYLINE 2D e 3D, POINT, CIRCLE, ARC, TEXT, MTEXT, INSERT | **sim** |
| 3DFACE — uma por triângulo | **sim**, e importa até na Rev. 03 |
| Malha poliface — vira 3D SOLID com `CONVTOSOLID` | **sim**, exige a Rev. 04 |
| **3D SOLID direto (ACIS)** | **não.** Geometria proprietária; `entmake` não a cria, nenhuma rotina AutoLISP cria |
| **MESH** (a do `MESHSMOOTH`), superfície NURBS, região | **não** |
| **Property sets** | **não.** Este canal leva geometria e camada; pset é o caminho do IFC |
| **Estilos e tipos de linha novos** | parcial — camada o LSP cria; tipo de linha e estilo de texto ausentes são **descartados**, não criados |

### As duas formas de levar um sólido

| | importa na Rev. 03 | vira sólido |
| --- | :---: | :---: |
| `3DFACE`, uma por triângulo | **sim, sem tocar no LSP** | não — é casca de faces |
| Malha poliface (`POLYLINE` 70=64) | não | **sim**, via `CONVTOSOLID` |

Comece sempre pelo `3DFACE` num arquivo pequeno: prova o canal em um minuto,
sem depender de revisão de LISP nenhuma. Só depois vá para a poliface.

---

## 1. Bloco Base

Cole isto no **início de qualquer** prompt deste canal.

```
CONTEXTO OBRIGATÓRIO — dialeto XML do IO_XML.lsp (round-trip de códigos DXF
via entget/entmake, AutoCAD/ZWCAD/BricsCAD).

Formato:
  <?xml version="1.0" encoding="..."?>
  <AUTOCAD_DRAWING>
   <ENTITIES>
    <ENTITY>
      <DXF code="0"  type="STR">3DFACE</DXF>
      <DXF code="10" type="LIST">303281.6168 7822971.9484 1015.0</DXF>
    </ENTITY>
   </ENTITIES>
  </AUTOCAD_DRAWING>

Regras invioláveis. Ignorar qualquer uma produz arquivo errado e plausível:

1. UMA LINHA POR ELEMENTO. O leitor do LSP (XmlGetAllBlocks) varre o arquivo
   LINHA A LINHA procurando "<ENTITY>", "</ENTITY>" e "<DXF". Elemento
   quebrado em duas linhas SOME sem avisar. Não idente o valor, não quebre
   lista longa.

2. NUNCA NOTAÇÃO CIENTÍFICA. O ParseStr resolve lista com
       (read (strcat "(" str ")"))
       (mapcar '(lambda (v) (if (numberp v) (float v) 0.0)) readVal)
   O read do AutoLISP NÃO entende "1e-05": devolve símbolo, que não é
   número, e a coordenada vira 0.0 SEM ERRO NENHUM. Ponto silenciosamente
   na origem é pior que arquivo que não abre.
   Formate em ponto fixo, 6 casas, e corte zero à direita.

3. QUATRO TIPOS, SÓ. O atributo type é consultado literalmente pelo
   ParseStr: "STR", "INT", "REAL", "LIST". Qualquer outro cai no ramo
   default e é tratado como string.
   LIST = valores separados por espaço (é o formato de ponto 3D: 10, 11,
   12, 13, 210...).

4. A ORDEM DOS CÓDIGOS IMPORTA. O entmake exige o código 0 primeiro e os
   marcadores de subclasse (100) na sequência do esquema: AcDbEntity e
   SÓ DEPOIS a subclasse concreta (AcDbFace, AcDbPolyFaceMesh, AcDbVertex +
   AcDbPolyFaceMeshVertex, AcDbVertex + AcDbFaceRecord...).

5. CÓDIGOS DE IDENTIDADE NÃO SE REESCREVEM: -1, -2, -3, 5, 330, 360, 340,
   390, 410. São identidade e donos do desenho de ORIGEM. O próprio LSP os
   descarta na exportação; reescrevê-los faz o entmake recusar ou criar
   entidade órfã. (Isso também significa que XDATA, código -3, não
   atravessa este canal.)

6. O QUE O ENTMAKE CRIA, ESTE CANAL TRANSPORTA — E SÓ ISSO.
   NÃO existe 3D SOLID (ACIS), MESH, superfície NURBS nem região por aqui.
   Se eu pedir, diga que não dá e proponha malha poliface + CONVTOSOLID.
   NÃO improvise um formato binário dentro do XML.

7. MALHA POLIFACE: LIMITE DURO DE 32.767 VÉRTICES E 32.767 FACES.
   Se estourar, RECUSE em voz alta com os dois números. Não fatie por conta
   própria: fatiar quebra a estanqueidade, que é exatamente o que permite o
   CONVTOSOLID. O remédio é densificar menos.

8. SÓLIDO EXIGE CASCA FECHADA E ORIENTADA. Toda aresta em EXATAMENTE duas
   faces, e faces vizinhas percorrendo a aresta compartilhada em sentidos
   opostos. Verifique as duas coisas ANTES de gravar e me diga o resultado.
   Malha aberta ou incoerente ou não vira sólido, ou vira com volume errado.

9. ÍNDICE DE FACE É BASE 1. No registro de face (VERTEX com 70=128), os
   códigos 71/72/73 (e 74) apontam para a ordem dos vértices começando em
   1, não em 0. Índice NEGATIVO marca aresta invisível — use só se eu
   pedir.

10. ENTIDADE COMPLEXA PRECISA DO SEQEND. POLYLINE e INSERT com atributos
    declaram 66=1 e são seguidos pelas sub-entidades e por um SEQEND.
    Complexa deixada em aberto derruba TODO entmake seguinte, e o erro
    aparece na entidade errada — o pior tipo de erro para diagnosticar.

11. DIGA PARA QUAL REVISÃO DO LSP ESTÁ GERANDO.
    Rev. 03: o ramo de sub-entidades só dispara para POLYLINE com 70=8
    (polilinha 3D) e recria cada vértice com apenas (10 ...) e (70 . 32).
    Poliface, polilinha 2D, bulge, larguras e INSERT+ATTRIB não passam.
    Rev. 04: o teste virou (assoc 66) = 1 e a sub-entidade é recriada com
    a lista DXF inteira. Se você não sabe a revisão, gere 3DFACE, que passa
    nas duas.

12. CODIFICAÇÃO. O AutoLISP grava ANSI (cp1252) declarando UTF-8 — defeito
    dele. Na LEITURA ele não olha a declaração, só varre a string. Portanto
    UTF-8 funciona, mas EVITE acento em nome de camada e de estilo.

13. COR VERDADEIRA (420), NÃO ÍNDICE (62). A paleta do escritório é
    hexadecimal e o índice de 256 cores não tem esses tons; aproximar troca
    o padrão por um vizinho sem avisar.
        420 = (R << 16) | (G << 8) | B
        440 = 0x02000000 | round(255 * (1 - alfa))     [transparência]

14. ESCAPE: SÓ AS CINCO ENTIDADES XML. O UnescapeXML do LSP desfaz
    &amp; &lt; &gt; &quot; &apos; — essas e só essas.
    E NÃO confunda com os escapes do AutoCAD DENTRO do texto: %%d (grau),
    %%c (diâmetro), %%p (mais-menos), %%% (por cento) são do CAD, não do
    XML, e passam literais.

15. COORDENADA AQUI É (X=ESTE, Y=NORTE, Z=COTA) — ao contrário do LandXML,
    que é (Norte, Este, Cota). Se o dado veio de LandXML, troque NA HORA DE
    GRAVAR, não na leitura. Inverter joga o desenho para fora da zona UTM.

Se algo contrariar estas regras, PARE e me diga. Não adivinhe.
```

---

## 2. Auditar um XML exportado do CAD

Use quando alguém te manda um XML do `EXPORTXML` e você precisa saber o que
tem dentro antes de confiar nele.

```
[BLOCO BASE]

TAREFA: auditar o XML em anexo e me dar um relatório. Não conserte nada.

Escreva um script Python (só biblioteca padrão; o formato é linha a linha,
não precisa de parser XML).

INVENTÁRIO
- total de <ENTITY>
- contagem por tipo (código 0), da mais frequente para a menos
- entidades complexas: quantas declaram 66=1, e se cada uma tem SEQEND
- camadas usadas (código 8) e quantas entidades em cada
- cores: quantas com 62, quantas com 420, quantas sem nenhuma
- tipos de linha (6) e estilos de texto (7) referenciados

SANIDADE DO DIALETO
- algum <DXF> partido em mais de uma linha?
- algum valor em notação científica? (liste os primeiros 10 — cada um vira
  0.0 na importação)
- algum type fora de STR/INT/REAL/LIST?
- algum código de identidade presente (-1,-2,-3,5,330,340,360,390,410)?
- caracteres fora do cp1252 em nome de camada, estilo ou texto

GEOMETRIA
- extensão (mín/máx de X, Y, Z) de todos os pontos encontrados
- as coordenadas parecem UTM? (X ~ 100.000-900.000, Y ~ 0-10.000.000)
- para cada malha poliface: nº de vértices declarado (71) × contado,
  nº de faces declarado (72) × contado, e se algum índice 71/72/73 aponta
  fora da faixa 1..nº de vértices

VEREDITO
Liste o que impediria a importação e o que exige decisão minha.
```

---

## 3. Exportar sólido de terraplenagem

O caso principal: o corpo entre duas superfícies, para virar 3D SOLID no
desenho.

```
[BLOCO BASE]

TAREFA: gerar o XML do IO_XML.lsp com os sólidos em anexo.

ENTRADA: [malha (P, F) por sólido | dois LandXML, terreno e projeto]
REVISÃO DO LSP: [Rev. 04 -> malha poliface | Rev. 03 ou não sei -> 3DFACE]
PREFIXO DE CAMADA: <ex.: ED>

Se a entrada for duas superfícies: use a triangulação da superfície de
PROJETO como pegada (é a menor, e é o que define o limite), amostre o
terreno nos vértices dela, recorte na linha de passagem dz = 0 e feche cada
região com topo, base espelhada e parede na borda.
Tolerância de serviço 0,02 m: abaixo disso não há terraplenagem, é ruído
entre duas superfícies que quase coincidem.

DENSIFICAÇÃO: aresta máxima <ARESTA, padrão 8.0> m.
Não é escolha de precisão, é o limite da regra 7. Medido no caso de
referência: a 4 m o corpo sai com 47.579 vértices e NÃO CABE; a 8 m sai com
12.221 e o volume erra 0,04% contra o método da grade.
Se a malha estourar o limite, PARE e me diga os números — não fatie.

CAMADAS E CORES (regra 13)
  <PREFIXO>-TER-3D-CORTE    verde limão #B0D400, alfa 0,35
  <PREFIXO>-TER-3D-ATERRO   rosa        #F0629B, alfa 0,35
Emita o registro de tabela LAYER de cada uma ANTES das entidades, para a
camada nascer com a cor certa. Se ela já existir no desenho, o entmake
devolve nil e o LSP segue — degradação aceitável.

ANTES DE GRAVAR, me mostre uma tabela com, por sólido:
  operação | volume (m³) | vértices | faces | casca fechada? | orientada?
O volume é o do teorema da divergência, com os vértices centrados no
centroide antes de somar — em coordenada UTM os termos chegam a 1e20 e
precisam cancelar até 1e3; sem centrar, o volume erra ~0,1% sem sintoma.

Termine dizendo, em uma linha, o que eu faço no CAD:
APPLOAD do IO_XML.lsp -> IMPORTXML -> CONVTOSOLID -> MASSPROP para conferir
o volume contra a sua tabela.
```

---

## 4. Exportar superfície como malha

Terreno, projeto, superfície intermediária — para enxergar e para cortar.

```
[BLOCO BASE]

TAREFA: gerar o XML do IO_XML.lsp com a superfície em anexo.

ENTRADA: [LandXML | CSV de pontos | OBJ/PLY]
NOME DA CAMADA: <ex.: ED-GER-3D-TOPOGRAFIA>
COR: <ex.: #2E7D32 verde, para MDT>

Superfície é malha ABERTA. Portanto:
( ) 3DFACE — o padrão. Casca de faces, importa em qualquer revisão do LSP.
( ) Casca com espessura <E, ex. 0,5> m — placa fina acompanhando o relevo,
    fechada, que pode virar sólido. O volume dela NÃO significa nada; não
    o reporte como quantitativo.

Se a origem for LandXML: exclua as faces com i="1" (não integram a
superfície) e TROQUE a ordem das coordenadas na gravação — o LandXML é
(N, E, Z) e o DXF é (X=E, Y=N, Z) (regra 15).

CUIDADO COM O TAMANHO. Uma superfície de levantamento passa fácil dos
32.767 vértices. Se for malha poliface e estourar, me diga o número e
sugira: (a) 3DFACE, que não tem limite de entidade, ou (b) recortar a
superfície na área de interesse antes de exportar.

Reporte antes de gravar: pontos, faces, extensão, tamanho estimado do
arquivo em MB.
```

---

## 5. Exportar eixo, contorno e linha de passagem

```
[BLOCO BASE]

TAREFA: gerar o XML do IO_XML.lsp com as polilinhas em anexo.

ENTRADA: [LandXML com Alignment | CSV norte;este;cota | lista de pontos]

FORMA: POLYLINE 3D — cabeçalho com 66=1 e 70=8 (some 1 se fechada),
sub-entidades VERTEX com 70=32, e SEQEND.
Esse é o ÚNICO ramo que o ImportEntities já trata desde a Rev. 03, então
polilinha 3D funciona em qualquer versão.

ATENÇÃO na Rev. 03: aquele ramo recria cada vértice com apenas (10 ...) e
(70 . 32). Camada e cor do VÉRTICE se perdem — o que não faz falta, porque
quem manda na aparência é o cabeçalho. Mas BULGE (42) e larguras (40/41)
também se perdem: se a polilinha tiver arco, ele volta RETO.
Se eu pedir arco, avise disso e me pergunte a revisão antes de gerar.

Se a origem for um Alignment do LandXML com <Curve>, discretize o arco em
segmentos com flecha máxima de <FLECHA, padrão 0,01> m e me diga quantos
pontos gerou por curva. Não tente reproduzir a curva com bulge sem eu
confirmar a Rev. 04.

CAMADA E COR por tipo de obra:
  acesso/estrada #E53935 · drenagem #1E88E5 · ferrovia #F57C00 ·
  pipeline #303F9F · demais #1A1A1A
```

---

## 6. Ler um XML do CAD de volta para dados

O caminho inverso: alguém exportou entidades do desenho e você quer os
números.

```
[BLOCO BASE]

TAREFA: extrair do XML em anexo, para CSV (separador ponto e vírgula,
decimal com vírgula, cabeçalho em português).

[escolha]
( ) pontos: entidade;camada;x;y;z
( ) polilinhas: id;camada;vertice;x;y;z    (uma linha por vértice)
( ) textos: camada;x;y;altura;rotacao;conteudo
( ) blocos: nome;camada;x;y;z;escala_x;escala_y;rotacao
( ) malhas: id;camada;vertices;faces;volume;fechada
( ) tabela de camadas: nome;cor_indice;cor_rgb;tipo_linha

REGRAS DA LEITURA
- entidade complexa: o cabeçalho e as sub-entidades são <ENTITY> SEPARADOS
  e CONSECUTIVOS, terminando em SEQEND. Agrupe por essa sequência, não por
  aninhamento — não há aninhamento.
- desescape as cinco entidades XML, e deixe %%d, %%c, %%p e %%% como estão
  ou traduza para °, Ø, ± e % — me diga qual você fez.
- coordenada aqui é (X=Este, Y=Norte). Se eu pedir saída para LandXML ou
  para relatório topográfico, INVERTA e rotule as colunas como norte/este.

Se algum valor vier em notação científica, ele já foi lido como 0.0 pelo
LSP na ida — me avise, porque significa que o arquivo veio de um gerador
que não respeita a regra 2.
```

---

## 7. Converter outro formato para o dialeto

```
[BLOCO BASE]

TAREFA: converter o arquivo em anexo para o XML do IO_XML.lsp.

ORIGEM: [DXF | LandXML | IFC | OBJ/PLY/STL | CSV]
REVISÃO DO LSP: [Rev. 04 | Rev. 03 / não sei]

PASSOS
1. Reporte o que encontrou: entidades ou malhas, pontos, faces, extensão,
   unidade e sistema de coordenadas se houver.
2. DIGA-ME em que ordem estão as coordenadas na origem e confirme comigo
   antes de gravar (regra 15). LandXML é (N,E,Z); DXF, IFC, OBJ e STL são
   (X,Y,Z) com X=Este. Essa troca é o erro mais comum da conversão e o
   sintoma é o desenho aparecer fora da zona UTM.
3. Para cada entidade da origem, escolha o equivalente que o entmake sabe
   criar. Se não houver equivalente (sólido ACIS, MESH, NURBS, região),
   NÃO improvise: liste o que não converte e me pergunte o que fazer.
4. Malha fechada -> poliface (Rev. 04) ou 3DFACE (Rev. 03). Malha aberta ->
   3DFACE. Diga qual escolheu e por quê.
5. Se a origem tiver unidade em pés ou milímetros, converta para metro e me
   diga o fator.
6. AUTOTESTE: releia o XML que você acabou de gravar com um leitor que imite
   o XmlGetAllBlocks + ParseStr do LSP — INCLUSIVE nos defeitos deles, isto
   é, trocando por 0.0 tudo que o read do AutoLISP não leria como número.
   Remonte a geometria e compare com a origem. Me mostre o resultado.

Esse autoteste é o ponto inteiro do exercício: sem ele você está apostando
que o LSP lê o que você escreveu, e a regra 2 existe justamente porque essa
aposta já foi perdida uma vez.
```

---

## 8. Criar as camadas do padrão

```
[BLOCO BASE]

TAREFA: gerar um XML só com registros de tabela LAYER, para eu importar uma
vez e ter as camadas do padrão no desenho.

ESTRUTURA de cada registro:
  0=LAYER, 100=AcDbSymbolTableRecord, 100=AcDbLayerTableRecord,
  2=nome, 70=0, 6=Continuous, 62=7, 420=cor verdadeira,
  440=transparência (só onde houver), 300=descrição

CAMADAS: <cole a lista: nome;cor_hex;alfa;descrição>

Nome de camada SEM ACENTO (regra 12).

Se a camada já existir no desenho, o entmake devolve nil e o LSP anota no
log — não é erro, é a cor que o desenhista escolheu prevalecendo. Diga isso
no seu resumo para eu não achar que falhou.

Não emita LTYPE nem STYLE junto: o LSP DESCARTA o código 6 e o 7 quando o
recurso não existe, em vez de criá-lo, então tipo de linha e estilo de texto
têm de já estar no desenho.
```

---

## 9. Diagnosticar "importei e não apareceu nada"

```
[BLOCO BASE]

TAREFA: o arquivo em anexo foi importado com IMPORTXML e o resultado não
foi o esperado. Diagnostique.

SINTOMA: <descreva — nada apareceu / apareceu na origem do desenho /
polilinha sem vértices / malha não vira sólido / arco virou reta /
importou mas o CONVTOSOLID recusa>

Percorra as causas nesta ordem, que é a da frequência medida:

1. NOTAÇÃO CIENTÍFICA (regra 2). Procure /\de[+-]?\d/ nos valores. Cada
   ocorrência virou 0.0. Sintoma clássico: geometria correta com um ou
   mais pontos na origem, ou tudo na origem.

2. ELEMENTO PARTIDO EM DUAS LINHAS (regra 1). Sintoma: entidade com menos
   códigos do que devia; ponto faltando; o LSP relata menos entidades
   criadas do que há <ENTITY> no arquivo.

3. REVISÃO DO LSP (regra 11). Se há POLYLINE que não seja 70=8, ou INSERT
   com ATTRIB, e o LSP é Rev. 03, as sub-entidades não entram. Sintoma:
   polilinha sem vértices, malha ausente, atributo órfão.

4. SEQEND FALTANDO (regra 10). Sintoma: a entidade complexa e TODAS as
   seguintes falham. O erro aparece na entidade errada.

5. ORDEM DOS CÓDIGOS (regra 4) ou marcador 100 fora de sequência.
   Sintoma: o LSP registra "Falha entmake" no LogReport ao lado do DWG.

6. CAMADA CONGELADA OU DESLIGADA, ou a geometria está fora da vista.
   Rode um ZOOM Extents mental: compare a extensão do arquivo com a do
   desenho e me diga se batem.

7. MALHA NÃO ESTANQUE (regra 8). Só para "não vira sólido": conte as
   arestas usadas por uma face só. Se houver, o CONVTOSOLID recusa — com
   razão.

Para cada causa, diga: encontrei / não encontrei, com a evidência. Leia o
LogReport ao lado do DWG se eu anexar.
```

---

## 10. Validar antes de importar

```
[BLOCO BASE]

TAREFA: validar o XML que vou anexar, como se fosse importá-lo num desenho
de cliente. Percorra a lista e responda item a item com OK ou o problema.

DIALETO
[ ] cada <DXF> em uma linha só
[ ] nenhum valor em notação científica
[ ] type sempre STR, INT, REAL ou LIST
[ ] só as cinco entidades XML escapadas
[ ] nenhum código de identidade (-1,-2,-3,5,330,340,360,390,410)
[ ] nomes de camada e estilo sem acento

ENTIDADES
[ ] código 0 é o primeiro de toda <ENTITY>
[ ] marcadores 100 em sequência: AcDbEntity antes da subclasse concreta
[ ] toda entidade com 66=1 é seguida de sub-entidades e de um SEQEND
[ ] nenhum SEQEND solto, sem entidade complexa aberta antes
[ ] nenhum tipo que o entmake não crie (3DSOLID, MESH, SURFACE, REGION)

MALHA POLIFACE
[ ] 71 do cabeçalho == nº de VERTEX com 70=192
[ ] 72 do cabeçalho == nº de VERTEX com 70=128
[ ] ambos <= 32767
[ ] todo índice 71/72/73 dentro de 1..71_do_cabeçalho
[ ] casca fechada: toda aresta em exatamente duas faces
[ ] orientação coerente entre faces vizinhas
[ ] volume positivo pela divergência, com os vértices centrados no centroide

GEOMETRIA
[ ] extensão compatível com a zona UTM esperada
[ ] X=Este e Y=Norte, não o contrário

ROUND-TRIP
[ ] releitura com um leitor que imite o ParseStr (defeitos inclusive)
    remonta a geometria e devolve o mesmo volume/extensão

VEREDITO: "pronto para importar" ou a lista do que impede, e em qual
revisão do LSP.
```

---

## 11. Ressalva para arquivo gerado

Enquanto um tipo de saída novo não tiver sido importado **uma vez** dentro do
CAD, entregue o arquivo com esta ressalva junto:

> Arquivo gerado fora do CAD. Geometria conferida por ida e volta em leitor
> que reproduz o `XmlGetAllBlocks` e o `ParseStr` do `IO_XML.lsp`, defeitos
> inclusive: a malha remonta e o volume confere. A importação no AutoCAD e a
> conversão por `CONVTOSOLID` ainda não foram confirmadas para este tipo de
> saída.

Depois da primeira confirmação, apague a última frase — e anote em
`Saida_DXF_XML.md` qual versão do CAD e qual revisão do LSP confirmaram,
porque a resposta pode mudar entre as duas.

Vale insistir num ponto: **o autoteste não substitui a importação**. Ele
prova que o arquivo diz o que você quis dizer. Se o `entmake` aceita o que o
arquivo diz, só o CAD responde.

---

## 12. Como pedir bem

Quatro hábitos que mudam o resultado, independentes de qual prompt você use:

**Diga a revisão do LSP logo no começo.** É a pergunta que muda mais coisa
neste canal — malha poliface, polilinha 2D, bulge e `INSERT` com atributo
dependem dela. Na dúvida, peça `3DFACE`: passa nas duas.

**Peça a tabela de conferência junto do arquivo.** Volume, vértices, faces e
"casca fechada?" por sólido custam uma linha de código e são o que você
compara com o `MASSPROP` depois. Sem isso, você importou e não sabe.

**Exija o autoteste que imita os defeitos do leitor.** Um round-trip com um
parser XML honesto não prova nada aqui: o `ParseStr` do LSP é *menos* capaz
que um parser honesto, e é a diferença entre os dois que engole coordenada.

**Prove o canal com um arquivo pequeno antes do grande.** Um `3DFACE` de
mil faces importa em segundos e responde a pergunta que importa — o LSP
carrega, a camada nasce, a geometria cai no lugar certo. Só então mande o de
17 MB, que leva minutos de leitura linha a linha em AutoLISP.

---

## 13. Os números medidos, para calibrar expectativa

Corpo de terra da ensecadeira (MDT de 46.512 faces, MDP de 726):

| `aresta_max` | maior peça | volume do aterro | cabe na poliface? | arquivo |
| :--- | ---: | ---: | :---: | ---: |
| `None` | 888 v / 1.772 f | 12.647,15 m³ (−0,94%) | sim | 1,4 MB |
| **8,0 m** | **12.221 v / 24.438 f** | **12.767,07 m³ (−0,04%)** | **sim** | **16,6 MB** |
| 4,0 m | 47.579 v / 95.154 f | 12.771,80 m³ | **não** | — |

Referência independente pelo método da grade: 12.774,12 m³.

O salto de tamanho entre 1,4 MB e 16,6 MB é real e importa: o leitor do LSP
é AutoLISP linha a linha. Para conferir a forma, use a versão leve; para
número de orçamento, a de 8 m.

---
*ED Serviços & Projetos LTDA — companheiro de `Saida_DXF_XML.md` e `cad/IO_XML.lsp`*
