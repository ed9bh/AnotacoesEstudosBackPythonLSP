---
Empresa: ED Serviços & Projetos LTDA
Documento: Prompts de LandXML — trabalhar sem o Civil 3D
Versão: 1.1 — Setembro/2026
Companheiro de: `.agents/.skills/LandXML.md`
Alinhamento: Bloco Base cobre as 15 regras medidas do LandXML.md (v1.0)
---

# Prompts de LandXML

Biblioteca de prompts prontos para produzir, ler e alterar LandXML com IA, sem
abrir o Civil 3D.

**Cada prompt é autossuficiente.** Todos carregam o Bloco Base (§1), que contém
as regras que, se ignoradas, produzem arquivo errado e plausível. Isso é de
propósito: um prompt colado num chat novo, com um modelo que nunca viu este
repositório, tem de funcionar mesmo assim.

Se o agente **tiver** o repositório, comece mandando ler o documento longo —
ele tem as fórmulas e o porquê de cada regra:

> Leia `.agents/.skills/LandXML.md` antes de começar. Ele é a especificação
> deste trabalho.

---

## 0. O que estes prompts tornam independente — e o que não

| Tarefa | Independente do Civil 3D? |
| --- | --- |
| Ler, auditar, extrair dados de LandXML | **sim, totalmente** |
| Calcular volume, área, perfil, seções | **sim** |
| Gerar superfície, alinhamento, greide | **sim, para produzir o arquivo** |
| Confirmar que o arquivo **abre** no Civil 3D | **não** |

A última linha é honesta e importante. Nada substitui abrir uma vez no Civil 3D
para validar um gerador novo. Mas isso é **uma** validação por tipo de saída, não
uma por arquivo: depois que o formato está confirmado, os prompts produzem
arquivo atrás de arquivo sem abrir o programa.

Enquanto essa confirmação não acontece, todo arquivo gerado sai com a ressalva
no §11.

### O que o LandXML não carrega — não perca um dia tentando

| Coisa | Situação |
| --- | --- |
| **Property sets** (Civil 3D / AEC) | **não carrega.** `<Feature>/<Property>` existe no esquema, mas a exportação de superfície não o preenche. O caminho é exportar **IFC** e ler de lá — ver `IFC_Prompts.md`. |
| **Corredor paramétrico** | `<Roadways>` guarda estações e seções, mas não assembly, subassembly, alvo, região nem frequência. Importar LandXML **não recria corredor editável**, em ferramenta nenhuma. |
| **Papel da superfície** | não há campo para "terreno" ou "projeto". É decisão sua — ver regra 11. |
| **Estilos, camadas, cores** | não fazem parte do formato. |

Do corredor se salva a superfície resultante, o alinhamento, o greide, as seções
por estaca e a lista de material. Perde-se a editabilidade paramétrica.

---

## 1. Bloco Base

Cole isto no **início de qualquer** prompt de LandXML.

