---
Empresa: ED Serviços & Projetos LTDA
Documento: Prompts de IFC — produzir e auditar modelo BIM com IA
Versão: 1.0 — Setembro/2026
Companheiro de: ".agents/.skills/IFC.md"
---

# Prompts de IFC

Biblioteca de prompts prontos para ler, auditar, gerar e alterar IFC com IA.

**Cada prompt é autossuficiente**: carrega o Bloco Base (§1) com as regras que,
se ignoradas, produzem arquivo válido que não abre no destino, ou que abre e
mente. Funciona colado num chat novo, com um modelo que nunca viu este
repositório.

Se o agente tiver o repositório:

> Leia `.agents/.skills/IFC.md` antes de começar. Ele é a especificação deste
> trabalho.

---

## 0. Antes de qualquer prompt: decida o destino

Essa é a única decisão que você **tem** de tomar, porque o arquivo muda inteiro.

| Destino | Diga no prompt |
| --- | --- |
| AutoCAD, Civil 3D, Navisworks | `PERFIL: COMPATIBILIDADE` |
| Visualizador IFC4 nativo, BIM 360, Solibri recente | `PERFIL: IFC4` |
| Não sei / vou distribuir | `PERFIL: COMPATIBILIDADE` |

Na dúvida, compatibilidade. O arquivo fica ~10× maior e abre em todo lugar.

---

## 1. Bloco Base

Cole no **início de qualquer** prompt de IFC.

```
CONTEXTO OBRIGATÓRIO — IFC4 em IFC-SPF (ISO-10303-21), destino de engenharia
de infraestrutura (terraplenagem, drenagem, acessos).

PERFIL: <COMPATIBILIDADE | IFC4>

  COMPATIBILIDADE (AutoCAD, Civil 3D, Navisworks):
    - geometria: IfcFacetedBrep sobre IfcClosedShell (sólido) ou
      IfcShellBasedSurfaceModel sobre IfcOpenShell (superfície)
    - RepresentationType: 'Brep' ou 'SurfaceModel'
    - FILE_DESCRIPTION: 'ViewDefinition [CoordinationView_V2.0]'
    - classes: IfcBuildingElementProxy para tudo
    - coordenadas ABSOLUTAS (UTM), IfcMapConversion com offset zero

  IFC4 (visualizador nativo):
    - geometria: IfcTriangulatedFaceSet
    - RepresentationType: 'Tessellation'
    - FILE_DESCRIPTION: 'ViewDefinition [ReferenceView_V1.2]'
    - classes: IfcGeographicElement, IfcEarthworksCut/Fill quando couber
    - geometria local + IfcMapConversion com o offset real

Regras invioláveis nos dois perfis:

1. MVD COERENTE COM A GEOMETRIA. ReferenceView EXIGE tesselação. Declarar
   uma e escrever a outra faz o importador desistir SEM MENSAGEM.

2. RepresentationType TEM DE DESCREVER O ITEM. 'Tessellation' com um
   IfcFacetedBrep dentro é outra forma de falhar em silêncio.

3. SÓ CASCA FECHADA VIRA 3D SOLID. Casca aberta importa como superfície, e
   superfície NÃO recebe property set. Uma TIN é aberta — tem borda.

4. FECHADA = DUAS CONFERÊNCIAS, NÃO UMA:
   (a) paridade: toda aresta em exatamente duas faces;
   (b) coerência: toda aresta compartilhada percorrida em sentidos OPOSTOS
       pelas duas faces.
   A (a) sozinha não pega orientação invertida — medido, um sólido dava
   833 m³ onde o correto era 500.

5. VOLUME EM COORDENADA UTM: centre no centroide antes de somar. O teorema
   da divergência é invariante a translação na matemática, não em double.
   Com Norte ~ 7,8 milhões, o erro chega a 0,1% vindo só da aritmética.

6. TRANSPARÊNCIA É O INVERSO DO ALFA.
   IfcSurfaceStyleShading.Transparency: 0 = opaco, 1 = transparente.
   Transparency = 1 - alfa. Alfa 0,35 vira 0.65. Opaco sai como $.

7. REAL PRECISA DE PONTO NA MANTISSA. '1.E-11' é REAL, '1e-11' NÃO É.
   repr() do Python entrega a forma inválida para 1e-11, 3e-05, 1e+16.
   Corrija: se há expoente e a mantissa não tem ponto, insira.

8. TEXTO NÃO-ASCII É ESCAPADO: \X\HH (latin-1) e \X2\HHHH\X0\ (UTF-16BE).
   Apóstrofo dobra. DESESCAPE na leitura — senão
   'INTERFER\X\CANCIAS' e 'INTERFERÊNCIAS' viram dois psets distintos.

9. GUID É 22 CARACTERES em base 64 com alfabeto PRÓPRIO:
   0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_$
   Termina em _$, não em +/. Não use base64 padrão.

10. HIERARQUIA: IfcProject -IfcRelAggregates-> IfcSite
    -IfcRelContainedInSpatialStructure-> elementos.
    São relações DIFERENTES. Sem o IfcRelAggregates o sítio é órfão.

11. CAMPO SEM VALOR: OMITA, nunca escreva zero. Zero num pset é
    indistinguível de medida real de zero e vira quantidade na planilha.

Se algo contrariar estas regras, PARE e me diga. Não adivinhe.
```

