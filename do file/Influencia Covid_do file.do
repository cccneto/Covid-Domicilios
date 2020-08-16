clear
import excel "C:\Users\User\Dropbox\COVID AREAS VERDES\basecompleta.xlsx", sheet("base") firstrow
set more off

********Variáveis de interesse********

destring IDADE, replace force
destring AREA_VERD, replace force
destring AVERD_AJUD, replace force
destring TEMP_MAIS, replace force

********Recodificando********

recode ISOLAM (0=1) (1=2) (2=3)
recode RENDA (0=1) (1=2) (2=3) (3=4) (4=5) (5=6), gen(renda)
recode ESCOL (0=1) (1=2) (2=3) (3=4) (4=5)
recode AFET_REND (0=1) (1=2) (2=3) (3=4) (4=5), gen(afet_rend)
recode STRES_FAM (0=1) (1=2) (2=3), gen(stres_fam)
recode QUAL_RES (0=1) (1=2) (2=3) (3=4) (4=5) (5=6), gen(qual_res)
recode AVERD_AJUD (0=1) (1=2) (2=3), gen(averd_ajud)
recode IMPAC_ISO (0=1) (1=2) (2=3) (3=4) (4=5)
recode TEMP_MAIS (0=1) (1=2) (2=3) (3=4) // ninguém respondeu menos de 1 mês
recode SEXO (0=1) (1=0) // homens igual a 1; seguindo o padrão usado na economia social

********Criando Variáveis********

gen IDAD = IDADE if IDADE >= 18
gen escol = ESCOL if ESCOL > 1 

********Renomeando as variáveis********

rename ESCOL educ
rename IDAD idade
rename ISOLAM isolam
rename ESTADO uf
rename SEXO sexo
rename ATIV_FIS ativ_fis
rename AREA_VERD area_verd
rename REDUZ_VIT red_vit
rename QTD_PES qtd_pes
rename SONO sono
rename IMPAC_ISO impac_iso
rename TEMP_MAIS temp_mais

********Apagando os missings********
tab averd_ajud, miss
* 4040 missing values 
drop if missing(averd_ajud) 

tab idade, miss
* 521 missing values
drop if missing(idade)

tab ativ_fis, miss
* 0 missing values
drop if missing(ativ_fis)

tab area_verd, miss
*0 missing values
drop if missing(area_verd)

tab isolam, miss
*0 missing values
drop if missing(isolam)

tab sono, miss
*0 missing values
drop if missing(sono)

tab sexo,miss
*0 missing values
drop if missing(sexo)

tab uf,miss
*0 missing values
drop if missing(uf)


tab impac_iso,miss
*0 missing values
drop if missing(impac_iso)

tab temp_mais,miss
*0 missing values
drop if missing(temp_mais)


**************** Criando variáveis*******
gen idoso = .
replace idoso = 0 if idade < 60
recode idoso .=1 if idade >59
gen idade2 = idade^2 // captar impacto não linear

gen qualres =.
recode qualres .=0 if qual_res < 4
recode qualres .=1 if qual_res >3
// Residências Boas ou ótimas somam 84% da amostra

gen vit =.
replace vit =0 if red_vit < 2 
replace vit =1 if red_vit == 2 

gen sono1 = sono
recode sono1 2=0 
recode sono1 (0=1) (1=0) //0 = normal; 1 = distúrbio no sono 

gen stress1 =stres_fam
recode stress1 1=0
recode stress1 (2=1) (3=1)

gen qpess =.
recode qpess .=0 if qtd_pes <4
recode qpess .=1 if qtd_pes > 4 // binária para "superlotação" da casa
 
 

********Criando Regiões********

recode uf (8=1) (19=1) (25=1) (13=1) ///
(16=2) (21=2) (24=2) ///
(18=3) (6=3) (10=3) (20=3) (15=3) (17=3) (2=3) (26=3) (5=3) ///
(7=4) (9=4) (12=4) (11=4) ///
(1=5) (3=5) (4=5) (14=5) (22=5) (23=5) (27=5)
label define muf 1 "sudeste" 2 "sul" 3 "nordeste" 4 "centro-oeste" 5 "norte" 
label value uf muf

gen regiao = uf

********** Criando Dummies********
tab uf, gen(duf)
tab renda, gen(drenda)  //Dummy para renda (drenda1=sem renda, drenda2=ate 1SM, drenda3= entre 1-2SM, drenda4 = entre 2-5SM, drenda5 = entre 5-8SM, drenda6 = maior 8SM)
tab regiao, gen(dregiao)  //dummy para região (Sudeste=1, Sul=2, Nordeste=3, Centro-Oeste=4, Norte=5)
tab(stres_fam), gen(dstress) //dummy para stress (dstress1 = nenhum, dstress2 = pouco, dstress3 = muito)
tab (sono), gen(dsono) // dummy para sono (dasono1= ruim, dsono2=normal, dsonoa3=dormindo mais)
tab (impac_iso), gen(dimpac_iso)


********MODELOS ESTIMADOS********

//Insalar mfx2
//mfx2 // com os efeitos marginais, fica mais fácil a interpretação. Vai te dar os coeficientes para as três opções.

* Testando diferentes vari�veis para o modelo.
******** M logit********
mlogit isolam  idoso, r
mfx2

mlogit isolam sexo, r
mfx2

mlogit isolam drenda1 drenda2 drenda3 drenda4 drenda5, r
mfx2

mlogit isolam drenda2 drenda3 drenda4 drenda5 drenda6, r
mfx2

mlogit isolam area_verd, r
mfx2

mlogit isolam ativ_fis, r
mfx2

mlogit isolam dstress1 dstress3, r
mfx2

mlogit isolam dstress1 dstress2, r
mfx2

mlogit isolam dstress2 dstress3, r
mfx2

mlogit isolam dsono1 dsono3, r
mfx2

mlogit isolam dsono1 dsono2, r
mfx2

mlogit isolam dsono2 dsono3, r
mfx2


mlogit isolam sono1, r
mfx2


mlogit isolam qpess, r // não significativo quando rodado sozinho
mfx2


***Modelo Final Adotado no artigo
mlogit isolam  idoso sexo  area_verd ativ vit dsono1 dsono3, r // b(0) escolher a categoria de comparação
mfx2, stub(total) // dentro do parenteses o nome do bodelo