```
CONTEXTO OBRIGATÓRIO — LandXML 1.2 exportado/importado pelo Autodesk Civil 3D.

Regras invioláveis. Ignorar qualquer uma produz arquivo errado e plausível:

1. NAMESPACE. Todo find/iter precisa de
   NS = "{http://www.landxml.org/schema/LandXML-1.2}"
   Esquecer é a causa nº 1 de "o arquivo está vazio".

2. COORDENADAS SÃO (Norte, Este, Cota) — não (X, Y, Z).
   <P id="2">7791683.387 616962.864 878.</P>
                ^Norte      ^Este    ^Cota
   Inverter joga a superfície para fora da zona UTM.

3. FACES INVISÍVEIS. <F i="1"> não integra a superfície. Exclua de área,
   volume, declividade e desenho. Incluir dá +5% a +6% de área — erro
   pequeno o bastante para parecer certo.

4. OS id DE <P> NÃO SÃO CONTÍGUOS e não começam em 1. Indexe por dicionário
   id -> (n,e,z). Array posicional quebra em silêncio.

5. O ARQUIVO TRAZ O PRÓPRIO GABARITO. <Definition> declara area2DSurf,
   area3DSurf, elevMin, elevMax; <Curve> declara radius/chord/delta/tangent.
   SEMPRE recalcule e compare (tolerância 1e-9 relativa). É teste de
   regressão de graça. Se divergir, PARE e reporte — não "conserte".

6. dir NÃO É AZIMUTE. O LandXML mede dir no sentido anti-horário a partir do
   ESTE: dir = degrees(atan2(ΔNorte, ΔEste)) mod 360.
   Azimute topográfico = (90 - dir) mod 360. Confundir dá número plausível
   com rótulo errado.

7. NO GREIDE, A CURVA É O PVI. <ProfAlign> é uma lista de vértices que são
   todos PVI. <ParaCurve> e <CircCurve> trazem estação e cota no texto,
   igual ao <PVI>, e acrescentam só o comprimento (e o raio). A curva NÃO
   fica entre dois PVI.
   Rampas saem da diferença entre vértices consecutivos, não de atributos.

8. RAIO DE CURVA VERTICAL CIRCULAR:
       R = L / |atan(g2) - atan(g1)|      <- diferença dos ÂNGULOS
   NÃO use R = L / |g2 - g1|. As duas concordam em rampa fraca e divergem
   vários porcento em rampa forte (mina, 39%).

9. UNIDADES. Leia <Units>; nunca assuma métrico.

10. NÚMEROS. Ponto decimal, nunca vírgula. O Civil 3D grava "0." e "20."
    (ponto final sem dígitos) — é válido. Não force casas fixas nem
    normalize a precisão de valores lidos de outro arquivo.

11. O NOME DO ARQUIVO MENTE. Use o name interno de <Surface> em todo
    relatório, nunca o nome do arquivo. Caso real: um "MDT.xml" era a
    superfície de tratamento de fundação (RMS 0,274 m contra as seções),
    não o terreno (RMS 4,996 m).
    E o LandXML NÃO declara papel de superfície. Heurística por nome é
    sugestão, JAMAIS decisão: adivinhar errado inverte o sinal do corte e
    do aterro e produz uma tabela completa, plausível e trocada.

12. ESPIRAL: radiusStart/radiusEnd podem vir com a STRING "INF". O float()
    do Python converte; Decimal e int quebram. Se você não trata espiral,
    RECUSE em voz alta — ignorar em silêncio devolve um eixo com o
    comprimento errado, que é o pior dos dois resultados.

13. NÃO EXTRAPOLE O GREIDE. Fora do intervalo de estações do <ProfAlign>,
    responda "não há greide", nunca um valor. Extrapolar greide é inventar
    projeto.
    Dentro do intervalo, avisos (estação não crescente, curva invadindo o
    vértice vizinho, raio divergente) NÃO interrompem a leitura: acumule
    numa lista e deixe quem consome decidir. Um greide de levantamento tem
    centenas de vértices e um trecho ruim não pode derrubar o arquivo.

14. SEÇÕES: <PntList2D> é uma lista plana ALTERNANDO offset e cota
    (v[0::2] = offsets, v[1::2] = cotas). Offset positivo é à DIREITA do
    eixo. O ponto no plano é origem + unitário*estaca + normal*offset, com
    normal = (-u_este, u_norte). Trocar o sinal espelha a seção sem erro
    nenhum.
    CrossSectSurf cujo nome contém "LISTA MATERIAL" é a área que o Civil 3D
    já contabilizou — use como aferição INDEPENDENTE do seu volume.

15. CRS. Leia <CoordinateSystem>/ogcWktCode e valide contra a zona
    esperada. RECUSE mesclar ou comparar superfícies com CRS divergente sem
    reprojeção explícita e registrada.

Se algo no arquivo contrariar estas regras, PARE e me diga. Não adivinhe.
```

Arquivo de dezenas de MB: troque `etree.parse` por `iterparse` com `clear()`.
Medido, 38,7 MB / 192.109 pontos / 383.802 faces em 2,6 s — o XML não é o
gargalo, dimensione pela cubagem e pela renderização.

---

## 2. Auditar um LandXML recebido

Use quando alguém te manda um arquivo e você precisa saber o que tem dentro
antes de confiar nele.