---

## 2. Auditar um IFC recebido

```
[BLOCO BASE]

TAREFA: auditar o IFC em anexo com ifcopenshell e me dar um relatório.

IDENTIFICAÇÃO
- schema, MVD declarada no FILE_DESCRIPTION, exportador, data
- contagem por tipo de entidade (as 15 mais frequentes)
- hierarquia espacial: Project -> Site? -> Building? -> elementos
- CRS (IfcProjectedCRS) e IfcMapConversion — o EPSG é válido?

COERÊNCIA (é aqui que mora o defeito)
- a MVD declarada combina com a geometria usada?
- todo IfcShapeRepresentation tem RepresentationType coerente com o Item?
- há classe que só existe no IFC4 (IfcGeographicElement, IfcEarthworks*,
  IfcCourse)? liste — elas SOMEM em importador antigo, sem erro
- as coordenadas são absolutas ou locais? se locais, o IfcMapConversion
  reconstitui a coordenada de projeto?

POR PRODUTO
- nome, classe, ObjectType, PredefinedType
- tem representação? qual item geométrico? quantos triângulos?
- a casca é fechada (paridade E coerência de orientação)?
- volume geométrico, calculado com os vértices CENTRADOS NO CENTROIDE
- tem IfcStyledItem? cor em hexadecimal e transparência
- property sets: nome, campos, tipos e valores

CONFERÊNCIA CRUZADA
- para cada elemento com pset de volume: volume da GEOMETRIA × volume
  DECLARADO no pset. Divergência acima de 1% é achado, reporte.
- sólidos de volume nulo ou quase nulo (medido em arquivo de produção:
  7,85e-13 m³)
- GUIDs duplicados
- elementos sem representação: são pset-only de propósito ou geometria
  perdida?

VEREDITO
Liste o que impede este arquivo de abrir no AutoCAD, se for o caso, e o que
exige decisão humana.

Não conserte nada. Só reporte.
```

---

## 3. Diagnosticar "não importa no AutoCAD"

```
[BLOCO BASE]

TAREFA: o IFC em anexo não entra pelo IFCIMPORT do AutoCAD. Diagnostique.

Verifique, nesta ordem, e me diga qual(is) se aplica(m):

1. GEOMETRIA. Usa IfcTriangulatedFaceSet? O importador do AutoCAD não lê
   tesselação IFC4. Tem de ser IfcFacetedBrep ou IfcShellBasedSurfaceModel.

2. MVD. FILE_DESCRIPTION declara ReferenceView_V1.2? ReferenceView exige
   tesselação; com B-rep dentro, o importador desiste calado. Tem de ser
   CoordinationView_V2.0.

3. CLASSES. Há IfcGeographicElement, IfcEarthworksCut, IfcEarthworksFill,
   IfcCourse? São IFC4 puro. Importador que não reconhece a classe não dá
   erro: SOME com o elemento.

4. COORDENADA. A geometria está em coordenada local com o deslocamento só
   no IfcMapConversion? Importador que ignora o MapConversion deposita o
   modelo a centenas de quilômetros — sintoma idêntico a "não importou".
   Diga onde o modelo cairia: dê a caixa envolvente COMO ESTÁ no arquivo.

5. ESTRUTURA. IfcProject -> IfcSite ligado por IfcRelAggregates? Elementos
   ligados por IfcRelContainedInSpatialStructure?

6. SINTAXE. Algum REAL sem ponto na mantissa (1e-11, 3e-05)? Algum GUID
   fora do alfabeto de 64 do IFC? Alguma string com ; não escapado?

Para cada item que falhar, diga o que trocar. Depois me pergunte se quero
que você gere a versão corrigida.
```

