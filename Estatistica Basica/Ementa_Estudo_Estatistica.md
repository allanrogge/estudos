Estudo Estatística Básica - Parte I
================

  - [Introdução à Estatística](#introdução-à-estatística)
      - [Conceitos básicos](#conceitos-básicos)
          - [Estatística](#estatística)
          - [População](#população)
          - [Censo](#censo)
          - [Amostra](#amostra)
          - [Amostragem](#amostragem)
          - [Experimento Aleatório](#experimento-aleatório)
          - [Parâmetro](#parâmetro)
          - [Estimativa](#estimativa)
          - [Estimador](#estimador)
          - [Variável](#variável)
  - [Estatística descritiva](#estatística-descritiva)
      - [Análise Exploratória](#análise-exploratória)
          - [Medidas descritivas](#medidas-descritivas)
          - [Distribuição de Frequência](#distribuição-de-frequência)
          - [Gráficos](#gráficos)
      - [Análises Bidimensionais](#análises-bidimensionais)
          - [Variáveis Qualitativas](#variáveis-qualitativas)
          - [Variáveis Quantitativas](#variáveis-quantitativas)
          - [Variáveis Qualitativas e
            Quantitativas](#variáveis-qualitativas-e-quantitativas)
      - [Probabilidade](#probabilidade)
          - [Variáveis Discretas](#variáveis-discretas)
      - [Variáveis Contínuas](#variáveis-contínuas)
          - [Propriedades](#propriedades-1)
          - [Distribuições Contínuas](#distribuições-contínuas)
          - [Função Acumulada](#função-acumulada-1)

# Introdução à Estatística

## Conceitos básicos

### Estatística

Ciência voltada para a coleta, análise, interpretação e apresentação dos
dados e, através das conclusões obtidas, são tomadas decisões mais
acertivas. Existem duas vertentes:

  - **Estatística Descritiva**: Descreve os dados. Voltada para obter a
    maior quantidade de informações possíveis para indicação de modelos
    plausíveis na etapa posterior.

*Exemplo*: Contagem de alunos do sexo feminino e masculino em uma sala
de aula.

  - **Estatística Inferencial**: Responsável pelas hispóteses e
    previsões para um determinada população baseada numa amostra. É
    fundamentada na teria das probabilidades e faz uso da modelagem para
    suas conclussões.

*Exemplo*: Estimação de quantos casos de COVID teremos em out’20.

### População

Conjunto, finito ou infinito que possui ao menos uma carcterística em
comum entre os elementos que os compõem. Significa o “todo”.

*Exemplo*: População do Brasil; ou número de casos da pandemia.

### Censo

Coleta da população, coleta do todo.

*Exemplo*: Censo do IBGE; ou informações de idade, salário, sexo, e
formação de todos os colaboradores de uma empresa.

### Amostra

É um subconjunto da população, uma parte do todo, onde se pode fazer
estimativas, inferir algo.

*Exemplo*: 2.200 indivíduos que participaram de uma pesquisa eleitoral;
ou um campus de uma universidade que possui outros 4 campus.

### Amostragem

Processo para se obter a amostra através de técnica (métodos) pré
definidas.

*Exemplo*: Sorteio aleatório de 5 alunos de uma classe de 10 alunos; ou
seleção de 1000 indivíduos para cada região do Brasil.

### Experimento Aleatório

Quando executa-se um experimento repetidas vezes sem previsão de
resultado ou sem que os resultados sejam essencialmente os mesmos. Geram
o que chamamos de espaço amostral, que possui subconjuntos denominados
eventos.

*Exemplo*: Lançamento de uma moeda, onde seu espaço amostral é
{cara,coroa} e seus eventos são {(cara)} ou {(coroa)}; ou lançamento de
um dados de 6 faces, onde seu espaço amostral é {1,2,3,4,5,6} e seus
eventos são {(1)}, {(2)}, … , {(6)}.

### Parâmetro

São as características singulares da população. Sua definição depende de
examinar toda população.

*Exemplo*: A média da idade de todos os senadores do Brasil (57 anos -
fictício); ou a mediana da altura dos jogadores de basquete do Los
Angeles Lakers (1,98m - fictício).

### Estimativa

É um valor aproximado do parâmetro, baseado e calculado através da
amostra.

*Exemplo*: Com base no time de futebol do Corinthians, obteve-se uma
média salarial de R$ 250.000,00 para os jogadores dos times do
Campeonato Braasileiro.

### Estimador

Forma de se obter a estimativa.

*Exemplo*:

\[ média = \frac{\sum\limits_{i=1}^{n}{x_i}}{n} , i = 1,2,...n \]

### Variável

É o conjunto de resultados possíveis de um fenômeno (resposta), ou ainda
são as propriedades dos elementos da população que se pretende conhecer.
Existem dois tipo:

  - Variáveis Qualitativas: Quando, de certa forma, qualificamos uma
    observação através de palavras: categorias e classes. Dentre estas
    temos:

\*Variáveis Qualitativas Nominais: Quando não há qualquer ordem ou nível
entre as respostas.

*Exemplo*: Gênero de diversos filmes da base do IMDB.

\*Variáveis Qualitativas Ordinais: Quando há ordem ou nível entre as
respostas.

*Exemplo*: Grau de instrução de indivíduos de uma determinada empresa.

  - Variáveis Quantitativas: Em resumo, são respostas numéricas. Dentre
    estas temos:

\*Variáveis Quantitativas Discretas: Quanto só admitem respostas de
números inteiros.

*Exemplo*: Número de filhos de um grupo de voluntários (Não daria pra
contar 0,5 filho).

\*Variáveis Quantitativas Contínuas: Quando são feitas medições, onde se
admitem números não inteiros (Racionais).

*Exemplo*: Temperatura da Cidade de Belém nos últimos 10 dias.

-----

# Estatística descritiva

## Análise Exploratória

### Medidas descritivas

#### Medidas de posição

##### Média

A média aritmética é a medida de posição mais faniliar e conhecida. É
deficina pela soma das observações dividida pelo número delas.

Para os dados brutos a média é calculada:

\[ média = \frac{\sum\limits_{i=1}^{n}{x_i}}{n}\]

*Exemplo*: Se tivermos o seguinte conjunto:

``` r
x <- c(1,2,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,6,6,6,6,7,8,9,9,9,9,9,9)

media_de_x <- sum(x)/length(x)

print(media_de_x)
```

    ## [1] 5.4

Para dados Tabelados, a média é calculada

\(média = \frac{\sum\limits_{i=1}^{n}{f_ix_i}}{\sum\limits_{i=1}^{n}{f_i}}\)

*Exemplo*: De acordo com o conjunto anterior:

``` r
tabela_x <- table(x) %>% data.frame()

tabela_x %>%   
  knitr::kable()
```

| x | Freq |
| :- | ---: |
| 1 |    1 |
| 2 |    4 |
| 3 |    3 |
| 4 |    3 |
| 5 |    3 |
| 6 |    8 |
| 7 |    1 |
| 8 |    1 |
| 9 |    6 |

``` r
media_de_x_tabelada <- (tabela_x$x*tabela_x$Freq)/sum(tabela_x$Freq)

print(media_de_x_tabelada)
```

    ## [1] NA NA NA NA NA NA NA NA NA

##### Moda

##### Mediana

##### Quantis

#### Medidas de dispersão

##### Amplitude

##### Desvio Médio

##### Variância

##### Desvio Padrão

##### Coeficiente de Variação

### Distribuição de Frequência

### Gráficos

## Análises Bidimensionais

### Variáveis Qualitativas

### Variáveis Quantitativas

### Variáveis Qualitativas e Quantitativas

## Probabilidade

### Variáveis Discretas

##### Propriedades

##### Distribuições Discretas

##### Função Acumulada

## Variáveis Contínuas

### Propriedades

### Distribuições Contínuas

### Função Acumulada