```
[BLOCO BASE]

TAREFA: auditar o LandXML em anexo e me dar um relatório.

Escreva um script Python (lxml + numpy) que reporte:

IDENTIFICAÇÃO
- schema, exportador, versão, data, DWG de origem
- CRS declarado (ogcWktCode) e unidades
- o que existe: Surfaces, Alignments, Profiles, Roadways, CrossSects

POR SUPERFÍCIE
- name interno (NÃO o nome do arquivo)
- pontos, faces visíveis, faces invisíveis (i="1")
- área 2D e 3D recalculadas × declaradas, com o desvio em notação científica
- elevMin/elevMax recalculados × declarados
- faces referenciando ponto inexistente, pontos órfãos, faces degeneradas
- arestas não-manifold, loops de borda (mais de 1 = buracos internos)
- declividade média e máxima; nº de faces acima de 45° e de 85°
- é 2,5D? (um só Z por XY) — importa antes de rasterizar

POR ALINHAMENTO
- name, length, staStart
- quantos Line, Curve, Spiral
- para cada Curve: radius declarado × recalculado; delta × (dirEnd-dirStart)
- espirais: reporte, não ignore
- greide: nº de PVI, ParaCurve, CircCurve; para cada CircCurve, radius
  declarado × recalculado pela fórmula do ângulo
- seções: quantas, faixa de estacas, nomes das CrossSectSurf

VEREDITO
Termine com uma lista do que NÃO confere e do que exige decisão humana
(papel de superfície, CRS divergente, espiral).

Não conserte nada. Só reporte.

Se o arquivo passar de uns 20 MB, use iterparse + clear() em vez de parse();
o parse completo de 38,7 MB leva 2,6 s por esse caminho.
```

---

## 3. Extrair dados para planilha

```
[BLOCO BASE]

TAREFA: extrair do LandXML em anexo, para CSV (separador ponto e vírgula,
decimal com vírgula, cabeçalho em português):

[escolha o que precisa]
( ) pontos da superfície <NOME>: id;norte;este;cota
( ) faces da superfície <NOME>: id1;id2;id3   (só as visíveis)
( ) greide: estacao;cota;tipo;comprimento;raio;rampa_entrada;rampa_saida
( ) eixo: elemento;comprimento;raio;sentido;dir;azimute;n_inicio;e_inicio;n_fim;e_fim
( ) seções: estaca;superficie;offset;cota
( ) perfil do terreno no eixo, a cada <PASSO> m: estaca;cota

Antes de exportar, rode a conferência da regra 5 e me diga o resultado.
Se não conferir, pare.

No CSV do eixo, traga dir e azimute em colunas SEPARADAS, com os nomes
literais "dir_landxml" e "azimute_topografico".

Nas seções, leia <PntList2D> pela regra 14 (lista alternada, offset positivo
à direita) e traga o nome da CrossSectSurf tal como está — inclusive as que
contêm "LISTA MATERIAL", que não são superfície e sim área já calculada pelo
Civil 3D. Marque-as numa coluna "eh_lista_material".
```

---

## 4. Criar superfície TIN a partir de pontos

```
[BLOCO BASE]

TAREFA: gerar um LandXML 1.2 com uma superfície TIN.

ENTRADA: [anexe CSV/TXT] com colunas [descreva: norte;este;cota | este,norte,cota | ...]
NOME DA SUPERFÍCIE: <NOME>
CRS: <ex.: SIRGAS 2000 / UTM 23S — EPSG:31983>   [ou "não declarar"]

PASSOS
1. Leia os pontos. Diga quantos leu e a extensão (N, E, cota).
2. Deduplique em planta com tolerância de 10 mm, desempatando pela cota
   média. Reporte quantos pontos foram fundidos. NÃO arredonde as cotas.
3. Triangule (Delaunay 2D, scipy.spatial.Delaunay sobre N,E).
4. Se eu tiver dado um contorno, recorte os triângulos fora dele e emita
   <Boundaries> com o loop externo como bndType="outer" e os internos como
   bndType="hide". Sem <Boundaries>, o Civil 3D pode retriangular e
   atravessar concavidades.
5. Calcule area2DSurf, area3DSurf, elevMin, elevMax e grave em <Definition>.
6. Emita na ordem: Units, CoordinateSystem, Project, Application, Surfaces.
7. AUTOTESTE OBRIGATÓRIO: releia o arquivo que você acabou de escrever com
   um parser independente e confirme que as áreas recalculadas batem com as
   declaradas e que os pontos voltam idênticos ao milímetro. Me mostre o
   resultado dessa conferência.

Numere os <P> a partir de 1, contíguos — quem lê não pode assumir isso, mas
quem escreve pode facilitar.

NÃO emita o atributo n="..." em <F> com valor inventado. Ele guarda os
vizinhos de cada aresta (0 = sem vizinho) e é redundante com a topologia: ou
calcule corretamente, ou omita. Vizinhança errada é pior que ausente.
```