---

## 4. Converter o IFC para o perfil de compatibilidade

```
[BLOCO BASE]
PERFIL: COMPATIBILIDADE

TAREFA: reescrever o IFC em anexo para abrir no AutoCAD/Civil 3D,
preservando geometria, cor e property sets.

CONVERSÕES
- IfcTriangulatedFaceSet -> IfcFacetedBrep (casca fechada) ou
  IfcShellBasedSurfaceModel (casca aberta). PERGUNTE À GEOMETRIA qual é:
  conte as arestas, não acredite no que o arquivo diz.
- RepresentationType -> 'Brep' ou 'SurfaceModel', conforme o item
- FILE_DESCRIPTION -> 'ViewDefinition [CoordinationView_V2.0]'
- classes IFC4-only -> IfcBuildingElementProxy, com o sentido preservado no
  ObjectType e no property set. O PredefinedType da classe original não
  vale no proxy: use .NOTDEFINED.
- coordenadas -> absolutas; IfcMapConversion com offset zero e CRS mantido

PRESERVE
- todos os property sets, campo a campo, com os tipos originais
- todos os IfcStyledItem (cor e transparência)
- os GUIDs dos elementos que já existiam — NÃO gere GUID novo para eles.
  O GUID é a identidade do objeto entre revisões.

ANTES E DEPOIS: tabela com nº de produtos, nº de triângulos por produto,
volume de cada sólido e tamanho do arquivo.

AUTOTESTE: abra o arquivo gerado com ifcopenshell e confirme zero erro de
esquema, geometria carregando, e volumes iguais aos do original dentro de
0,01%.
```

---

## 5. Gerar modelo de terraplenagem a partir de superfícies

```
[BLOCO BASE]
PERFIL: COMPATIBILIDADE

TAREFA: gerar um IFC de terraplenagem a partir das duas superfícies em
anexo (LandXML ou malha).

TERRENO (base): <arquivo/nome>
PROJETO (topo): <arquivo/nome>
CRS: <ex.: EPSG:31983 — SIRGAS 2000 / UTM 23S>
TIPO DE OBRA: <maciço | estrada | drenagem | ferrovia | pipeline>

O QUE EMITIR
1. TERRENO como sólido: dê espessura constante de <0,50> m — rebaixe a
   malha, feche as laterais. É uma placa fina que acompanha o relevo. O
   volume dela não significa nada e NÃO vai para pset de terraplenagem.
2. CORPO DE TERRA recortado na linha de passagem (dz = 0): corte e aterro
   viram sólidos INDEPENDENTES, um por região conexa.
   Onde dz = 0, topo e base são o mesmo ponto — solde os vértices e a
   linha de passagem fecha o sólido sem precisar de parede.
3. Cada sólido com property set 01_GERAL e 08_TERRAPLENAGEM.

DUAS DECISÕES DE ENGENHARIA, que são suas e não do algoritmo:
- TOLERÂNCIA DE SERVIÇO: <0,02> m. Diferença menor que isso não é corte nem
  aterro — está dentro da tolerância do levantamento e da execução. Sem ela
  o ruído entre superfícies que quase coincidem enche o modelo de lascas.
- ARESTA MÁXIMA da malha do corpo: <4,0> m. O terreno é amostrado nos
  vértices da superfície de PROJETO; se ela for muito mais grossa que a de
  terreno, o volume erra. Densifique de forma UNIFORME (1 para 4, em
  rodadas) — adaptativa deixa junção em T e parte a região em pedaços
  falsos.

CORES (padrão do escritório)
  terreno #2E7D32 opaco · corte #B0D400 alfa 0,35 · aterro #F0629B alfa 0,35
  Lembre da regra 6: Transparency = 1 - alfa.

O VOLUME DO PSET É O DO SÓLIDO, não o de um cálculo paralelo. O que eu medir
no CAD tem de ser o que a propriedade declara.

RELATÓRIO OBRIGATÓRIO antes de me entregar:
- por sólido: fechada? orientação coerente? volume
- soma por operação × volume pelo método da grade, com a diferença em %
- se a diferença passar de 1%, PARE e me diga
```

---

## 6. Gerar property sets a partir de cálculo

