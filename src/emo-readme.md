# Table of contents
- [introduction](#introduction)
- [methods](#methods)
  - [sentiment analysis](##sentiment-analysis)
- [results](#results)
- [discussion](#discussion)

# Introduction
formulate hyptheses

# Methods
take a look in csv folder

## raw data dump (sh)
- from crowdtangle ?
- facebook, ca 350K rows
- instagram, ca 350K rows

## normalize raw data (sh) 
- records, fix newlines
- delimiters, insert tabs
- unique record id, post id
- facebook, ca 240K rows

## clean, split, sample (sh)
- clean out N/A followers
- 240K to 120K post
- divide into 10K chunks
- randomize row order

## emojis to text (R)
- handle emojis in posts
- convert emoji to text

## match columns, rows
- to original 2018 dataset
- reassemble 100K rows

## sentiment analysis (py)
- afinn dictionary
- english for emoji text
- swedish for post text

## outlier detection (R)
- 1.5 interquartile range
- standardize, normalize measures

## data aggregation (R)
- 100K rows by 60 months

## modelling, visualization (R)
- linear models
- scatter plots

# Results
The results of the survey will be presented in two steps. First, some general descriptive statistics will be presented, and secondly, we use inferential statistics to test the hypotheses H1-H3 provided by the theoretical models generated through literature review of previous research. Descriptive statistics show .. visualize aggregated data, aggregate by organization (cf. Figure 1), [check appendix](#appendix)

![test figure](../fig/ei-sa-time-02.png)
Figure 1

Positive relationships between user engagement and sentiment measures.

![test figure](../fig/ei-sa-norm-02.png)
Figure 2

A number of measures were investigated for their explanatory contribution in relation to user engagement. Based on the theoretical model informed by previous research within organizational communication on social media, we hypothesized that user engagement would be positivey associated with sentiment in textual post content (H1a-H1c). We also hypothesized that this dependent measure would be positively associated with the number of followers of NGO Facebook pages (H2). Finally, we hypothesized that later time of post over the selected time period would be associated with higher levels user engagement (H3).


### model
Table 1: Effects on user engagment

|term        | Estimate| Std..Error| t.value|   p.z|
|:-----------|--------:|----------:|-------:|-----:|
|(Intercept) |    0.063|      0.004|  14.268| 0.000|
|sa_val_norm |    0.008|      0.004|   2.292| 0.022|
|sa_int_norm |    0.034|      0.005|   7.331| 0.000|
|follow_norm |    0.008|      0.003|   2.887| 0.004|
|time_norm   |   -0.014|      0.003|  -5.009| 0.000|


## Effects of sentiment measures on user engagement
three measures stated in h1a-h1c

### Post text sentiment valency
moved values to positive scale.. 

### Post text sentiment intensity
operationalized as valency squared.. also include frequency measure ?

## Effects of page followers on user engagement
control variable 

## Effects of period time point on user engagement 
control variable 

# Discussion
not there yet..

# Appendix
aggregate data by organization

Table: aggregate

|org                                   |    N|     mean|       sd|
|:-------------------------------------|----:|--------:|--------:|
|ActionAidSweden                       |  680|   61.694|  215.264|
|actsvenskakyrkan                      | 1040|  245.887|  428.189|
|Afghanistankommitten                  |  899|  126.697|  249.499|
|Afrikagrupperna                       |  286|   60.311|  107.691|
|Alzheimerfonden                       |  254|  236.776|  187.561|
|AmnestySverige                        |  971|  618.280|  864.434|
|AMREFNordic                           |  149|   35.114|  148.345|
|AnhorigasRiksforbund                  |  941|   50.932|   67.994|
|astmaallergiforbundet                 |  983|   93.152|  112.296|
|autismaspergersverige                 |  818|  276.363|  284.711|
|barncancerfonden                      | 1445|  607.293|  636.999|
|barndiabetesfonden                    |  753|  254.809|  506.392|
|Barnfonden                            |  819|  122.278|  545.050|
|barnrattsbyransverige                 |  316|   77.617|   61.060|
|berattarministeriet                   |  880|   47.853|   55.127|
|BirdLifeSverige                       |  971|  159.022|  236.712|
|Blomsterfonden                        |  212|   33.759|   36.942|
|BRIS                                  |  935|  246.892|  623.556|
|brostcancerforbundet                  |  911|  180.700|  253.226|
|cancerfonden                          | 1149| 1427.490| 3254.472|
|celiakiforbundet                      |  350|  105.474|  142.546|
|childhoodsverige                      |  378|  454.921|  642.396|
|civilrightsdefenders                  |  712|  103.808|  484.434|
|ClownerutanGranser                    | 1141|  151.877|  171.956|
|Diabetesfonden                        |   65|  154.415|  353.219|
|diakonia.se                           |  464|  116.198|  267.921|
|djurskyddet                           |  883|  251.468|  409.121|
|EcpatSverige                          |  477|  410.321|  510.958|
|emmausstockholm                       |  973|   31.280|   65.832|
|Erikshjalpen                          | 1104|   59.924|   83.858|
|eskilstunastadsmission                |  450|  112.518|  128.934|
|FairtradeSverige                      |  784|  200.607|  360.358|
|FNforbundet                           | 1011|   73.668|  198.559|
|fondenforpsykiskhalsa                 |  109|   32.798|  124.784|
|foreningenfuruboda                    | 1179|   46.073|   50.838|
|forskautandjurforsok                  |  341|  299.117|  353.172|
|fralsningsarmen                       | 1795|  477.388| 1003.658|
|FreezonenKvinnoTjejochBrottsofferjour |  240|   15.762|   32.113|
|Friluftsframjandet                    |  493|  173.185|  454.248|
|friskfri                              | 1069|   54.763|   61.042|
|fryshuset                             |  323|   27.477|   31.730|
|GbgStadsmission                       | 1392|  111.347|  274.448|
|hallsverigerent                       |  614|  292.148|  730.873|
|hela.manniskan                        |  538|   67.459|  222.335|
|hjarnfonden                           | 1262|  351.975|  691.081|
|Hjartebarnsfonden                     |  738|  165.560|  215.633|
|hjartlungfonden                       |  815|  138.692|  382.527|
|HRFriks                               | 1358|   67.408|   65.381|
|HRWSweden                             |  727|    5.521|    8.359|
|imsweden.org                          | 1435|   89.795|  234.545|
|iogtnto                               |  825|  161.996|  210.306|
|IslamicReliefSverige                  | 1523|   71.571|  186.052|
|kalmarstadsmission                    | 1122|   77.104|   78.034|
|kfumsverige                           |  704|   18.926|   24.270|
|kristnafreds                          | 1225|   25.558|   24.497|
|kvinnatillkvinna                      | 1082|  273.142| 1686.408|
|lakareivarlden                        |  569|   58.619|   98.878|
|lakareutangranser                     | 1272|  779.178| 2533.478|
|Lakarmissionen                        |  231|  301.312|  831.364|
|Latinamerikagrupperna                 |  169|   25.361|   25.941|
|Laxhjalpen                            |  696|   20.249|   16.895|
|lillabarnet                           |  144|  109.590|  459.369|
|linkopingsstadsmission.fb             | 1588|   50.844|   94.838|
|Mattecentrum                          | 1146|   59.453|   89.756|
|mentorsverige                         |  653|   48.856|   70.850|
|mindsweden                            |  943|  232.525|  419.257|
|minstoradag                           |  832| 1079.750| 2291.103|
|MPSweden                              |  159| 2000.220| 3142.276|
|neurosweden                           |  518|   72.726|  104.135|
|nhjalp                                |  230|   30.283|   70.754|
|Njurfonden                            |  161|  131.025|  270.474|
|nonsmokinggeneration                  | 1063|   40.298|   47.730|
|Nordensark                            |  517|  239.681|  273.435|
|operationsmilesverige                 |  982|  589.695|  805.250|
|organisationen.man                    |  817|  149.782|  240.027|
|oxfamsverige                          |  670|  196.854|  586.010|
|palestinagrupperna                    |  482|   88.776|  128.498|
|parasportSWE                          |  730|   75.732|   65.828|
|PlanSverige                           | 1162|  653.441| 1120.796|
|PMUfb                                 |  790|  105.318|  192.080|
|prostatacancerforbundetsverige        |  170|  197.894|  176.354|
|Psoriasisforbundet                    |  545|   58.154|   48.846|
|raddabarnen                           |  862|  963.223| 2741.993|
|raddningsmissionen                    | 1327|   97.812|  137.024|
|RaoulWallenbergAcademy                |  527|   98.387|  188.978|
|rburiks                               | 1097|  107.008|  136.342|
|reachforchangeorg                     |  824|   16.939|   19.669|
|Reumatikerforbundet                   | 1137|   99.835|   96.405|
|rfsl.forbundet                        | 1253|  141.513|  300.170|
|rfsu.se                               |  621|  158.403|  950.378|
|rightlivelihood                       |  539|   43.579|  203.035|
|RiksforbundetHjartLung                |  752|  113.089|  142.410|
|rodakorset                            |  851|  837.221| 1176.032|
|savetheorangutan.sverige              | 1181|  248.338|  274.264|
|scouterna                             |  901|  105.397|  233.443|
|sjoraddning                           | 1034|  471.632|  460.310|
|skanestadsmission                     | 1185|  155.844|  168.284|
|SLMK.1981                             |  958|   44.634|   55.200|
|sosbarnbyar                           |  956|  168.257|  314.140|
|spadbarnsfonden                       |  190|   96.584|  180.038|
|Sportfiskarna                         |  644|  151.078|  403.589|
|stadsmissionen                        | 1001|  227.832|  633.775|
|stadsmissioniorebro                   |  613|   65.713|   87.640|
|starforlifeofficial                   |  297|   63.869|   63.155|
|StiftelsenFriends                     |  811|  712.429| 4860.726|
|suicidezero                           |  263|  450.582|  549.821|
|svenskafreds                          | 1275|  103.275|  165.300|
|svenskalivraddningssallskapet         |  524|   85.964|  133.596|
|sverigeforunhcr                       | 1132|  384.048|  666.155|
|sverigesstadsmissioner                |  631|   28.669|   27.206|
|TeachForSweden                        |  626|   21.987|   18.075|
|Teskedsorden                          |  286|   53.909|   57.993|
|thehungerprojectse                    |  980|   20.209|   23.159|
|Tjejzonen                             |  524|   66.719|  114.499|
|ungcancer                             | 1151|  437.135|  940.106|
|UNICEF-Sverige                        |  955| 1111.969| 3250.357|
|uppsalastadsmission                   | 1334|   82.824|  144.695|
|vasterasstadsmission                  |  762|   68.156|  230.661|
|viskogen                              |  472|  806.328|  943.541|
|warchildsverige                       |  738|   29.375|   36.957|
|wateraidswe                           |  995|   78.004|  198.772|
|weeffect                              |  525|  240.189|  700.034|
|WikimediaSverige                      |  570|   34.014|  108.909|
|WorldAnimalProtectionSverige          | 1262| 1018.281| 1334.483|
|worldschildrensprize                  |  270|  792.307| 2102.117|