---

## 5. Criar alinhamento (retas e curvas)

```
[BLOCO BASE]

TAREFA: gerar um LandXML 1.2 com um <Alignment>.

ENTRADA: [escolha]
( ) vértices de PI em (norte, este) + raio de cada curva
( ) polilinha em CSV: norte;este  (só retas, sem curva)
NOME: <NOME>    ESTACA INICIAL: <staStart, ex.: 0>

REGRA CENTRAL DA ESCRITA
Um <Curve> carrega doze grandezas para descrever uma coisa só: rot, radius,
length, chord, delta, dirStart, dirEnd, tangent, midOrd, external, mais os
pontos Start/Center/End/PI. Se duas discordarem, o Civil 3D ou recusa o
arquivo ou reconstrói a curva do jeito dele, EM SILÊNCIO.

Portanto: NENHUMA dessas grandezas vem de mim. TODAS são derivadas de
(PI, raio) e gravadas já coerentes:

    delta    = ângulo de deflexão entre as tangentes
    tangent  = R * tan(delta/2)
    length   = R * delta_rad
    chord    = 2R * sin(delta/2)
    midOrd   = R * (1 - cos(delta/2))
    external = R * (1/cos(delta/2) - 1)
    dirStart, dirEnd = direções das tangentes, anti-horário do ESTE
    rot      = "ccw" se dir cresce, "cw" se decresce

(Estas cinco fórmulas foram conferidas contra as 8 curvas reais de
Eixo_TesteLongaDistanciaComArcos.xml: reproduzem os atributos declarados pelo
Civil 3D com erro de 1e-13. delta == dirEnd - dirStart e rot coerente com o
sinal, nas 8.)

O <Alignment length="..."> é a soma dos comprimentos dos elementos.

VERIFICAÇÕES ANTES DE ME ENTREGAR
- fim de cada elemento == início do próximo, ao milímetro
- dirEnd de um == dirStart do próximo (tangência)
- tangente da curva cabe na reta adjacente; se não couber, PARE e diga qual
- releia o arquivo gerado e confirme que todos os atributos redundantes
  batem com a geometria dos pontos

Se eu pedir espiral, diga que não está coberto e pare — não improvise
clotoide.
```

---

## 6. Criar greide

```
[BLOCO BASE]

TAREFA: gerar o <Profile>/<ProfAlign> de um alinhamento.

ENTRADA: lista de PVI — estacao;cota;tipo_curva;parametro
  tipo_curva: PVI (sem curva) | PARA (parábola) | CIRC (circular)
  parametro : vazio para PVI | comprimento L para PARA | raio R para CIRC

ESTRUTURA (releia a regra 7 do bloco base)
  <PVI>estacao cota</PVI>
  <ParaCurve length="L">estacao cota</ParaCurve>
  <CircCurve length="L" radius="R">estacao cota</CircCurve>

A curva É o PVI. Estação e cota vão no TEXTO, iguais às de um <PVI>.

PARA CircCurve, quando eu der o raio, derive o comprimento pela fórmula do
ângulo — a mesma da regra 8, invertida:

    t1 = atan(g1);  t2 = atan(g2)
    L  = R * |t2 - t1|

onde g1 e g2 são as rampas de entrada e saída, calculadas da diferença entre
vértices consecutivos.

VERIFICAÇÕES
- estações estritamente crescentes
- nenhuma curva invade o vértice vizinho (para PARA, L/2 de cada lado;
  para CIRC, a tangente T = R*tan(|t2-t1|/2), medida SOBRE a rampa)
- nenhuma CircCurve com g1 == g2 (raio infinito)
- releia e confirme que R recalculado bate com o R gravado
- primeiro e último vértice não podem ser curva (falta uma rampa)

Se alguma verificação falhar, mostre qual PVI e pare.

Se eu depois te pedir a cota do greide numa estação, aplique a regra 13:
dentro do intervalo, interpole; fora dele, responda "não há greide" — não
prolongue a última rampa.
```