```
[BLOCO BASE]

TAREFA: preencher os property sets dos elementos do IFC em anexo a partir
dos números em <planilha/tabela anexa>.

ESQUEMA (use exatamente esta grafia, inclusive as inconsistências):
  01_GERAL: 00_LAYER, 01_ID, 02_DESCRICAO, 03_DISCIPLINA, 04_SET
  08_TERRAPLENAGEM: 00_LAYER, 01_TIPO, 04_MATERIAL, 05-AREA, 06_VOLUME,
    09_COTA-MAXIMA, 10_COTA-MINIMA, 11_ALTURA, 12_COMPRIMENTO, 13_LARGURA,
    14_DECLIVIDADE, 15_TALUDE-ALTURA, 16_TALUDE-SLOPE
  09_DRENAGEM: 00_LAYER, 01_TIPO, 02_GEOMETRIA, 05_MATERIAL, 06-AREA,
    07_VOLUME, 08_COTA_INICIO_TOPO, 09_COTA_FIM_FUNDO, 12_EXTENSAO,
    13_ESPESSURA, 14_LARGURA, 15_COMPRIMENTO, 16_ALTURA, 17_DEC-PAREDE,
    18_DECLIVIDADE, 19_DEGRAU-ESPELHO

ATENÇÃO: "05-AREA" e "06-AREA" usam HÍFEN onde os vizinhos usam sublinhado.
Não "corrija" — divergir da grafia quebra o filtro de quem consome o modelo.

A CHAVE DO VOLUME MUDA POR PSET: 08_TERRAPLENAGEM usa 06_VOLUME,
09_DRENAGEM usa 07_VOLUME.

REGRAS
- campo sem valor: OMITA. Nunca escreva zero (regra 11 do bloco base).
- rejeite chave que não esteja no esquema, com erro — não grave campo novo
- tipos: IFCREAL para grandeza, IFCLABEL para texto, IFCBOOLEAN para sim/não
- 00_LAYER: gere a partir do tipo de obra e da operação, no padrão
  <PREFIXO>-<DISCIPLINA>-3D-<OPERAÇÃO>. Não me peça o nome da camada.

Ao terminar, releia o arquivo e me mostre uma tabela elemento × pset ×
campos preenchidos × campos omitidos.
```

---

## 7. Extrair quantitativos de um IFC

```
[BLOCO BASE]

TAREFA: extrair do IFC em anexo uma planilha de quantitativos.

CSV (separador ponto e vírgula, decimal com vírgula, cabeçalho em português):
elemento;classe;camada;tipo;material;volume_pset;volume_geometria;diferenca_pct;area;cota_min;cota_max

REGRAS
- volume_pset: o valor declarado no property set (atenção à chave, que muda
  por pset)
- volume_geometria: calculado da malha, com os vértices CENTRADOS no
  centroide antes de somar (regra 5)
- diferenca_pct: (geometria/pset - 1) × 100
- DESESCAPE o texto: \X\ e \X2\ (regra 8)
- elemento sem geometria entra na tabela com volume_geometria vazio, não zero

Ao final, some por tipo e por camada, e destaque:
- todo elemento com diferença acima de 1% entre pset e geometria
- todo sólido com volume abaixo de 0,01 m³
- toda casca não fechada (não deveria carregar volume)
```

---

## 8. Ler o esquema de property sets de outra empresa

```
[BLOCO BASE]

TAREFA: inventariar o esquema de property sets do IFC em anexo.

SAÍDA: para cada property set, nome e a lista de campo -> tipo, na ordem de
aparição (que é a ordem em que foram definidos).

FILTRE os psets de fábrica, que vêm do exportador e não do escritório:
prefixos Pset_, ePset_, ADT_Pset_, Qto_. Mostre-os separados, no fim.

DESESCAPE os nomes (regra 8) — senão 'CADASTRO DE INTERFER\X\CANCIAS' e
'CADASTRO DE INTERFERÊNCIAS' aparecem como dois psets distintos.

APONTE:
- prefixos numéricos ausentes na série (ex.: existe 01, 02, 03, 08, 09 —
  faltam 04 a 07)
- gerações convivendo: o mesmo conceito com e sem prefixo numérico
  (ex.: 'GERAL' e '01_GERAL')
- tipos inconsistentes dentro do mesmo campo semântico (ex.: uma cota como
  IFCINTEGER e outra como IFCREAL — a primeira perde os centímetros)

SE NÃO VIER NENHUM PSET DO ESCRITÓRIO, verifique quantos objetos FÍSICOS o
arquivo tem. Se for zero, o diagnóstico é: Property Set Definition no
template é só definição — ela só chega ao IFC anexada a um objeto que foi
exportado. Desenho vazio exporta a casca IfcProject/IfcBuilding com os
psets de fábrica e mais nada.
```