---

## 7. Alterar um arquivo existente

```
[BLOCO BASE]

TAREFA: alterar o LandXML em anexo.

MUDANÇA: <descreva — ex.: subir todas as cotas em 1,25 m / transladar
E em +150 m / renomear a superfície para X / remover as faces acima da
cota 1010 / recortar pelo polígono anexo>

REGRA: altere a ÁRVORE, não a sua representação.
Leia com lxml, encontre os nós, mude o que precisa, grave a árvore. NÃO
reconstrua o arquivo a partir do que você entendeu dele — o que você não
modelou tem de sobreviver intacto.

DEPOIS DE MEXER EM PONTOS OU FACES, obrigatoriamente:
- recalcule e ATUALIZE area2DSurf, area3DSurf, elevMin e elevMax
- se mexeu na borda, atualize <Boundaries> se houver

Deixar essas grandezas com o valor antigo transforma o gabarito embutido
numa mentira, e o próximo a ler vai confiar nele.

ANTES E DEPOIS: me mostre uma tabela com pontos, faces, áreas e faixa de
cotas, para eu ver o que mudou.

Grave com xml_declaration=True, encoding="UTF-8", e preserve o namespace.
```

---

## 8. Calcular volume entre duas superfícies

```
[BLOCO BASE]

TAREFA: cubagem entre as duas superfícies em anexo.

TERRENO (base): <arquivo ou nome da Surface>
PROJETO (topo): <arquivo ou nome da Surface>

ATENÇÃO: o LandXML não declara papel de superfície. Confirme comigo qual é
qual antes de calcular — trocar inverte o sinal do corte e do aterro, e a
tabela sai completa, plausível e errada.

MÉTODO: grade regular de <RESOLUÇÃO, padrão 0,50> m sobre a extensão do
projeto. Para cada célula, dz = z_projeto - z_terreno; some dz>0 como
aterro e dz<0 como corte, multiplicando pela área da célula.

RELATE
- aterro, corte, saldo (corte - aterro), área de sobreposição
- altura máxima de aterro e profundidade máxima de corte
- A RESOLUÇÃO USADA, junto de cada número — volume pequeno é sensível a ela
- rode também em <RESOLUÇÃO/2> e me mostre os dois. Se diferirem mais de
  1%, o número não está convergido e você tem de me dizer isso.

Se houver alinhamento, dê também o volume restrito ao trecho dele.

AFERIÇÃO INDEPENDENTE: se algum dos arquivos tiver <CrossSects> com uma
CrossSectSurf chamada "...LISTA MATERIAL...", ela traz a área que o próprio
Civil 3D contabilizou por estaca. Integre essas áreas pelo método das áreas
médias e me mostre o resultado AO LADO do da grade. Dois métodos
independentes concordando é a única evidência barata que existe aqui.
```

---

## 9. Converter para LandXML

```
[BLOCO BASE]

TAREFA: converter o arquivo em anexo para LandXML 1.2.

ORIGEM: [CSV de pontos | DXF com faces 3D | malha OBJ/PLY | IFC | outro]

PASSOS
1. Reporte o que encontrou: quantos pontos, quantas faces, extensão,
   sistema de coordenadas se houver.
2. DIGA-ME em que ordem estão as coordenadas na origem, e confirme comigo
   antes de gravar. A maioria dos formatos usa (X=Este, Y=Norte); o
   LandXML usa (Norte, Este). Essa troca é o erro mais comum da conversão
   e o sintoma é a superfície aparecer fora da zona UTM.
3. Deduplique com tolerância de 10 mm e reporte.
4. Gere conforme o prompt §4 (superfície) ou §5 (alinhamento).
5. Autoteste: releia e compare com a origem, ponto a ponto, ao milímetro.

Se a origem tiver unidade em pés, converta e me diga o fator usado.
```

---

## 10. Validar antes de entregar

```
[BLOCO BASE]

TAREFA: validar o LandXML que vou anexar, como se fosse entregá-lo a um
cliente. Percorra a lista e responda item a item com OK ou o problema.

ESTRUTURA
[ ] XML bem formado; namespace correto; declaração de encoding
[ ] Ordem dos elementos: Units, CoordinateSystem, Project, Application, dados
[ ] <Units> presente e coerente com os valores
[ ] <CoordinateSystem> presente, e o ogcWktCode é a zona que eu espero

SUPERFÍCIE
[ ] area2DSurf e area3DSurf conferem com as recalculadas (1e-9 relativo)
[ ] elevMin/elevMax conferem
[ ] nenhuma face referencia ponto inexistente
[ ] nenhum ponto órfão, nenhuma face degenerada
[ ] nenhuma aresta não-manifold
[ ] loops de borda: quantos, e isso é esperado?
[ ] <Boundaries> presente se a superfície tem concavidade ou buraco

ALINHAMENTO
[ ] length do Alignment == soma dos elementos
[ ] continuidade: fim de cada elemento == início do próximo
[ ] tangência: dirEnd == dirStart do próximo
[ ] cada Curve: radius, length, chord, delta, tangent coerentes entre si
[ ] rot coerente com o sentido de dir
[ ] Spiral: se houver, radiusStart/radiusEnd "INF" foram lidos como float e
    a espiral foi tratada — nunca ignorada

GREIDE
[ ] estações estritamente crescentes
[ ] cada CircCurve: R declarado == L/|atan(g2)-atan(g1)|
[ ] nenhuma curva invadindo o vértice vizinho
[ ] primeiro e último vértice não são curva

SEÇÕES (se houver)
[ ] PntList2D com número PAR de valores, alternando offset e cota
[ ] offsets monótonos dentro de cada CrossSectSurf
[ ] as CrossSectSurf de "LISTA MATERIAL" identificadas e não somadas como
    superfície

IDENTIFICAÇÃO
[ ] o relatório usa o name interno das Surfaces, não o nome do arquivo
[ ] o papel de cada superfície (terreno / projeto) foi decidido por MIM, e
    está escrito onde quem receber o arquivo consiga ler

VEREDITO: "pronto para entregar" ou a lista do que impede.
```

---

## 11. Ressalva para arquivo gerado

Enquanto o formato de uma saída nova não tiver sido confirmado dentro do Civil
3D **uma vez**, entregue o arquivo com esta ressalva junto:

> Arquivo gerado fora do Civil 3D. Geometria conferida por ida e volta em
> parser independente, com as áreas declaradas batendo com as recalculadas.
> A importação no Civil 3D ainda não foi confirmada para este tipo de saída.

Depois da primeira confirmação, apague a última frase — e anote no
`LandXML.md` qual versão do Civil 3D confirmou, porque a resposta pode mudar
entre versões.

---

## 12. Como pedir bem

Três hábitos que mudam o resultado, independentes de qual prompt você use:

**Peça o número de conferência, não só o arquivo.** "Me mostre a área
recalculada ao lado da declarada" custa uma linha e pega a maioria dos erros.

**Não deixe o agente "consertar" divergência.** Se o recalculado não bate com o
declarado, ou o parser está errado ou o arquivo está corrompido — nos dois casos
a resposta é parar, não ajustar um dos lados até fechar.

**Diga o que é decisão sua.** Papel de superfície, CRS, tolerância de
deduplicação, resolução da grade: são escolhas de engenharia. Um agente que as
adivinha produz um resultado defensável e possivelmente errado, sem avisar.

---
*ED Serviços & Projetos LTDA — companheiro de `.agents/.skills/LandXML.md`*