---

## 9. Alterar um IFC existente

```
[BLOCO BASE]

TAREFA: alterar o IFC em anexo.

MUDANÇA: <descreva — ex.: renomear elementos / trocar a cor do aterro /
atualizar o volume dos psets / transladar o modelo / remover elementos
abaixo de X m³>

REGRA: altere pelo ifcopenshell, não por substituição de texto. Trocar
string no arquivo quebra referência com facilidade e não renumera nada.

NÃO GERE GUID NOVO para elemento que já existia. O GUID é a identidade do
objeto entre revisões; trocá-lo faz o Navisworks tratar como objeto novo e
perder o histórico.

SE MEXER EM GEOMETRIA, atualize o property set correspondente. SE MEXER NO
PSET, confira contra a geometria. Um modelo cujo sólido não bate com a
propriedade é pior que um modelo sem propriedade.

ANTES E DEPOIS: tabela com produtos, volumes, cores e tamanho do arquivo.

AUTOTESTE: reabra e confirme zero erro de esquema e geometria carregando.
```

---

## 10. Validar antes de entregar

```
[BLOCO BASE]

TAREFA: validar o IFC que vou anexar como se fosse entregá-lo a um cliente.
Responda item a item com OK ou o problema.

ESTRUTURA
[ ] Schema declarado e MVD coerentes com a geometria usada
[ ] ifcopenshell.validate: zero mensagem
[ ] IfcProject -> IfcSite por IfcRelAggregates
[ ] elementos por IfcRelContainedInSpatialStructure
[ ] unidades declaradas (comprimento, área, volume, ângulo)
[ ] CRS com EPSG válido (EPSG:0 não existe)
[ ] IfcMapConversion coerente com onde a geometria está

GEOMETRIA
[ ] toda geometria carrega no ifcopenshell
[ ] toda casca que deveria ser sólido é fechada — paridade E orientação
[ ] nenhum sólido com volume nulo ou negativo
[ ] volume calculado com vértices centrados no centroide
[ ] RepresentationType descreve o Item de verdade

APARÊNCIA
[ ] todo produto com geometria tem IfcStyledItem
[ ] transparência: 1 - alfa, e não o alfa
[ ] Side = .BOTH. em superfície de terra

PROPRIEDADES
[ ] grafia dos campos idêntica ao esquema, inclusive "05-AREA" com hífen
[ ] nenhum campo fora do esquema
[ ] nenhum zero em campo que não foi medido
[ ] volume do pset bate com o volume da geometria (dentro de 1%)

SINTAXE
[ ] todo REAL com ponto na mantissa
[ ] GUIDs de 22 caracteres no alfabeto do IFC, sem duplicata
[ ] texto não-ASCII escapado corretamente

VEREDITO: "pronto para entregar" ou a lista do que impede.
```

---

## 11. Ressalva para arquivo gerado

Enquanto um tipo de saída novo não tiver sido aberto **uma vez** no programa de
destino, entregue com esta ressalva:

> Modelo gerado fora do <AutoCAD/Civil 3D>. Validado em `ifcopenshell`: sem erro
> de esquema, geometria carregando, e o volume medido da geometria conferindo
> com o declarado nos property sets. A importação no programa de destino ainda
> não foi confirmada para este tipo de saída.

Depois da primeira confirmação, apague a última frase e **anote em `IFC.md` qual
versão do programa confirmou** — a resposta muda entre versões.

---

## 12. Como pedir bem

**Peça a conferência cruzada, sempre.** "Compare o volume da geometria com o
volume do pset" é uma linha e pega a classe inteira de erro em que o modelo
contradiz a si mesmo.

**Não aceite "está fechado" sem as duas conferências.** Paridade de aresta sozinha
deixa passar orientação invertida, e o sintoma é um volume errado que parece
certo.

**Diga o destino no primeiro parágrafo.** Compatibilidade ou IFC4 muda geometria,
MVD, classes e coordenadas — tudo. Um agente que adivinha o destino produz um
arquivo defensável que não abre onde você precisa.

**Decisões de engenharia são suas.** Tolerância de serviço, espessura da casca do
terreno, resolução da malha, qual superfície é terreno e qual é projeto. Um
agente que as adivinha produz resultado plausível e possivelmente errado, sem
avisar.

---
*ED Serviços & Projetos LTDA — companheiro de `.agents/.skills/IFC.md`*
