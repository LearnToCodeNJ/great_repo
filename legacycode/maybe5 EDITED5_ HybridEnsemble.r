##(To Be Implemented) Hou, Kewei. "Industry information diffusion and the lead-lag effect in stock returns." Review of Financial Studies 20.4 (2007): 1113-1138.
##(To Be Implemented) Cohen, Lauren, and Andrea Frazzini. "Economic links and predictable returns." The Journal of Finance 63.4 (2008): 1977-2011.
##(To be Implemented) Fuzzy Rule Based Classification 
##Becker, Natalia, et al. "Elastic SCAD as a novel penalization method for SVM classification tasks in high-dimensional data." BMC bioinformatics 12.1 (2011): 1.
##http://grokbase.com/t/r/r-help/05bng1f70z/r-force-apply-to-return-a-list
##http://www.r-tutor.com/r-introduction/list
##http://forums.psy.ed.ac.uk/R/P01582/essential-8/


fillNAgaps <- function(x, firstBack=FALSE) {

    lvls <- NULL
    if (is.factor(x)) {
        lvls <- levels(x)
        x    <- as.integer(x)
    }
 
    goodIdx <- !is.na(x)
    if (firstBack)   goodVals <- c(x[goodIdx][1], x[goodIdx])
    else             goodVals <- c(NA,            x[goodIdx])

    fillIdx <- cumsum(goodIdx)+1
    
    x <- goodVals[fillIdx]
    if (!is.null(lvls)) {
        x <- factor(x, levels=seq_along(lvls), labels=lvls)
    }

    x
}

######################################################################
library(devtools)
devtools::install_github("berndbischl/ParamHelpers",force=TRUE)

####### Load Multiple Libraries Simultaneously #######################
ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)}

packages <- c("quantmod", "Quandl", "robustbase","VGAM","gamlss","gamlss.add","GenSA","rugarch","VineCopula","quantreg","mgcv","rvest",
              "PerformanceAnalytics","forecast","spd","StableEstim","fExtremes","RCurl","pracma","Aelasticnet","FRAPO","tseries",
              "clue","hybridHclust","PortfolioAnalytics","hybridEnsemble","stringi","glmnet","ncvreg","mboost","hmms","depmixS4","extraTrees",
              "penalizedSVM","LiblineaR","svmpath","NHEMOtree","mlr","SparseLearner","svmadmm","HDclassif","splsda","caret","gbm","frbs",
              "mxnet","rnn","OneR","ParamsHelper","lfda","mgm")

ipak(packages);setInternet2(TRUE);con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con);close(con)
###################################################################### 




##############################################################################################
tickers<-c("AAPL","GOOGL","GE","MSFT","BRK-B","XOM","WFC","JNJ","AMZN","JPM","WMT","PFE",
           "T","VZ","PG","DIS","BAC","KO","ORCL","GILD","C","HD","MRK","IBM","CVX","CMCSA",
           "INTC","PEP","CSCO","AGN","SPY")

getSymbols(tickers,src = 'yahoo',from="2005-12-27", to="2014-12-31")

### Extract Adjusted Prices, Closing Prices and Volume ########### 
FINAL_Prices=do.call(cbind, lapply(tickers, function(x) {Ad(get(x))}))
Closing_Prices=do.call(cbind, lapply(tickers, function(x) {Cl(get(x))}))[,-ncol(FINAL_Prices),drop=FALSE]
Volume_Assets=do.call(cbind,lapply(tickers, function(x) {Vo(get(x))}))[,-ncol(FINAL_Prices),drop=FALSE]
Hi_Prices=do.call(cbind, lapply(tickers, function(x) {Hi(get(x))}))[,-ncol(FINAL_Prices),drop=FALSE]
Lo_Prices=do.call(cbind, lapply(tickers, function(x) {Lo(get(x))}))[,-ncol(FINAL_Prices),drop=FALSE]

##################################################################

PROP_INT=function(x,MINNA=3){   INDEXX=index(x)
                                if(any(is.na(x[1:MINNA]))){MIN=which.min(is.na((x)==FALSE))
                                                        (zoo(c(unclass(x[1:(MIN+MINNA)]),(na.interp(x[-c(1:(MIN+MINNA))]))),INDEXX))
                               }else {zoo(na.interp(x),INDEXX)
                             }}

FINAL_AdjPrices<-apply(FINAL_Prices,2,function(x){PROP_INT(x)}); FINAL_AdjPrices=zoo(FINAL_AdjPrices, index(FINAL_Prices))
FINAL_LogRet<-suppressWarnings(do.call(cbind,lapply(FINAL_AdjPrices,function(u) dailyReturn(as.xts(u),type="log"))))
FINAL_LogRet<-FINAL_LogRet[-1,];colnames(FINAL_LogRet)=gsub(".Adjusted","",colnames(FINAL_Prices))
FINAL_PORT_RET=FINAL_LogRet[,-ncol(FINAL_LogRet)];SP500_RET=FINAL_LogRet[,ncol(FINAL_LogRet)]

getSymbols(tickers,src = 'yahoo',from="2002-12-27", to="2014-12-31")
EXT_FINAL_Prices=do.call(cbind, lapply(tickers, function(x) {Ad(get(x))}))
PROP_INT=function(x,MINNA=3){   INDEXX=index(x)
                                if(any(is.na(x[1:MINNA]))){MIN=which.min(is.na((x)==FALSE))
                                                        (zoo(c(unclass(x[1:(MIN+MINNA)]),(na.interp(x[-c(1:(MIN+MINNA))]))),INDEXX))
                               }else {zoo(na.interp(x),INDEXX)
                             }}

EXT_FINAL_AdjPrices<-apply(EXT_FINAL_Prices,2,function(x){PROP_INT(x)}); EXT_FINAL_AdjPrices=zoo(EXT_FINAL_AdjPrices, index(EXT_FINAL_Prices))
EXT_FINAL_LogRet<-suppressWarnings(do.call(cbind,lapply(EXT_FINAL_AdjPrices,function(u) dailyReturn(as.xts(u),type="log"))))
EXT_FINAL_LogRet<-EXT_FINAL_LogRet[-1,];colnames(EXT_FINAL_LogRet)=gsub(".Adjusted","",colnames(EXT_FINAL_Prices))
EXT_FINAL_PORT_RET=EXT_FINAL_LogRet[,-ncol(EXT_FINAL_LogRet)];SP500_RET=EXT_FINAL_LogRet[,ncol(EXT_FINAL_LogRet)]
####### END/Extract Properly Interpolated Log Returns #####################

###### Market Capitalization Data #######
MKTCAP=c(7.2901e10,1.4177e10,1.0633e10,2.1006e10,1.0338e10,1.0338e10,1.863e11,1.6029e11,1.6254e10,1.325e10,
1.0338e10,2.3763e10,1.0338e10,1.0338e10,4.4804e10,5.1764e10,4.8789e10,3.00085e10,1.0338e10,2.96e10,3.7826e10,
2.5323e10,1.9323e10,2.5323e10,7.290e10,7.2901e10,1.4688e10,1.307e10,7.2901e10,1.755e10)
MKTCAP_Weights= MKTCAP/sum(MKTCAP)
#########################################

########### Robust Skewness Measures ###########################
Hinkley_SKEW=function(x,PP){LIST=c(1-PP,0.50,PP);QUANTS=do.call(c,lapply(1:length(LIST),function(i){quantile(x,LIST[i])}))
                            ROB_SKEW=((QUANTS[1]-QUANTS[2])-(QUANTS[2]-QUANTS[3]))/((QUANTS[1]-QUANTS[3])); return(as.numeric(ROB_SKEW))}

Bali2011_SKEWProxy=function(x,N=21){MAX_SKEW=max(x[1:N])}
MEDCouple=function(x){mc(x)}
#########################################################

## Consistent with recent theories, we find that expected idiosyncratic skewness and returns are negatively correlated. Specifically, the Fama-French alpha 
## of a low-expected-skewness quintile exceeds the alpha of a high-expected-skewness quintile by 1.00% per month. Furthermore, the coefficients on expected 
## skewness in Fama-MacBeth cross-sectional regressions are negative and significant. In addition, we find that expected skewness helps explain the phenomenon
## that stocks with high idiosyncratic volatility have low expected returns. 



################################ Time in Regime Indicator Functions ##################################################

SimpleUPTIR=function(data,CRITUP){ZZ=ifelse(data>CRITUP,1,0);CC=function(x){tmp<-cumsum(x);tmp-cummax((!x)*tmp)}
                                  return(CC(ZZ))}

SimpleDWNTIR=function(data,CRITDN){ZZ=ifelse(data<CRITDN,1,0);CC=function(x){tmp<-cumsum(x);tmp-cummax((!x)*tmp)}
                                  return(CC(ZZ))}

StrEXP=function(x,phi,beta){exp(-(x/phi)^beta)}
DMMUP_HYBRIDTIR=function(data,D0=5,phi=5,beta=0.5,K1=3,K2=5,NN=10,alpha=0.01) {
i=1;TIR=rep(0,length(data));Entrance_CRIT=rep(0,length(data));EXIT_EMWACRIT=rep(0,length(data));EXIT_MAGCRIT=rep(0,length(data))

repeat{ # Repeat the following algorthim until total length is reached  

 Entrance_CRIT[i]=D0*exp(alpha*(max(tail(TIR[1:i],10))))
 if (data[i]>=Entrance_CRIT){ # Initiate a Do-While loop with Time in Regime-Dependent Entrance and Exit Magnitudes
          j=1
          repeat {
             TIR[i]=j;j=j+1;i=i+1
                   # The Do-While loop breaks if EMA(data,n)<=K1*(1+StrEXP(max(TIR,0),phi,beta)))
                   # or data<=K2*(1+StrEXP(max(TIR,0),phi,beta))) where K1<K2
             DataX=data[1:i];EWMA_data=as.numeric(na.remove(EMA(DataX,n=ifelse(length(DataX)<NN,length(DataX),NN)))) 
             EXIT_EMWACRIT[i]=K1*(1+StrEXP(max(j,0),phi,beta));EXIT_MAGCRIT[i]=K2*(1-StrEXP(max(j,0),phi,beta))
             if (tail(EWMA_data,1)<EXIT_EMWACRIT[i]||data[i]<EXIT_MAGCRIT[i]){break}
                     }
 }else{TIR[i]=0; i=i+1}
 if (i>length(data)){break}
  }
return(list(TIR=TIR,ENT=Entrance_CRIT,EXIT_EWMA=EXIT_EMWACRIT,EXIT_MAG=EXIT_MAGCRIT))}


DMMDWN_HYBRIDTIR=function(data,D0=3,phi=5,beta=0.5,K1=4,K2=5,NN=10) {
i=1;TIR=rep(0,length(data))

repeat{
 if (data[i]<=D0*exp(alpha*(max(tail(TIR[1:i],10))))){ # Initiate a Do-While loop with Time in Regime Dependent Exit Magnitude
          j=1
          repeat {
             TIR[i]=j;j=j+1;i=i+1
                  # The Do-While loop breaks iff EMA(data)>K1*(1+StrEXP(max(TIR,0),phi,beta)))
                  # or data>K2*(1+StrEXP(max(TIR,0),phi,beta)))
             DataX=data[1:i];EWMA_data=as.numeric(na.remove(EMA(DataX,n=ifelse(length(DataX)<NN,length(DataX),NN))))        
             if (tail(EWMA_data,1)>K1*(1-StrEXP(max(j,0),phi,beta))||data[i]>K2*(1-StrEXP(max(j,0),phi,beta))){break}
                     }
 }else{ TIR[i]=0; i=i+1}
 if (i>length(data)){break}
  }
return(TIR)}


#########################################################################################################################


TUW_GENDD=function(x,w,power,CRIT){

DD<-function(x){
    value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
    ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                }
TUW<-function(x){
         value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
         DDX<-DD(x);DDIND=ifelse(DDX<=-CRIT,1,0)
         tmp<-cumsum(DDIND);HH=tmp-cummax((!DDIND)*tmp);return(HH)}
UU=(mean((log(1+TUW(x))^w*DD(x))^power))^(1/power); return(UU)}


TUW_GENDDRatio=function(x,w,power1,power2,CRIT=0.3){

      DD<-function(x){
          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])}
      DU<-function(x){
          value<-cumprod(c(1,1+x));cumminValue<-cummin(value)
          ZZ=(value-cumminValue)/cumminValue; return(ZZ[-1])}

      TUW_DD<-function(x,CRITX=CRIT){
              value<-cumprod(c(1,1+x));DDX=DD(x);DDIND=ifelse(DDX<=-CRITX,1,0)
              tmp<-cumsum(DDIND);HH=tmp-cummax((!DDIND)*tmp);return(HH)}
      TUW_DU<-function(x,CRITX=CRIT){
              value<-cumprod(c(1,1+x));DUX=DU(x);DDIND=ifelse(DUX>=CRITX,1,0)
              tmp<-cumsum(DDIND);HH=tmp-cummin((!DDIND)*tmp);return(HH)}

DDD=(mean((log(1+TUW_DD(x))^w*abs(DD(x)))^power2))^(1/power2)
UUU=(mean((log(1+TUW_DU(x))^w*DU(x))^power1))^(1/power1)
return(UUU/DDD)} 

#######################@@@@@@@@@@@@@@@@



#####################################  Tail Based and Risk Adjusted Measure Asset Ranking #######################################

GENHYB_TCR=function(data,Market, HI="quantile(data,0.1)",HM="quantile(Market,0.1)"){
           data=as.numeric(data); Market=as.numeric(Market)
           HIi=eval(parse(text=HI));HMm=eval(parse(text=HM))
           ZZ=mean(((data-HIi)*(Market-HMm))[data<HIi]); return(ZZ)}

FT_ASSET=function(data,p,q,MinAR){MA=eval(parse(text=MinAR));xlower=MA-data; xupper=data-MA
                                  xlower[xlower<0]<-0; xupper[xupper<0]<-0
                                  FT=(mean((xupper)^p))^(1/p)/(mean((xlower)^q))^(1/q);return(FT)}

Sharpe=function(x,RFF){EXC_RET=mean(x-RFF);SD=sd(x);SHARPE=EXC_RET/SD; return(SHARPE)}

Israelsan_ModSharpe=function(x,RFF){EXC_RET=mean(x-RFF); SD=sd(x)
                                    IMS=EXC_RET/SD^(EXC_RET/abs(EXC_RET)); return(IMS)}

Peizar_ASR=function(x,RFF){ skew=as.numeric(skewness(x));kurt=as.numeric(kurtosis(x))

             Israelsan_ModSharpe=function(x,RFF){EXC_RET=mean(x)-mean(RFF); SD=sd(x)
                                 IMS=EXC_RET/SD^(EXC_RET/abs(EXC_RET)); return(IMS)}

             SRR=Israelsan_ModSharpe(x,RFF); ZZ=SRR*(1+(skew/6)*SRR-((kurt-3)/24)*SRR^2);return(ZZ)}


Modified_ASR=function(x,RFF,SKEWCRITX=0.04,lambdaX=0.1){ skew=as.numeric(skewness(x));kurt=as.numeric(kurtosis(x))
             
              LSTAR=function(u,SKEWCRIT=SKEWCRITX,lambda=lambdaX){(1+exp(-lambda*(u-SKEWCRIT)))^-1}
              Israelsan_ModSharpe=function(x,RFF){EXC_RET=mean(x-RFF); SD=sd(x)
                                  IMS=EXC_RET/SD^(EXC_RET/abs(EXC_RET)); return(IMS)}

              SRR=Israelsan_ModSharpe(x,RFF); ZZ=SRR*(1+(skew/6)*SRR+(2*LSTAR(skew)-1)*((kurt-3)/24)*SRR^2);return(ZZ)}


AutoCORR_Sharpe=function(x,RFF,q=12){

                CORR=acf(x,lag.max=q,plot=FALSE)$acf[-1];k=1:(q-1);nq=q/sqrt(q+2*sum((q-k)*CORR[k]))
                Israelsan_ModSharpe=function(x,RFF){EXC_RET=mean(x)-mean(RFF); SD=sd(x)
                                    IMS=EXC_RET/SD^(EXC_RET/abs(EXC_RET)); return(IMS)}

                SRR=Israelsan_ModSharpe(x,RFF); return(nq*SRR)}


ASKR_Sharpe=function(x,RFF){

            U=mean(x);SD=sd(x);SKEW=as.numeric(skewness(x)); KURT=as.numeric(kurtosis(x))
            Israelsan_ModSharpe=function(x,RFF){EXC_RET=mean(x)-mean(RFF); SD=sd(x)
                                IMS=EXC_RET/SD^(EXC_RET/abs(EXC_RET)); return(IMS)}

            SRR=Israelsan_ModSharpe(x=x,RFF=RFF)
            alpha=(3*sqrt(3*KURT-4*SKEW^2-9))/(SD^2*(3*sqrt(3*KURT-5*SKEW^2-9)))
            beta=(3*SRR)/(SD*(3*sqrt(3*KURT-5*SKEW^2-9)))
            eta=U-(3*SKEW*SD)/(3*KURT-4*SKEW^2-9)
            delta=(3*SD)*sqrt(3*KURT-5*SKEW^2-9)/(3*KURT-4*SKEW^2-9)
            phi=sqrt(alpha^2+beta^2)
            opt_alpha=beta+alpha*(eta-U)/sqrt(delta^2+(eta-U)^2)

return(exp(2*(opt_alpha*(eta-mean(RFF))-delta*(phi-sqrt(alpha^2-(beta-opt_alpha)^2)))))}
     

ADJ_GENDDRR=function(data,q1=0.05,q2=0.05,power1=1,power2=2){ 
VaR=fExtremes::VaR

   ABS_GENDD=function(x){
             value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
             ZZ=(value-cummaxValue);return(zoo(ZZ[-1],index(x)))}
   ABS_GENDU=function(x){
             value<-cumprod(c(1,1+x));cumminValue<-cummin(value)
             ZZ=(value-cumminValue);return(zoo(ZZ[-1],index(x)))}

ABSDD=ABS_GENDD(data);ABSDU=ABS_GENDU(data)

# Step 1: Calculate Value-at-Risk 

VaRUpper=VaR(ABSDU,alpha=(1-q1));VaRLower=VaR(ABSDD,alpha=(q2))

#Step 2 Subset the data 
UpperSubset=ABSDU[as.numeric(ABSDU)>=as.numeric(VaRUpper)]
LowerSubset=ABSDD[as.numeric(ABSDD)<=as.numeric(VaRLower)]

if(length(UpperSubset)==0){
                      GRR=0
}  else if (length(LowerSubset)==0){
                     GRR=100
} else
#SubsetXU=UpperSubset[UpperSubset>0,UpperSubset,0]
#SubsetXD=LowerSubset[LowerSubset<0,LowerSubset,0]

SubsetXU=ifelse(UpperSubset>0,UpperSubset,0)
SubsetXD=ifelse(LowerSubset<0,LowerSubset,0)

# Step 4: Calculate Generalized Mean from ratio of [E(X^p)]^(1/p) for the subset data 
# Step 4: Calculate Generalized Mean from ratio of [E(X^p)]^(1/p) for the subset data 
GRRU=(mean(abs(SubsetXU)^power1))^(1/power1)
GRRD=(mean(abs(SubsetXD)^power2))^(1/power2)
GRR=GRRU/GRRD
GRR}


GENDD=function(x,RFF,power=1){
       Economic_DrawDown<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
                          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                                          }
power=power;GENDD=(mean(abs(Economic_DrawDown(x,RFF))^power))^(1/power);return(GENDD)}


GEN_ECONDD=function(x,RFF,power=1){
       Economic_DrawDown<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                                          }
power=power;GENDD=(mean(abs(Economic_DrawDown(x,RFF))^power))^(1/power);return(GENDD)}


GEN_ECONDU=function(x,RFF,power=1){
       Economic_DrawUP<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cumminValue<-cummin(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cumminValue)/cumminValue; return(ZZ[-1])
                                          }
power=power;GENDU=(mean(abs(Economic_DrawUP(x,RFF))^power))^(1/power);return(GENDU)}


GENDD_ECONRATIO=function(x,RFF,power1,power2){

GEN_ECONDD=function(x,RFF,power=1){
        Economic_DrawDown<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                                          }
power=power;GENDD=(mean(abs(Economic_DrawDown(x,RFF))^power))^(1/power);return(GENDD)}

GEN_ECONDU=function(x,RFF,power=1){
       Economic_DrawUP<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cumminValue<-cummin(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cumminValue)/cumminValue; return(ZZ[-1])
                                          }
power=power;GENDU=(mean(abs(Economic_DrawUP(x,RFF))^power))^(1/power);return(GENDU)}
GENDD_RATIO=GEN_ECONDU(x=x,RFF=RFF,power=power1)/GEN_ECONDD(x=x,RFF=RFF,power=power2);return(GENDD_RATIO)}


DownCORR=function(data,MAR,RFF,method){EXCESSMAR=MAR-RFF; AVGEXC=mean(EXCESSMAR)
                  DOWN_Data=data[EXCESSMAR<=AVGEXC];DOWN_MAR=EXCESSMAR[EXCESSMAR<=AVGEXC]
                  DOWN_CORR=cor(DOWN_Data,DOWN_MAR,method=method);return(DOWN_CORR)}

DOWNTailCoSKEW=function(data,Market,LowerQuantile){
               RSTD=data-mean(data);MARSTD=Market-mean(Market); N=nrow(RSTD)
               ZZ=RSTD*MARSTD^2;ZZ=ZZ[RSTD<quantile(RSTD,LowerQuantile)]
               TCS=((1/N)*sum(ZZ))/(sqrt(mean((RSTD)^2))*mean(MARSTD^2));return(TCS)}

CoSKEW=function(data,Market){
               RSTD=data-mean(data);MARSTD=Market-mean(Market); N=nrow(RSTD)
               CS=mean(RSTD*MARSTD^2)/(sqrt(mean((RSTD)^2))*mean(MARSTD^2));return(CS)}

CAPMRES_CoSKEW=function(data,Market,IRR){
               ExcessRet=data-IRR; ExcessMAR=Market-IRR
               MARSTD=Market-mean(Market);RES=residuals(rlm(ExcessRet~ExcessMAR)); 
               CRCS=mean(RES*MARSTD^2)/(sqrt(mean((RES)^2))*mean(MARSTD^2));return(CRCS)}


BetaData=function(data,MAR){BETA=cov(data,MAR)/var(MAR); return(BETA)}

AsymmBeta=function(data,MAR,RFF){EXCESSMAR=MAR-RFF; AVGEXC=mean(EXCESSMAR)
                                 UP_Data=data[EXCESSMAR>AVGEXC];DOWN_Data=data[EXCESSMAR<=AVGEXC]
                                 UP_MAR=EXCESSMAR[EXCESSMAR>AVGEXC];DOWN_MAR=EXCESSMAR[EXCESSMAR<=AVGEXC]
                                 UP_BETA=BetaData(UP_Data,UP_MAR); DOWN_BETA=BetaData(DOWN_Data,DOWN_MAR)
                                 return(UP_BETA-DOWN_BETA)}

UP_DownCORR=function(data,MAR,RFF,method="kendall"){ 
                                 EXCESSMAR=MAR-RFF; AVGEXC=mean(EXCESSMAR)
                                 UP_Data=data[EXCESSMAR>AVGEXC];DOWN_Data=data[EXCESSMAR<=AVGEXC]
                                 UP_MAR=EXCESSMAR[EXCESSMAR>AVGEXC];DOWN_MAR=EXCESSMAR[EXCESSMAR<=AVGEXC]
                                 UP_CORR=cor(UP_Data,UP_MAR,method=method); DOWN_CORR=cor(DOWN_Data,DOWN_MAR,method=method)
                                 return(UP_CORR-DOWN_CORR)}

DownCORR=function(data,MAR,RFF,method="kendall"){ 
                                 EXCESSMAR=MAR-RFF; AVGEXC=mean(EXCESSMAR)
                                 DOWN_Data=data[EXCESSMAR<=AVGEXC];DOWN_MAR=EXCESSMAR[EXCESSMAR<=AVGEXC]
                                 DOWN_CORR=cor(DOWN_Data,DOWN_MAR,method=method)
                                 return(DOWN_CORR)}

Idiosync_VOL=function(data,MAR,RFF){EXCESSMAR=MAR-RFF; CAPM=lm(data~EXCESSMAR)
                                    STD_RES=sd(residuals(CAPM));return(STD_RES)}

Idiosync_SKEW=function(data,MAR,RFF){EXCESSMAR=MAR-RFF; CAPM=lm(data~EXCESSMAR)
                                    SKEW_RES=skewness(residuals(CAPM));return(SKEW_RES)}

Idiosync_KURT=function(data,MAR,RFF){EXCESSMAR=MAR-RFF; CAPM=lm(data~EXCESSMAR)
                                     KURT_RES=kurtosis(residuals(CAPM));return(KURT_RES)}

runMAX=function(x){
       NN=length(x);RMAX=do.call(c,lapply(1:NN,function(i){max(x[1:i])}))
       return(zoo(RMAX,index(x)))}

CDaR=function(alpha,X){  
     DD<-function(x){value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
         ZZ=(cummaxValue-value);return(ZZ[-1])}
     
     NN=length(X);IND_CDAR=function(X,QQ,alpha,NN){return(ifelse(X>=QQ,1/((1-alpha)*NN),0))}
     DrawDown=DD(X);QQ=quantile(DrawDown,alpha);IND_CDARX=IND_CDAR(DrawDown,QQ,alpha,NN)
     CDaR=sum(IND_CDARX*DrawDown);return(CDaR)}

CoSKEW=function(R,Market){
       RSTD=R-mean(R);MARSTD=Market-mean(Market); N=nrow(RSTD)
       CS=mean(RSTD*MARSTD^2)/(sqrt(mean((RSTD)^2))*mean(MARSTD^2));return(CS)}

CoKURT<-as.numeric(lapply(1:ncol(data), function(i){
            -centeredcomoment(as.xts(data[,i]),as.xts(MARKET),p1=1,p2=3,normalize=TRUE)}))

Beta_CoSKEW=function(R,Market){
            RSTD=R-mean(R);MARSTD=Market-mean(Market); N=nrow(RSTD)
            CS=mean(RSTD*MARSTD^2)/(sqrt(mean((RSTD)^2))*mean(MARSTD^2))
            return(CS/as.numeric(PerformanceAnalytics::skewness(Market)))}

CAPMRES_CoSKEW=function(R,Market,IRR){
               ExcessRet=R-IRR; ExcessMAR=Market-IRR
               MARSTD=Market-mean(Market);RES=residuals(rlm(ExcessRet~ExcessMAR)); 
               CRCS=mean(RES*MARSTD^2)/(sqrt(mean((RES)^2))*mean(MARSTD^2));return(CRCS)}

US_TailCoSKEW=function(R,Market,UpperQ,LowerQ){
              RSTD=R-mean(R);MARSTD=Market-mean(Market); N=nrow(RSTD)
              ZZ=RSTD*MARSTD^2;ZZ=ZZ[RSTD>quantile(RSTD,UpperQ)||RSTD<quantile(RSTD,LowerQ)]
              TCS=((1/N)*sum(ZZ))/(sqrt(mean((RSTD)^2))*mean(MARSTD^2));return(TCS)}

DOWN_TailCoSKEW=function(R,Market,LowerQ){
               RSTD=R-mean(R);MARSTD=Market-mean(Market); N=nrow(RSTD)
               ZZ=RSTD*MARSTD^2;ZZ=ZZ[RSTD<quantile(RSTD,LowerQ)]
               TCS=((1/N)*sum(ZZ))/(sqrt(mean((RSTD)^2))*mean(MARSTD^2));return(TCS)}

Beta_CDaR=function(alpha,XM,X){

##### Calculate length,Market DrawDown, Market Quantile,Indicator Qt, Market CDaR ##################
      DD<-function(x){value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
         ZZ=(cummaxValue-value);return(ZZ[-1])}

      NN=length(X);MAR_DD=DD(XM);MAR_QQ=quantile(MAR_DD,alpha);MAR_runMAX=cummax(XM)
      IND_CDAR=function(X,QQ,alpha,NN){return(ifelse(X>=QQ,1/((1-alpha)*NN),0))}
      MAR_CDaR=CDaR(alpha=alpha,X=XM)

Beta_CDARX=sum(IND_CDAR(XM,MAR_QQ,alpha,NN)*(MAR_runMAX-cumsum(X)))
return(Beta_CDARX)}

Tail_Index=function(x,QQ=0.8){ 
                 x= as.numeric(-x); TI=max(0,attributes(gpdFit(x,u=quantile(x,QQ),type="mle"))$fit$fit$par[1])
                 return(TI)}        

GENDD_Ratio=function(x, power1,power2){

ABS_GENDD=function(x, power1){
DD<-function(x){
           value<-cumprod(c(1,1+x));cummaxValue<-cummax(value)
           ZZ=(value-cummaxValue);return(ZZ[-1])}
GENDD=(mean(abs(DD(x))^power1))^(1/power1);return(GENDD)}

ABS_GENDU=function(x, power2){
DU<-function(x){
           value<-cumprod(c(1,1+x));cumminValue<-cummin(value)
           ZZ=(value-cumminValue);return(ZZ[-1])}
GENDU=(mean(abs(DU(x))^power2))^(1/power2);return(GENDU)}

ABSDD=ABS_GENDD(x,power1);ABSDU=ABS_GENDU(x,power2);return(ABSDU/ABSDD)}


GEN_ECONDD=function(x,RFF,power=1){

       Economic_DrawDown<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                                          }
power=power;GENDD=(mean(abs(Economic_DrawDown(x,RFF))^power))^(1/power);return(GENDD)}


GEN_ECONDU=function(x,RFF,power=1){

       Economic_DrawUP<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cumminValue<-cummin(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cumminValue)/cumminValue; return(ZZ[-1])
                                          }
power=power;GENDU=(mean(abs(Economic_DrawUP(x,RFF))^power))^(1/power);return(GENDU)}


GENDD_ECONRATIO=function(x,RFF,power1,power2){


GEN_ECONDD=function(x,RFF,power=1){

       Economic_DrawDown<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cummaxValue<-cummax(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cummaxValue)/cummaxValue; return(ZZ[-1])
                                          }
power=power;GENDD=(mean(abs(Economic_DrawDown(x,RFF))^power))^(1/power);return(GENDD)}


GEN_ECONDU=function(x,RFF,power=1){

       Economic_DrawUP<-function(x,RFF){
                          value<-cumprod(c(1,1+x));cumminValue<-cummin(value*rev(c(1,cumprod((1+RFF)))))
                          ZZ=(value-cumminValue)/cumminValue; return(ZZ[-1])
                                          }
power=power;GENDU=(mean(abs(Economic_DrawUP(x,RFF))^power))^(1/power);return(GENDU)}


GENDD_RATIO=GEN_ECONDU(x=x,RFF=RFF,power=power1)/GEN_ECONDD(x=x,RFF=RFF,power=power2);return(GENDD_RATIO)}

Tail_Index=function(x){x=as.numeric(-x); TI=max(0,attributes(gpdFit(x,u=quantile(x,0.9),type="mle"))$fit$fit$par[1]);return(TI)}

######################### Acceleration Functions #####################################################################
STDCUMRET1_ACC=function(RET,LEAD){stdCUMRET=function(x){NN=length(x);SD=sd(x);ZZ=cumsum(x)[NN];return(as.numeric(ZZ/SD))}
                                  NN=length(RET);ZZ=stdCUMRET(RET[c((LEAD*NN):NN)])-stdCUMRET(RET[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}

STDCUMRET2_ACC=function(RET){stdCUMRET=function(x){NN=length(x);SD=sd(x);ZZ=cumsum(x)[NN];return(as.numeric(ZZ/SD))}
                                  NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)));ZZ=stdCUMRET(EXP_W*RET);return(as.numeric(ZZ))}

GENMEAN1_ACC=function(RET,power,LEAD){NN=length(RET); GENMEAN=function(x,power){(mean(abs(x)^power))^(1/power)}
              ZZ=GENMEAN(RET[c((LEAD*NN):NN)],power)-GENMEAN(RET[c(1:(LEAD*NN))],power);return(ZZ)}

GENMEAN2_ACC=function(RET,power){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)))
             GENMEAN=function(x,power){(mean(abs(x)^power))^(1/power)};ZZ=GENMEAN(EXP_W*RET,power);return(ZZ)}

GENDD_RATIO1_ACC=function(RET,p,q,LEAD){NN=length(RET);ZZ=GENDD_Ratio(RET[c((LEAD*NN):NN)],p,q)-GENDD_Ratio(RET[c(1:(LEAD*NN))],p,q); return(ZZ)}
GENDD_RATIO2_ACC=function(RET,p,q){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)));ZZ=GENDD_Ratio(EXP_W*RET,p,q);return(ZZ)}

GENDD1_ACC=function(RET,power1,LEAD){NN=length(RET);ZZ=GENDD(RET[c((LEAD*NN):NN)],power1)-GENDD(RET[c(1:(LEAD*NN))],power1); return(ZZ)}
GENDD2_ACC=function(RET,power1){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)));ZZ=GENDD(EXP_W*RET,power1); return(ZZ)}

FT1_ACC=function(RET,p,q,LEAD){NN=length(RET);ZZ=FT_ASSET(RET[c((LEAD*NN):NN)],p,q,MINAR)-FT_ASSET(RET[c(1:(LEAD*NN))],p,q,MINAR); return(ZZ)}
FT2_ACC=function(RET,p,q){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)));ZZ=FT_ASSET(EXP_W*RET,p,q,MINAR); return(ZZ)}
 
GENDDRR1_ACC=function(RET,p,q,LEAD){NN=length(RET);ZZ=ADJ_GENDDRR(RET[c((LEAD*NN):NN)],q1=0.05,q2=0.05,p,q)-
                                                     ADJ_GENDDRR(RET[c(1:(LEAD*NN))],q1=0.05,q2=0.05,p,q);return(ZZ)}

GENDDRR2_ACC=function(RET,p,q){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)))
                              ZZ=ADJ_GENDDRR(EXP_W*RET,q1=0.05,q2=0.05,p,q);return(ZZ)}

GENHYBTCR1_ACC=function(RET,MAR,power1,LEAD){NN=length(RET);FIRST_D=RET[c((LEAD*NN):NN)];SECOND_D=RET[c(1:(LEAD*NN))]
                                            FIRST_MAR=MAR[c((LEAD*NN):NN)];SECOND_MAR=MAR[c(1:(LEAD*NN))]
                                            ZZ=GENHYB_TCR(FIRST_D,Market=FIRST_MAR,HI="quantile(data,0.1)",HM="quantile(Market,0.1)")
                                            -GENHYB_TCR(SECOND_D,Market=SECOND_MAR,HI="quantile(data,0.1)",HM="quantile(Market,0.1)");return(ZZ)}

GENHYBTCR2_ACC=function(RET,MAR,power1){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)));RET_D=EXP_W*RET; RET_MAR=EXP_W*MAR
                                        ZZ=GENHYB_TCR(data=RET_D,Market=EXP_W*MAR,HI="quantile(data,0.1)",HM="quantile(Market,0.1)");return(ZZ)}

DownCORR_ACC=function(data,MAR,RFF,method="kendall",LEAD){ NN=length(data) 
              DownCORR=function(data,MAR,RFF,method="kendall"){EXCESSMAR=MAR-RFF; AVGEXC=mean(EXCESSMAR);DOWN_Data=data[EXCESSMAR<=AVGEXC]
              DOWN_MAR=EXCESSMAR[EXCESSMAR<=AVGEXC];DOWN_CORR=cor(DOWN_Data,DOWN_MAR,method=method);return(DOWN_CORR)}
              ZZ=DownCORR(data[c((LEAD*NN):NN)],MAR[c((LEAD*NN):NN)],RFF[c((LEAD*NN):NN)])-
              DownCORR(data[c(1:(LEAD*NN))],MAR[c(1:(LEAD*NN))],RFF[c(1:(LEAD*NN))]); return(ZZ)}

TailIndex2_ACC=function(RET,LEAD,lambda=10){NN=length(RET);tT=(1:NN)/NN;EXP_W=-1+2/(1+exp(-lambda*(tT-0.5)))
                                            ZZ=Tail_Index(EXP_W*RET); return(ZZ)}

SKEW_ACC=function(RET,LEAD){NN=length(RET);ZZ=skewness(RET[c((LEAD*NN):NN)])-skewness(RET[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
KURT_ACC=function(RET,LEAD){NN=length(RET);ZZ=kurtosis(RET[c((LEAD*NN):NN)])-kurtosis(RET[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
Vol_ACC=function(RET,LEAD){NN=length(RET);ZZ=sd(RET[c((LEAD*NN):NN)])-sd(RET[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
Volume1_ACC=function(Volume,LEAD){NN=length(RET);ZZ=Volume[c((LEAD*NN):NN)]-Volume[c(1:(LEAD*NN))];return(as.numeric(ZZ))}
Volume2_ACC=function(Volume,LEAD){NN=length(RET);ZZ=(Volume[c((LEAD*NN):NN)]-Volume[c(1:(LEAD*NN))])/Volume[c(1:(LEAD*NN))];return(as.numeric(ZZ))}
     
CoSKEW_ACC=function(RET,MAR,LEAD){NN=length(RET);FIRST_D=RET[c((LEAD*NN):NN)];SECOND_D=RET[c(1:(LEAD*NN))]
                                  FIRST_MAR=MAR[c((LEAD*NN):NN)];SECOND_MAR=MAR[c(1:(LEAD*NN))]
                                  ZZ=CoSKEW(FIRST_D,FIRST_MAR)-CoSKEW(SECOND_D,SECOND_MAR);return(as.numeric(ZZ))} 

CoKURT_ACC=function(RET,MAR,LEAD){NN=length(RET);FIRST_D=RET[c((LEAD*NN):NN)];SECOND_D=RET[c(1:(LEAD*NN))]
                                  FIRST_MAR=MAR[c((LEAD*NN):NN)];SECOND_MAR=MAR[c(1:(LEAD*NN))]
                                  ZZ=CoKURT(FIRST_D,FIRST_MAR)-CoKURT(SECOND_D,SECOND_MAR);return(as.numeric(ZZ))} 

AMIHUDILL_ACC=function(AMIHUD,LEAD){NN=length(AMIHUD);ZZ=mean(AMIHUD[c((LEAD*NN):NN)])-mean(AMIHUD[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
RollSpread_ACC=function(AMIHUD,LEAD){NN=length(AMIHUD);ZZ=mean(AMIHUD[c((LEAD*NN):NN)])-mean(AMIHUD[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
###############  ################################################################################################################


############### Illiquidity and Bid/Ask based Measures ##################################################

AMIHUD_Illiquidity=function(RET,ClosePrice,Volume,n=21){NN=length(RET)
                           ZZ=sum(abs(RET[c((NN-n):NN)])/((ClosePrice[c((NN-n):NN)]*Volume[c((NN-n):NN)])/n)); return(ZZ)} 

AMIHUD_Illiquidity=function(data,ClosePrice,Volume,n=21){AMIHUD=function(data,ClosePrice,Volume,n){sum(abs(data)/((ClosePrice*Volume)/n))}
                   UU=zoo(cbind(data,ClosePrice,Volume),index(data));ZZ=rollapplyr(UU,n,function(UU){AMIHUD(UU[,1],UU[,2],UU[,3],n=n)}, by.column=FALSE)
                   return(zoo(fillNAgaps(ZZ,firstBack=TRUE),index(data)))}
             
Roll_Spread=function(data){laggedData=embed(data,2); 2*sqrt(abs(cov(diff(laggedData[,1]),diff(laggedData[,2]))))}
Asset_Roll_Spread=function(data){ZZ=rollapplyr(data,4,function(u)Roll_Spread(u)); zoo(fillNAgaps(ZZ,firstBack=TRUE),index(data))}

Corwin_Schultz_Spread=function(H,L){ 
            H=as.numeric(H); L=as.numeric(L);Beta=log(H[1]/L[1])^2+log(H[2]/L[2])^2;Gamma=log(H[1]/L[1])^2+log(max(H[2],H[1])/min(L[2],L[1]))^2
            alpha=(sqrt(2*Beta)-sqrt(Beta))/(3-2*sqrt(2))-sqrt((Gamma/(3-2*sqrt(2))))
            Spread=2*(exp(alpha-1))/(1+exp(alpha));return(Spread)}

Asset_Corwin_Schultz=function(data){do.call(c,lapply(1:(nrow(data)-1),function(i){Corwin_Schultz_Spread(data[i:(i+1),1],data[i:(i+1),2])}))}

#####################################################################################################

##### Information Discreteness: Simple Proxy ##############
IDDFUN=function(data){
lengthX=length(data); Neg=length(data[data<0]);Pos=length(data[data>=0])
CumSum=cumsum(data); CumRET=CumSum[length(CumSum)];ID=sign(CumRET)*((Neg-Pos)/lengthX)
return(ID)        }
###########################################################

##### Information Discreteness: Magnitude Proxy ###########
IDDMAG_1=function(data,decay){
dataX=as.ts(data);PT=ecdf(abs(as.ts(dataX)));w=exp(-decay*PT(abs(as.ts(dataX))));ww=w/sum(w)
CumRET=cumsum(dataX);IDMAG=-(1/length(CumRET))*sign(CumRET[length(CumRET)])*sum(sign(dataX)*ww)
return(IDMAG)                 }
############################################################

##### Information Discreteness: Magnitude Proxy ###########
IDDMAG_2=function(data){
dataX=as.ts(data);PT=ecdf(abs(dataX));PTT=PT(abs(dataX))

Weight_FUN=function(EC){
ZZ=ifelse(EC<=0.2, 5/15,ifelse(EC>0.2&&EC<=0.4,4/15,ifelse(EC>0.4&&EC<=0.6,3/15,
   ifelse(EC>0.6&&EC<=0.8,2/15,1/15))))
return(ZZ)             }

w=as.numeric(lapply(1:length(PTT),function(i) Weight_FUN(PTT[i])))
CumRET=cumsum(dataX);IDMAG=-(1/length(CumRET))*sign(CumRET[length(CumRET)])*sum(sign(dataX)*w)
return(IDMAG)        
        }
############################################################

##### Information Discreteness: LowDF with Generalized Mean DrawDown Error ###########
IDD_LDGENDD=function(data,p=2, maxDF=1.4){
dataX=as.ts(data) 
tT=1:length(dataX);gamX=gam(cumsum(dataX)~s(tT,maxDF),data=data.frame(dataX))
RES_LMM=residuals(gamX);ABSRES=abs(residuals(gamX));MaxDD=GENDD(RES_LMM,p)
INDX=function(ABSRES){ifelse(ABSRES<0.1,0,ifelse(ABSRES>0.1 && ABSRES<=0.5, RES_LMM,exp(0.5*ABSRES)))}
RESX=lapply(1:length(RES_LMM), function(i) INDX(ABSRES[i]))
SQRES=MaxDD*(1+0.05*sum(as.numeric(RESX)^2))
return(SQRES)                      }

##### Information Discreteness: LowDF Squared Error ###########
IDD_LDF=function(data){
dataX=as.ts(data) 
tT=1:length(dataX);lmm=gam(cumsum(dataX)~s(tT,1.4),data=data.frame(dataX))
RES_LMM=residuals(lmm);ABSRES=as.numeric(abs(RES_LMM))
INDX=function(ABSRES){ifelse(ABSRES<0.1,0,ifelse(ABSRES>0.1 && ABSRES<=0.5, RES_LMM,exp(0.5*ABSRES)))}
RESX=lapply(1:length(RES_LMM), function(i) INDX(ABSRES[i]))
SQRES=sum(as.numeric(RESX)^2)
return(SQRES)                 }

##############################################################################################################

################ Mean Non-Stationarity Measures FUNCTIONS #####################################################

CUMRET=function(x){NN=length(x);ZZ=cumsum(x)[NN];return(ZZ)}
stdCUMRET=function(x){NN=length(x);SD=sd(x);ZZ=cumsum(x)[NN];return(ZZ/SD)}

FBRUR=function(data){

data=data;data_r=rev(data)
x1i = NULL;xii = NULL;x1i_r = NULL;xii_r = NULL

for (i in 1:NROW(data)){
   mini= min(data[1:i]);maxi= max(data[1:i])
   x1i=cbind(x1i,mini);xii=cbind(xii,maxi)
   mini_r= min(data_r[1:i]);maxi_r= max(data_r[1:i])
   x1i_r=cbind(x1i_r,mini_r);xii_r=cbind(xii_r,maxi_r)
                       }
rix= as.numeric(xii-x1i);drix= diff(rix)
rix_r= as.numeric(xii_r-x1i_r);drix_r= diff(rix_r)

tt= NROW(data)- 1
stats2= ( 1/sqrt(2*tt) )*( sum(drix>0) + sum(drix_r>0) )
return(stats2)       }


RollingADF=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) suppressWarnings(adf.test(x)$p.value))}
RollingKPSS=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) suppressWarnings(kpss.test(x)$p.value))}
RollingRankADF=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) suppressWarnings(adf.test(rank(x))$p.value))}          
RollingADFEXP=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) suppressWarnings(adf.test(x,alternative ="explosive")$p.value))}
RollingRankADFEXP=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) suppressWarnings(adf.test(x,alternative ="explosive")$p.value))}
RollingFBRUR=function(data,window){data=as.numeric(data);rollapplyr(data,window,function(x) FBRUR(x))} 

supGENDD=function(x,p,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0
forwardGENDD=lapply(1:(length(x)-r0), function (i) GENDD(x[1:(r0+i)],p))
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forwardGENDD)))
}else{return(unlist(forwardGENDD))}}

supGENDD_Ratio=function(x,p1,p2,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0
forwardGENDD_Ratio=lapply(1:(length(x)-r0), function(i){GENDD_Ratio(x[1:(r0+i)],power1=p1,power2=p2)})
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forwardGENDD_Ratio)))
}else{return(unlist(forwardGENDD_Ratio))}}

supGENRachev_Ratio=function(x,p,q,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0
forwardGENRachev_Ratio=lapply(1:(length(x)-r0), function(i){ADJ_GENDDRR(x[1:(r0+i)],q1=0.05,q2=0.05,p,q)})
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forwardGENRachev_Ratio)))
}else{return(unlist(forwardGENRachev_Ratio))}}

supRank_WLJB=function(x,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0
forWLJ=lapply(1:(length(x)-r0),function(i){Weighted.Box.test(rank(as.numeric(x[1:(r0+i),])),lag=10,type="Ljung-Box",weighted=TRUE)$p.value})
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forWLJ)))
}else{return(unlist(forWLJ))}}

supCUMRET=function(x,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0   
forwardCUMRET=lapply(1:(length(x)-r0), function(i){CUMRET(x[1:(r0+i)])})
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forwardCUMRET)))
}else{return(unlist(forwardCUMRET))}}

supSTDCUMRET=function(x,r0){NN=length(x)-r0;x=na.remove(x);NNA=length(x)-r0   
forwardSTDCUMRET=lapply(1:(length(x)-r0), function(i){stdCUMRET(x[1:(r0+i)])})
if(NN>NNA){return(c(rep(NA,NN-NNA),unlist(forwardSTDCUMRET)))
}else{return(unlist(forwardSTDCUMRET))}} 


RollingGENDD_Ratio=function(data,window,p1,p2){rollapplyr(data,window,function(x,p1,p2) GENDD_Ratio(x,power1=p1,power2=p2))} 
RollingGENDD_Ratio=function(data,window,p1,p2){rollapplyr(data,window,function(x,p1,p2) GENDD_Ratio(x,power1=p1,power2=p2))} 

RollingGENDD=function(data,window,p){rollapplyr(data,window,function(x,p) GENDD(x,power=p))}          
RollingGENDU=function(data,window,p){rollapplyr(data,window,function(x,p) GENDU(x,power=p))} 
ROllingWLJB=function(data,window,p){rollapplyr(data,window,function(x,lag=10){Weighted.Box.test(rank(as.numeric(x)),
                                                                              lag=lag,type="Ljung-Box",weighted=TRUE)$p.value})} 


################################################################################################################



supClass_XREG=function(data,r0=210){

INDEX=index(data[-c(1:r0)])
sup_CUMRET=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supCUMRET(data[,i],r0=r0)})),INDEX)
sup_STDCUMRET=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supSTDCUMRET(data[,i],r0=r0)})),INDEX)

supGENDDRatio_13=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supGENDD_Ratio(data[,i],p1=1,p2=3,r0=r0)})),INDEX)
supGENDDRatio_31=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supGENDD_Ratio(data[,i],p1=3,p2=1,r0=r0)})),INDEX)
supGENDDRatio_1100=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supGENDD_Ratio(data[,i],p1=1,p2=100,r0=r0)})),INDEX)
supGENDDRatio_1001=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supGENDD_Ratio(data[,i],p1=100,p2=1,r0=r0)})),INDEX)
supGENDDRatio_100100=zoo(do.call(cbind,lapply(1:ncol(data),function(i){supGENDD_Ratio(data[,i],p1=100,p2=100,r0=r0)})),INDEX)

#supGENRachev_13=do.call(cbind,lapply(1:ncol(data),function(i){supGENRachev_Ratio(data[,i],p=1,q=3,r0=r0)}))
#supGENRachev_31=do.call(cbind,lapply(1:ncol(data),function(i){supGENRachev_Ratio(data[,i],p=3,q=1,r0=r0)}))
#supGENRachev_1100=do.call(cbind,lapply(1:ncol(data),function(i){supGENRachev_Ratio(data[,i],p=1,q=100,r0=r0)}))
#supGENRachev_1001=do.call(cbind,lapply(1:ncol(data),function(i){supGENRachev_Ratio(data[,i],p=100,q=1,r0=r0)}))
#supGENRachev_100100=do.call(cbind,lapply(1:ncol(data),function(i){supGENRachev_Ratio(data[,i],p=100,q=100,r0=r0)}))

supWLBJ=do.call(cbind,lapply(1:ncol(data),function(i)supRank_WLJB(data[,i],r0=r0)))

return(list(CUMRET=sup_CUMRET,STDCUMRET=sup_STDCUMRET,GENDDR13=supGENDDRatio_13,GENDDR31=supGENDDRatio_31,
            GENDDR1100=supGENDDRatio_1100,GENDDR1001=supGENDDRatio_1001,GENDDR100100=supGENDDRatio_100100, WLBJ=supWLBJ))}

supXXREG=supClass_XREG(data=FINAL_PORT_RET,r0=210)
       





do.call(cbind,lapply(1:ncol(supXXREG[[j]]),function(i){ZZ=(diff(supXXREG[[j]][,i]));ZZ[is.na(ZZ)]=ZZ[2];ZZ}))

supXXREG[[1]]



supFDIFFClass_XREG=function(sup_XREG){LIST_NAMES=attributes(sup_XREG)$names;LIST_NN=length(LIST_NAMES)
                                      RES=list();LIST_DIM=lapply(1:LIST_NN,function(i){dim(sup_XREG[[i]])})
                                      




supSDIFFClass_XREG=function(sup_XREG){



FDIFF_supGENDDRatio=do.call(cbind,lapply(1:ncol(supGENDDRatio_13),function(i){ZZ=diff(supGENDDRatio_13[,i],na.pad=TRUE);ZZ[is.na(ZZ)]=ZZ[2]}))
SDIFF_supGENDDRatio=do.call(cbind,lapply(1:ncol(supGENDDRatio),function(i){ZZ=diff(supGENDDRatio[,i],na.pad=TRUE,differences=2));ZZ[is.na(ZZ)]=ZZ[3]}))
FDIFF_supWLBJ=do.call(cbind,lapply(1:ncol(supWLBJ),function(i){ZZ=diff(supWLBJ[,i],na.pad=TRUE);ZZ[is.na(ZZ)]=ZZ[2]}))
SDIFF_supWLBJ=do.call(cbind,lapply(1:ncol(supWLBJ),function(i){ZZ=diff(supWLBJ[,i],na.pad=TRUE,differences=2);ZZ[is.na(ZZ)]=ZZ[3]}))









ROLLXREG=function(data, ){
RollRankADF_12M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADF(data[,i],window=12*21-1)}))
RollRankADF_24M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADF(data[,i],window=24*21-1)}))
RollRankADF_36M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADF(data[,i],window=36*21-1)}))
RollRankADFEXP_12M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADFEXP(data[,i],window=12*21-1)}))
RollRankADFEXP_24M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADFEXP(data[,i],window=24*21-1)}))
RollRankADFEXP_36M=do.call(cbind,lapply(1:ncol(data),function(i){RollingRankADFEXP(data[,i],window=36*21-1)}))
RollFBRUR_12M=do.call(cbind,lapply(1:ncol(data),function(i){RollingFBRUR(data[,i],window=12*21-1)}))
RollFBRUR_24M=do.call(cbind,lapply(1:ncol(data),function(i){RollingFBRUR(data[,i],window=24*21-1)}))
RollFBRUR_36M=do.call(cbind,lapply(1:ncol(data),function(i){RollingFBRUR(data[,i],window=36*21-1)}))

RollGENDDRatio_12M=do.call(cbind,lapply(1:ncol(data),function(i){RollingFBRUR(data[,i],window=36*21-1)}))






###################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

StrEXP=function(x,phi,beta){exp(-(x/phi)^beta)}
DMMUP_HYBRIDTIR=function(data,D0=5,phi=5,beta=0.5,K1=3,K2=5,NN=10,alpha=0.01) {
i=1;TIR=rep(0,length(data));Entrance_CRIT=rep(0,length(data));EXIT_EMWACRIT=rep(0,length(data));EXIT_MAGCRIT=rep(0,length(data))

repeat{ # Repeat the following algorthim until total length is reached  

 Entrance_CRIT[i]=D0*exp(alpha*(max(tail(TIR[1:i],10))))
 if (data[i]>=Entrance_CRIT[i]){ # Initiate a Do-While loop with Time in Regime-Dependent Entrance and Exit Magnitude
          j=1
          repeat {
             TIR[i]=j;j=j+1;i=i+1
                   # The Do-While loop breaks if EMA(data,n)<=K1*(1+StrEXP(max(TIR,0),phi,beta)))
                   # or data<=K2*(1+StrEXP(max(TIR,0),phi,beta))) where K1<K2
             DataX=data[1:i];EWMA_data=as.numeric(na.remove(EMA(DataX,n=ifelse(length(DataX)<NN,length(DataX),NN)))) 
             EXIT_EMWACRIT[i]=K1*(1+StrEXP(max(j,0),phi,beta));EXIT_MAGCRIT[i]=K2*(1-StrEXP(max(j,0),phi,beta))
             if (tail(EWMA_data,1)<EXIT_EMWACRIT[i]||data[i]<EXIT_MAGCRIT[i]){break}
                     }
 }else{TIR[i]=0; i=i+1}
 if (i>length(data)){break}
  }
return(list(TIR=TIR,ENT=Entrance_CRIT,EXIT_EWMA=EXIT_EMWACRIT,EXIT_MAG=EXIT_MAGCRIT))}


DMMUP_HYBRIDTIR(data=supGENDDRatio_13[,1],D0=5,phi=1,beta=0.5,K1=4,K2=5,NN=10)









Duration ..... Duration Adjusted Measures 




SIMTIRDWN_RankADF12M=do.call(cbind,lapply(1:ncol(data),function(i){SimpleDWNTIR(RollRankADF_12M[,i],0.1)}))


DisasterMagnificationMyopia_HYBRIDTIR=function(data,DF=5,phi=5,beta=0.5,K1=3,K2=5,NN=10,alpha=0.01) {

HYBRIDTIR_RankADF12M=do.call(cbind,lapply(1:ncol(data),function(i){
                             DisasterMagnificationMyopia_HYBRIDTIR(RollRankADF_12M[,i],   )                     }))








NonSTAT_MAT=


############################# Hybrid Too-Gaussian for Too Long Measures && Too Efficient for too long##########################


require(quantmod)
require(fitdistrplus)

roll_TDIST=function(data){rollapplyr(data,210,function(x){fitdistr(x,"t")$estimate[3]})}
PORT_TDIST=do.call(cbind,lapply(1:ncol(data),function(i){roll_TDIST(data[,i])}))

TGFTL
TNGFTL
lowVol_TGFTL
highVol_TNGFTL




#####################################################################################




library(kernlab);library(spls);library(gam)

data=FINAL_PORT_RET;STD_CumRet=function(data){SD=sd(data);ZZ=cumsum(data)/SD;ZZ[length(ZZ)]}
PORT_STDCUMRET=function(data){do.call(c,lapply(1:ncol(data),function(i){STD_CumRet(data[,i])}))}
HIST_PORTRET=lapply(1:floor(nrow(data)/210),function(i){PORT_STDCUMRET(data[c((i+210*(i-1)):(210*i)),])})
HIST_CUMRET=lapply(1:97,function(u){HIST_PORTRET[[floor(1+0.1*u)]]})


########### Robust Skewness Measures ###########################
Hinkley_SKEW=function(x,PP){LIST=c(1-PP,0.50,PP);QUANTS=do.call(c,lapply(1:length(LIST),function(i){quantile(x,LIST[i])}))
                            ROB_SKEW=((QUANTS[1]-QUANTS[2])-(QUANTS[2]-QUANTS[3]))/((QUANTS[1]-QUANTS[3])); return(as.numeric(ROB_SKEW))}
Bali2011_SKEWProxy=function(x,N){MAX_SKEW=max(x[1:N])}
MEDCouple=function(x){mc(x)}
################################################################



###### Endogenous Classification Regressors: Path Independent Risk Adjusted Measures, Moments/Generalized Hybrid Tail Measures
######                                       Path Dependent Risk/Risk Adjusted Hybrid Measures,Price Discretness,Acceleration

###### Exogenous Classification Regressors:  

########### DATA: External Potiental Regressors ######################################
SKEW_CBOE=Quandl("CBOE/SKEW",start_date=data_Start_REG,end_date=data_END_REG,sort="asc", type="xts")
VIX_CBOE=Quandl("CBOE/VIX",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")[,4,drop =FALSE]
TED=Quandl("FRED/TEDRATE",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
BAAYield=Quandl("FRED/BAAFF",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
AAAYield=Quandl("FRED/AAAFF",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
BlackSwan_VIX=Quandl("CBOE/VXTH",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
SpreadTBILL_10YR_2YR=Quandl("FRED/T10Y2Y",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
TBILL_4Week=Quandl("FRED/DTB4WK",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
TBILL_13Week=Quandl("YAHOO/INDEX_IRX",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")[,4,drop =FALSE]
FFM=Quandl("KFRENCH/FACTORS_D",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")[,-c(4),drop =FALSE]
MLEEMGCorpSpreads=Quandl("ML/EEMCBI",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
MLHYCorpSpreads=Quandl("ML/HYOAS",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
MLEMGCorpSpreads=Quandl("ML/EMHGY",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
TENYR_TREASFFR=Quandl("FRED/T10YFF",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
STLFSI=Quandl("FRED/STLFSI",src="FRED",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")
SHYINDEX=Quandl("GOOG/AMEX_SHY",start_date=data_Start_REG,end_date=data_END_REG,sort="asc",type="xts")[,4,drop =FALSE]
INDEXX=index(FFM)

#Convert to Daily Returns and Excess Risk
ADJBAAYield=((1+BAAYield/100)^(1/252)-1);ADJAAAYield=((1+AAAYield/100)^(1/252)-1);ADJTBILL_4Week=((1+TBILL_4Week/100)^(1/252)-1)
ADJTBILL_13Week=((1+TBILL_13Week/100)^(1/252)-1);ADJSpreadTBILL_10YR_2YR=(1+SpreadTBILL_10YR_2YR/100)^(1/252)-1
ADJFFM=FFM/100;ExcessBAA_AAA=ADJBAAYield-ADJAAAYield; Excess3MTH_1MTHTBill=ADJTBILL_13Week-ADJTBILL_4Week
 
DATA_MAT=cbind(ADJTBILL_13Week,ADJFFM,SKEW_CBOE,VIX_CBOE,TED,ExcessBAA_AAA,Excess3MTH_1MTHTBill,BlackSwan_VIX,ADJSpreadTBILL_10YR_2YR)
DATA_MAT=zoo(matrix(DATA_MAT,ncol=ncol(DATA_MAT)),INDEXX)
DATA_INT=apply(DATA_MAT,2,function(x)as.xts((PROP_INT(x,MINNA=2))));DATA_INT=zoo(matrix(DATA_INT,ncol=ncol(DATA_INT)),INDEXX)
colnames(DATA_INT)=c("IRR","CAPM","SMB","HML","SKEW_CBOE","VIX_CBOE","TED_SPREAD","ExcessBAA_AAA","Excess3MTH_1MTHTBill", "BlackSwanVIX",
                     "SpreadTBILL_10YR_2YR")


"^VIX","^VXV","XLB", "XLE", "XLF", "XLI", 
           "XLK", "XLP", "XLU", "XLV", "XLY", "RWR", "SHY"



########### END/DATA: External Regressors ########################################





###### Classification Methodology: P(Asset(i)>Asset(j)|cbind(END_XREG,EXO_XREG))=f(...) 


XREG_SORT=function(data,MARKET,RFF,Closing_Prices,Volume_Assets,Hi_Prices,Lo_Prices,MINAR){

i=1
data=FINAL_PORT_RET[c(1:210)+21*(i-1),];MARKET=SP500_RET[c(1:210)+21*(i-1)];RFF=RIRR[c(1:210)+21*(i-1)];
Hi_Prices=Hi_Prices[c(1:210)+21*(i-1),];Lo_Prices=Lo_Prices[c(1:210)+21*(i-1),];MINAR=0.001
Volume_Assets=Volume_Assets[c(1:210)+21*(i-1),]


#### Standard Cumulative and Standardized Cumulative Return Criteria ##########

CUMRET_VEC=as.numeric(lapply(1:ncol(data),function(i){SD=sd(data[,1]);ZZ=cumsum(as.ts(data[,i])); ZZ[length(ZZ)]}))
STDCUMRET_VEC=as.numeric(lapply(1:ncol(data),function(i){ZZ=cumsum(as.ts(data[,i]));SD=sd(ZZ); ZZ[length(ZZ)]/SD}))

######## Path Independent Risk Adjusted Measures ############## 

Sharpe_VEC=as.numeric(lapply(1:ncol(data),function(i){Israelsan_ModSharpe(data[,i],RFF=RFF)}))
Israelsean_VEC=as.numeric(lapply(1:ncol(data),function(i){Israelsan_ModSharpe(data[,i],RFF=RFF)}))
FT_VEC=as.numeric(lapply(1:ncol(data),function(i){FT_ASSET(data[,i],p=1,q=10,MinAR=MINAR)}))
GENDDRR_VEC=as.numeric(lapply(1:ncol(data), function(i){ADJ_GENDDRR(data[,i],q1=0.05,q2=0.05,power1=1,power2=10)}))
PeizarASR_VEC=as.numeric(lapply(1:ncol(data), function(i){Peizar_ASR(data[,i],RFF=RFF)}))
ModifiedASR_VEC=as.numeric(lapply(1:ncol(data), function(i){Modified_ASR(data[,i],RFF=RFF)}))
AutoCORRSharpe_VEC=as.numeric(lapply(1:ncol(data), function(i){AutoCORR_Sharpe(data[,i],RFF=RFF)}))

###############################################################

######## Moments, Partial Moments and Generalized Hybrid Tail Measures #############################  

VOL_VEC=as.numeric(lapply(1:ncol(data), function(i) {-sd(data[,i])}))
Hinkley_SKEW_VEC=as.numeric(lapply(1:ncol(data),function(i){Hinkley_SKEW(as.ts(data[,i]),PP=0.15)}))
Bali_SKEW_VEC=as.numeric(lapply(1:ncol(data),function(i){Bali2011_SKEWProxy(as.ts(data[,i]),N=21)}))
MEDCopule_VEC=as.numeric(lapply(1:ncol(data),function(i){MEDCouple(as.ts(data[,i]))}))
AVGCORR_VEC=colSums(-cor(data, use="complete.obs"))

AsymmBeta_VEC=as.numeric(lapply(1:ncol(data),function(i){AsymmBeta(data[,i],MAR=MARKET,RFF=RFF)}))
UPDownCORR_VEC=as.numeric(lapply(1:ncol(data),function(i){UP_DownCORR(data[,i],MAR=MARKET,RFF=RFF,method="kendall")}))
DownCORR_VEC=as.numeric(lapply(1:ncol(data),function(i){DownCORR(data[,i],MAR=MARKET,RFF=RFF,method="kendall")}))
IdiosyncVol_VEC=as.numeric(lapply(1:ncol(data),function(i){Idiosync_VOL(data[,i],MAR=MARKET,RFF=RFF)}))
IdiosyncSkew_VEC=as.numeric(lapply(1:ncol(data),function(i){Idiosync_SKEW(data[,i],MAR=MARKET,RFF=RFF)}))
IdiosyncKurt_VEC=as.numeric(lapply(1:ncol(data),function(i){Idiosync_KURT(data[,i],MAR=MARKET,RFF=RFF)}))

CDaR_VEC=as.numeric(lapply(1:ncol(data),function(i){CDaR(alpha=0.2,data[,i])}))
UD_TailCoSKEW_VEC=as.numeric(lapply(1:ncol(data),function(i){US_TailCoSKEW(data[,i],Market=MARKET,UpperQ=0.8,LowerQ=0.2)}))
DOWN_TailCoSKEW_VEC=as.numeric(lapply(1:ncol(data),function(i){DOWN_TailCoSKEW(data[,i],Market=MARKET,LowerQ=0.2)}))
BetaCoSKEW_VEC=as.numeric(lapply(1:ncol(data),function(i){Beta_CoSKEW(data[,i],Market=MARKET)}))
BetaCDaR_VEC=as.numeric(lapply(1:ncol(data),function(i){Beta_CDaR(alpha=0.2,XM=MARKET,X=data[,i])}))

CAPMRES_CoSKEW_VEC=as.numeric(lapply(1:ncol(data), function(i){
                   -centeredcomoment(as.xts(residuals(lm(data[,i] ~(MARKET-RFF)))),as.xts(MARKET),p1=1,p2=2, normalize=TRUE)}))
CAPMRES_CoKURT_VEC=as.numeric(lapply(1:ncol(data), function(i){
                   -centeredcomoment(as.xts(residuals(lm(data[,i] ~(MARKET-RFF)))),as.xts(MARKET),p1=1,p2=3, normalize=TRUE)}))

GENHYBTCR_VEC_0101<-as.numeric(lapply(1:ncol(data),function(i){
                    GENHYB_TCR(data[,i],Market=MARKET, HI="quantile(data,0.1)",HM="quantile(Market,0.1)")}))
GENHYBTCR_VEC_01025<-as.numeric(lapply(1:ncol(data),function(i){
                    GENHYB_TCR(data[,i],Market=MARKET, HI="quantile(data,0.1)",HM="quantile(Market,0.25)")}))
GENHYBTCR_VEC_02501<-as.numeric(lapply(1:ncol(data),function(i){
                    GENHYB_TCR(data[,i],Market=MARKET, HI="quantile(data,0.25)",HM="quantile(Market,0.1)")}))
GENHYBTCR_VEC_025025<-as.numeric(lapply(1:ncol(data),function(i){
                    GENHYB_TCR(data[,i],Market=MARKET, HI="quantile(data,0.25)",HM="quantile(Market,0.25)")}))

TailIndex_VEC=as.numeric(lapply(1:ncol(data),function(i){Tail_Index(data[,i])}))
###############################################################################################

############# Path Dependent Risk and Risk Adjusted Hybrid Measures ###########################
AVGDD_VEC=as.numeric(lapply(1:ncol(data), function(i) {-GENDD(data[,i],1)}))
QUADDD_VEC=as.numeric(lapply(1:ncol(data), function(i) {-GENDD(data[,i],2)}))
CUBDD_VEC=as.numeric(lapply(1:ncol(data), function(i) {-GENDD(data[,i],3)}))
MAXDD_VEC=as.numeric(lapply(1:ncol(data), function(i) {-GENDD(data[,i],100)}))

GENDDRatio13_VEC=as.numeric(lapply(1:ncol(data), function(i) {GENDD_Ratio(data[,i],power1=1,power2=3)}))
GENDDRatio31_VEC=as.numeric(lapply(1:ncol(data), function(i) {GENDD_Ratio(data[,i],power1=3,power2=1)}))
GENDDRatio1100_VEC=as.numeric(lapply(1:ncol(data), function(i) {GENDD_Ratio(data[,i],power1=1,power2=100)}))
GENDDRatio1001_VEC=as.numeric(lapply(1:ncol(data), function(i) {GENDD_Ratio(data[,i],power1=100,power2=1)}))
GENDDRatio100100_VEC=as.numeric(lapply(1:ncol(data), function(i) {GENDD_Ratio(data[,i],power1=100,power2=100)}))
############################################################################################

############### Illiquidity and Bid ASK Spread #########################################
Illiquidity_VEC=do.call(cbind,lapply(1:ncol(data),function(i){
                        AMIHUD_Illiquidity(data[,i],Closing_Prices[,i],Volume_Assets[,i],n=21)}));colnames(Illiquidity_VEC)=colnames(data)
RollSpread_VEC=na.omit(do.call(cbind,lapply(1:ncol(data),function(i){Asset_Roll_Spread(data[,i])})))
CorwinSpread_VEC=na.omit(do.call(cbind,lapply(1:ncol(data),function(i){Asset_Corwin_Schultz(cbind(Hi_Prices[,i],Lo_Prices[,i]))})))
########################################################################################

################## Price Discretness ####################
IDDFUN_VEC=as.numeric(lapply(1:ncol(data), function(i) {IDDFUN(data[,i])}))
IDDLDF_VEC=as.numeric(lapply(1:ncol(data), function(i) {IDD_LDF(data[,i])}))
IDDLMDD_VEC=as.numeric(lapply(1:ncol(data), function(i){IDD_LDGENDD(data[,i])}))
IDDMAG1_VEC=as.numeric(lapply(1:ncol(data), function(i){IDDMAG_1(data[,i],decay=10)}))
IDDMAG2_VEC=as.numeric(lapply(1:ncol(data), function(i){IDDMAG_2(data[,i])}))
#########################################################

################### Acceleration ########################

GENMEAN_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){GENMEAN_ACC(data[,i],power=10,LEAD=0.6)}))                         
GENDD_RATIO_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){GENDD_RATIO_ACC(data[,i],p=1,q=3,LEAD=0.6)}))
STDCUMRET_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){STDCUMRET_ACC(data[,i],LEAD=0.6)}))
FT_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){FT_ACC(data[,i],p=1,q=3,LEAD=0.6)}))
GENDDRR_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){GENDDRR_ACC(data[,i],p=1,q=3,LEAD=0.6)}))
GENHYBTCR_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){GENHYBTCR_ACC(data[,i],MAR=MARKET,power1=2,LEAD=0.6)}))
DownCORR_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){DownCORR_ACC(data[,i],MAR=MARKET,RFF=RFF,LEAD=0.6)}))
Vol_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){Vol_ACC(data[,i],LEAD=0.6)}))
SKEW_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){SKEW_ACC(data[,i],LEAD=0.6)}))
KURT_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){KURT_ACC(data[,i],LEAD=0.6)}))
Volume1_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){Volume1_ACC(Volume_Assets[,i],LEAD=0.6)}))
Volume2_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){Volume2_ACC(Volume_Assets[,i],LEAD=0.6)}))
TailIndex_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){Tail_IndexACC(data[,i],LEAD=0.6)}))
CoSKEW_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){CoSKEW_ACC(RET=data[,i],MAR=MARKET,LEAD=0.6)}))
CoKURT_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){CoKURT_ACC(RET=data[,i],MAR=MARKET,LEAD=0.6)}))
RollSpread_ACCVEC=as.numeric(lapply(1:ncol(data),function(i){RollSpread_ACC(data[,i],LEAD=0.6)}))
AMIHUDILL_ACC


AMIHUDILL_ACC=function(AMIHUD,LEAD){NN=length(AMIHUD);ZZ=mean(AMIHUD[c((LEAD*NN):NN)])-mean(AMIHUD[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
RollSpread_ACC=function(AMIHUD,LEAD){NN=length(AMIHUD);ZZ=mean(AMIHUD[c((LEAD*NN):NN)])-mean(AMIHUD[c(1:(LEAD*NN))]);return(as.numeric(ZZ))}
###############


XREG_MAT=matrix(cbind(CUMRET_VEC,STDCUMRET_VEC,Sharpe_VEC,Israelsean_VEC,FT_VEC,GENDDRR_VEC,PeizarASR_VEC,ModifiedASR_VEC,AutoCORRSharpe_VEC,
                      VOL_VEC,Hinkley_SKEW_VEC,Bali_SKEW_VEC,MEDCopule_VEC,AVGCORR_VEC,AsymmBeta_VEC,UPDownCORR_VEC,DownCORR_VEC,IdiosyncVol_VEC,
                      IdiosyncSkew_VEC,IdiosyncKurt_VEC,CDaR_VEC,UD_TailCoSKEW_VEC,DOWN_TailCoSKEW_VEC,BetaCoSKEW_VEC,BetaCDaR_VEC,CAPMRES_CoSKEW_VEC,
                      CAPMRES_CoKURT_VEC, GENHYBTCR_VEC_0101,GENHYBTCR_VEC_01025,GENHYBTCR_VEC_02501,GENHYBTCR_VEC_025025,TailIndex_VEC,CoSKEW_VEC,
                      CoKURT_VEC,GENHYBTCR_VEC,AVGDD_VEC,QUADDD_VEC,CUBDD_VEC,MAXDD_VEC,GENDDRatio13_VEC,GENDDRatio31_VEC,GENDDRatio1100_VEC,
                      GENDDRatio1001_VEC,GENDDRatio100100_VEC,IDDFUN_VEC,IDDLDF_VEC,IDDLMDD_VEC,IDDMAG1_VEC,IDDMAG2_VEC,GENMEAN_ACCVEC,
                      GENDD_RATIO_ACCVEC,STDCUMRET_ACCVEC,FT_ACCVEC,GENDDRR_ACCVEC,GENHYBTCR_ACCVEC,DownCORR_ACCVEC,SKEW_ACCVEC, KURT_ACCVEC, Vol_ACCVEC,
                      TailIndex_ACCVEC),ncol=28)

colnames(XREG_MAT)=c("CUMRET","STDCUMRET","Sharpe","Israelsen","FT","GENDDRR","CoSKEW","CoKURT","GENHYBTCR","AVGDD","QUADDD","CUBDD","MAXDD",
                     "GENDDRatio_13","GENDDRatio_31","GENDDRatio_1100","GENDDRatio_1001","GENDDRatio_100100","VOL","Hinkley_Skew",
                     "BaliSkew","MEDCopule","AVGCORR","IDDFUN","IDDLDF","IDDLMDD","IDDMAG1","IDDMAG2","GENMEAN_ACC","GENDD_RATIO_ACC",
                     "STDCUMRET_ACC","FT_ACC","GENDDRR_ACC","GENHYBTCR_ACC","DownCORR_ACC","SKEW_ACC","KURT_ACC","Vol_ACC","Volume_ACC","TailIndex_ACC" )
RANK_MAT=apply(XREG_MAT,2,function(u){order(u)}); return(RANK_MAT)}









##################################

#### Fit Hidden Markov Model with covariates. Assumes that the probability of staying in a regime is constant
#### Equivalently to assuming that the time spent in a regime has no effect on the probability of staying in the regime.

#####A Hidden Semi-Markov model (HSMM) is a statistical model with the same structure as a hidden Markov model
#except that the unobservable process is semi-Markov rather than Markov. This means that the probability of 
#there being a change in the hidden state depends on the amount of time that has elapsed since entry into the 
#current state. This is in contrast to hidden Markov models where there is a constant probability of changing state
#given survival in the state up to that time.

#######The HMM presented in the previous section provides ﬂexible,general-purpose models for univariate and multivariate time series. 
#However, a major limitation is the implicit geometric distribution of the sojourn times as a consequence of the Markov property, 
#i.e., P (sojourn in state j of length u)=pjj^(u−1)(1−pjj). The HSMM is a generalization of the HMM that allows to use more general 
#sojourn time (or state occupancy) distributions.

# Find Upper and Lower Quantile for Historical Standardized Cumulative Return data
    Lower_HQuant=as.numeric(quantile(HIST_CUMRET,LowerQuantile))
    Upper_HQuant=as.numeric(quantile(HIST_CUMRET,UpperQuantile))

    IND_HYBRID=function(i){ifelse(QLONG[i]>=Upper_Quantile && STDRET[,i]>=Upper_HQuant,1,
                           ifelse(QSHORT[i]<=Lower_Quantile && STDRET[,i]<=Lower_HQuant,-1,0))}

## Double Sorting can evaluate and guide ranking criteria selection for two variables. In order to extend this to a multivariate framework 
## and to engage in a more statistically valid variable selection, I utilized sparse classification. 
   

##### Run the Hybrid Ensemble Filteration with a maximum lookback window to allow for smoothly varying classification weights ######

if(CLASS_ALGO=="HybridEnsemble"){

STD_CUMRET_RANK=function(data){order(unlist(lapply(1:ncol(data),function(i){SD=sd(data);ZZ=cumsum(as.ts(data[,i])); ZZ[length(ZZ)]/SD})))}
CumSUM_OPT=lapply(1:97,function(i){STD_CUMRET_RANK(FINAL_PORT_RET[c((1+21*(i-1)):(21*i))+231,])})
XREG_HOLD=lapply(1:97,function(i){XREG_SORT(FINAL_PORT_RET[c(1:210)+21*(i-1),],SP500_RET[c(1:210)+21*(i-1)],RFF[c(1:210)+21*(i-1)],MINAR=0)})


#### The following are WinnerLoser, Winner and Loser Portfolio Classification applied to Holding Data ##########
WL_CumSUM_OPT=lapply(1:97,function(i){UpperQuantile=quantile(CumSUM_OPT[[i]],0.8);LowerQuantile=quantile(CumSUM_OPT[[i]],0.1)                          
                                      ifelse(CumSUM_OPT[[i]]>UpperQuantile,1,ifelse(CumSUM_OPT[[i]]<LowerQuantile,-1,0))})
Winner_CumSUM_OPT=lapply(1:97,function(i){UpperQuantile=quantile(CumSUM_OPT[[i]],0.8);ifelse(CumSUM_OPT[[i]]>=UpperQuantile,1,0)})
Loser_CumSUM_OPT=lapply(1:97,function(i){LowerQuantile=quantile(CumSUM_OPT[[i]],0.2);ifelse(CumSUM_OPT[[i]]<=LowerQuantile,1,0)})

i=50;FULL=1:i; HH=tail(FULL,10)
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
WL_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){WL_CumSUM_OPT[[m]]}))
Winner_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Winner_CumSUM_OPT[[m]]}))
Loser_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Loser_CumSUM_OPT[[m]]}))


### cor(do.call(cbind,WL_CumSUM_OPT),method="kendall")


HybridEnsemble_Filter=hybridEnsemble(data.frame(XREG_MM),as.factor(Loser_CumSUM_OPT_MM))
predictions <- predict(HybridEnsemble_Filter,newdata=data.frame(XREG_HOLD[[(max(HH)+1)]]))
WML_Inclusion_Probability=ifelse(predictions$predAUTHORITY>0.6,1,0)





} else if (





N. Meinshausen and P. Buehlmann (2010), Stability selection. Journal of the Royal Statistical Society, Series B, 72(4). 

stabsel {mboost}	R Documentation
Stability Selection
Description

Selection of influential variables or model components with error control.
Usage

stabsel(object, FWER = 0.05, cutoff, q, 
        folds = cv(model.weights(object), type = "subsampling"),
        papply = if (require("multicore")) mclapply else lapply, ...)

Feature selection using vanilla logistic regression and penalized linear regression
Multiple models with variation in features as well as variation in the target
Since only ranking of the outcomes mattered, we transformed the target to build binary and poisson models using gbm in R
In addition, we built randomized trees in R, elastic nets in R, and extra trees in python
We also tried building a multinomial model but could not find much success
All our models were cross-validated and repeated with different seeds to ensure stability
Individual predictions were combined using generalized additive models
Lastly, we got a gain of about 0.005 on CV as well as LB if we just multiplied the predictions for dummy == "B" with a factor of 1.2 (we don't have any convincing explanation behind this)





OPTIMALLAM=suppressWarnings(cv.rq.pen(scale(xnew),ynew,tau=tauX,nlambda=nlamdaX,nfolds=nfoldsX,penalty="SCAD")$lamda.min)






rq.fit.scad(x, y, tau = 0.5, alpha = 3.2, lambda = 1, start="rq", 
        beta = .9995, eps = 1e-06)









### Choosing the best prior/regularization penalty to use: Non-Spurious Multicollinearity and Non-Normality

  # Under extreme non-spurious mulitcollinearity, priors/regularization penalties with grouping effect perform better than those without.
    # Examples of nil-weak grouping effect regularizations: LASSO,SCAD, MLP, Horseshoe etc

  # Under extreme superGaussianity, priors/regularization penalties with robustness outperform those withoute
    # Examples of robust penalties regularization:adaptive online repeated median filter, LAD error, quantile, Horeshoe, Spike and Slab. 
 

##################################### TESTS!!!!!!!##############################################################

## Causes of Spurious Multicollinearity:
   # Nonstationary Data: Nonstationarity between variables will cause spurious multicollinearity. 
     # Run rank ADF and KPSS tests,together. Rank based tests are robust to nonlinearity i.e. there can be a process that is 
     # nonstationary but subject to a nonlinear transformation. Difference until stationary. 
       # If reject null of KPSS and fail to reject null of ADF, nonstationary in mean.
       # If fail to reject null of KPSS and reject null of ADF, stationary in mean.
       # If reject null of KPSS and reject the null of ADF, fractionally integrated in mean (long memory in mean).
       # If fail to reject null of KPSS and ADF, there is insufficient data to draw conclusion. 
 
   # Non-Scaled or Centered data: Sometimes non-centered and/or non-scaled data can cause spurious multicollinearity   
     # Run AutoMultiColling
       # If non-spurious multicollinearity is low, use non-grouping effect priors/regularization. Center and/or scale the 
       # X data with R function: XX=scale(X, center = TRUE, scale =TRUE) where XX is the new matrix. 
 
       # If non-spurious multicollinearity is high, use grouping effect priors/regularization. Center and/or scale the 
       # X data with R function: XX=scale(X, center = TRUE, scale =TRUE) to reduce extreme multicollinearity.       


Rank_MeanStationarityTest=function(data,criticalPADF=0.05,criticalPKPSS=0.05){

KPSS_ADF=function(x,criticalpADF,criticalpKPSS){
    KPSS=suppressWarnings(kpss.test(rank(x))$p.value)
    ADF=suppressWarnings(adf.test(rank(x))$p.value)
    # Run Nested IfElse loop to run over all the conditions
    ifelse(KPSS<criticalPKPSS && ADF>criticalPADF,2,ifelse(KPSS<criticalPKPSS &&ADF<criticalPADF,1,
    ifelse(KPSS>criticalPKPSS && ADF<criticalPADF,0,-1)))}

AA=matrix(apply(data,2, function(x)KPSS_ADF(x,criticalpADF=criticalPADF,criticalpKPSS=criticalPKPSS)),ncol=1)
rownames(AA)=colnames(data)
colnames(AA)=c("Stationarity Test")
return(AA)
}


Rank_MeanStationarityTest(data=PORT)

# If the value of the RankKPSS_ADF test is 2, the data is nonstationary. It must be first differenced. 
# if the value of the RankKPSS_ADF test is 1, the data is stationary with long memory i.e. fractionally integrated
# If the value of the RankKPSS_ADF test is 0, the data is stationary with short memory
# If the value of the RankKPSS_ADF test is-1, the data is inconclusive. 



Given a design matrix, the condition indices (ratio of largest singular value to each singular value),variance decomposition proportions, 
and variance inflation factors are returned. Belsley, Kuh, & Welsch [1] suggest a strategy for diagnosing degrading collinearity using the following conditions: 

    1) A singular value judged with a large condition index, and which is associated with 
    2) Large variance decomposition proportions for two or more covariates

# Very important part

######The number of large condition indexes identifies the number of near dependencies among the columns of the design matrix. 
Large variance decomposition proportions identify covariates that are involved in the corresponding near dependency, and the magnitude 
of these proportions, in conjunction with the condition index, provides a measure of the degree to which the corresponding regression 
estimate has been degraded by the presence of collinearity. What is meant by "large" is not statistically precise, although numerical 
experiments by Belsley et al. indicate that the following ranges are useful:
#######

# Co-conditions for determining the right 
Condition index, Collinearity 
5 < CI < 10, weak 
30 < CI < 100, moderate to strong 
CI > 100, severe

and where a pair (or more) of variance decomposition factors > 0.5 warrant inspection.


Automated_MULTICollDiag=function(x,y,k1=10,k2=30,varmax=0.5,scaleX= TRUE, centerX =TRUE){
ZZ=colldiag(lm(y~., data=x),scale=scaleX,center=centerX)
MAX=max(ZZ$condindx)
VARPOR1=suppressWarnings(max(na.remove(ZZ$pi[ZZ$condindx>k1,])))
VARPOR2=suppressWarnings(max(na.remove(ZZ$pi[ZZ$condindx>k2,])))
ifelse(MAX>k2&&VARPOR2>varmax,2,ifelse(MAX>k1&&VARPOR1>varmax,1,0))}                                             


#Automated_MULTICollDiag(x=PORT[,-c(1)],y=PORT[,c(1)],k1=10,k2=30,varmax=0.5,scaleX=FALSE,centerX=FALSE)
[1] 2
#Automated_MULTICollDiag(x=PORT[,-c(1)],y=PORT[,c(1)],k1=10,k2=30,varmax=0.5,scaleX=TRUE,centerX=TRUE)
[1] 1


If MAX is greater than K2 and the Variance Proportion matrix is greater than varmax for Condition Index greater than K2, the value return is 2 i.e. extreme multicollinearity.
If it fails to meet extreme multicollinearity but MAX is greater than K1 and the Variance Proportion matrix is greater than varmax for Condition Index greater than K1, the value returned is 1 i.e. moderate to strong multicollinearity
If it fails to meet moderate-strong multicollinearity, the value returned is 0 i.e. no-weak multicollinearity.    


# Non-Normality Tests 
Razali, Nornadiah Mohd, and Yap Bee Wah. "Power comparisons of shapiro-wilk, kolmogorov-smirnov, lilliefors and anderson-darling tests." Journal of Statistical Modeling and Analytics 2.1 (2011): 21-33.
Gel,Y.R.,Miao,W.,andGastwirth,J.L.(2007) Robust Directed Tests of Normality AgainstHeavy Tailed Alternatives. Computational Statistics and Data Analysis 51, 2734-2746.
Brys, Guy, Mia Hubert, and Anja Struyf. "Robust measures of tail weight." Computational statistics & data analysis 50.3 (2006): 733-759.


SW_robustSW_SSTD_Tests=function(data,criticalPSW=0.05,criticalPRSW=0.05,criticalSKEW=1,NN=1000,lowerX=c(1e-10,2,0), upperX=c(0.5,20,10), maxiter=1000){

SW_robSW=function(x,criticalpSW=criticalPSW,criticalpRSW=criticalPRSW,criticalSKEW=criticalSKEW,N=NN,lower=lowerX,upper=upperX){

    SW=suppressWarnings(shapiro.test(x)$p.value)
    robSW=suppressWarnings(sj.test(x, crit.values ="empirical", N)$p.value)

    # Fit a Skewed Student T Distribution with GenSA by minimizing the negative log-liklehood 
    MEAN=mean(x)
    SSTD=suppressWarnings(GenSA(fn=function(theta)-sum(log(dsstd(x,mean=theta[1],sd=theta[2],nu=theta[3],xi=theta[4]))),
         lower=c(-1.5*abs(MEAN),lowerX),upper=c(1.5*abs(MEAN),upperX),control=list(maxit=maxiter))$par)
    
    # Run Nested If_Else loops to run over all the conditions
     # Run Nested If_Else loops to run over all the conditions
    ZZ=ifelse(SW<criticalpSW && robSW<criticalpRSW && SSTD[4]<criticalSKEW,"TRUE Symmetric SuperGaussian",
       ifelse(SW<criticalpSW && robSW<criticalpRSW && SSTD[4]>criticalSKEW,"TRUE Asymmetric superGaussian",
       ifelse(SW<criticalpSW && robSW>criticalpRSW && SSTD[4]>criticalSKEW,"Outlier polluted Gaussian",
       ifelse(SW<criticalpSW && robSW>criticalpRSW && SSTD[4]<criticalSKEW,"Outlier polluted Gaussian/Skewed superGaussian",
       ifelse(SW>criticalpSW && robSW>criticalpRSW && SSTD[4]>criticalSKEW,"Gaussian",
       ifelse(SW>criticalpSW && robSW>criticalpRSW && SSTD[4]<criticalSKEW,"Weak Asymmetrical/quasi-Gaussian",
       ifelse(SW>criticalpSW && robSW<criticalpRSW && SSTD[4]<criticalSKEW,"Small Sample Symmetric SuperGaussian/Insufficient Data",
       "Small Sample Aymmetric SuperGaussian/Insufficient Data")))))))}

AA=matrix(apply(data,2, function(x)SW_robSW(x,criticalpSW=criticalPSW,criticalpRSW=criticalPRSW,criticalSKEW=criticalSKEW,N=NN,lower=lowerX,upper=upperX)),ncol=1)
rownames(AA)=colnames(data)
colnames(AA)=c("Result:SW_RSW_SSTD Test")
return(AA)}

SW_robustSW_SSTD_Tests(data=PORT[1:500,],maxiter=50) 


SW_robustSW_Symm_Tests=function(data,criticalPSW=0.05,criticalPRSW=0.05,criticalSYMM=0.01,NN=1000){

SW_robSW=function(x,criticalpSW=criticalPSW,criticalpRSW=criticalPRSW,criticalSKEW=criticalSYMM,N=NN,lower=lowerX,upper=upperX){

    SW=suppressWarnings(shapiro.test(x)$p.value)
    robSW=suppressWarnings(sj.test(x, crit.values ="empirical", N)$p.value)

    # RUN symmtest
    SYMM=symmetry.test(x)$p.value
    
    # Run Nested If_Else loops to run over all the conditions
    ZZ=ifelse(SW<criticalpSW && robSW<criticalpRSW && SYMM<criticalSKEW,"TRUE Symmetric SuperGaussian",
       ifelse(SW<criticalpSW && robSW<criticalpRSW && SYMM>criticalSKEW,"TRUE Asymmetric superGaussian",
       ifelse(SW<criticalpSW && robSW>criticalpRSW && SYMM>criticalSKEW,"Outlier polluted Gaussian",
       ifelse(SW<criticalpSW && robSW>criticalpRSW && SYMM<criticalSKEW,"Outlier polluted Gaussian/Skewed superGaussian",
       ifelse(SW>criticalpSW && robSW>criticalpRSW && SYMM>criticalSKEW,"Gaussian",
       ifelse(SW>criticalpSW && robSW>criticalpRSW && SYMM<criticalSKEW,"Weak Asymmetrical/quasi-Gaussian",
       ifelse(SW>criticalpSW && robSW<criticalpRSW && SYMM<criticalSKEW,"Small Sample Symmetric SuperGaussian/Insufficient Data",
       "Small Sample Aymmetric SuperGaussian/Insufficient Data")))))))}
 
AA=matrix(apply(data,2, function(x)SW_robSW(x,criticalpSW=criticalPSW,criticalpRSW=criticalPRSW,criticalSKEW=criticalSYMM,N=NN,lower=lowerX,upper=upperX)),ncol=1)
rownames(AA)=colnames(data)
colnames(AA)=c("Result:SW_RSW_SYMM Test")
return(AA)}

SW_robustSW_Symm_Tests(data=PORT[1:1000,]) 

####In practice, we therefore recommend to perform both a robust and a non-robust test. If they lead to contradictory conclusions, 
this can be due to the sensitivity of the non-robust test towards outliers, or due to the conservative behavior of the robust test. 
In that case, a further investigation of the data is required.####
## Note that the directed SJ test is more powerful in detecting heavy-tailed symmetric alternatives than all other tests, especially for small and moderate sizes
## Note that the directed SJ test lacks power in detecting short tailed or skewed distributions. 


########################################################################################################################################################

library(monomvn)

## Using blasso with horeshoe prior. 
# Good Source Slide: Reading Group Presenter:Zhen Hu Cognitive Radio Institute Friday, October 08, 2010; 
# Authors: Carlos M. Carvalho, Nicholas G. Polson and James G. Scott
     # HorseShoe Prior is highly adaptive both to unknown sparsity and to unknown signal-to-noise ratio.
     # HorseShoe Prior is robust to large, outlying signals. 

# Properities of HorseShoe Prior  
     # It is symmetric about zero.
     # It has heavy, Cauchy like tails that decay like       .
     # It has an infinitely tall spike at 0, in the sense that the density approaches infinity logarithmically fast as from either side. 
        # Thus like the LASSO, the HorseShoe is a good default shrinkage prior for sparse signals.
        # Unlike the LASSO,the HoreseShoe prior’s flat tails are robust to heavy tailed data i.e. leptokurtic data 

WW=blasso(X=cbind(DIBM[1:500],DKO[1:500]), y=DSP500[1:500],case="hs",T=5000)
coefWW=as.numeric((gsub("[[:alpha:]:]", "",summary(WW)$coef[3,])))
coefWW
[1] 0.0003936 0.0000000 0.0000000





## Using blasso with horeshoe prior. 
# Good Source Slide: Reading Group Presenter:Zhen Hu Cognitive Radio Institute Friday, October 08, 2010; 
# Authors: Carlos M. Carvalho, Nicholas G. Polson and James G. Scott
     # HorseShoe Prior is highly adaptive both to unknown sparsity and to unknown signal-to-noise ratio.
     # HorseShoe Prior is robust to large, outlying signals. 

# Properities of HorseShoe Prior  
     # It is symmetric about zero.
     # It has heavy, Cauchy like tails that decay like       .
     # It has an infinitely tall spike at 0, in the sense that the density approaches infinity logarithmically fast as from either side. 
        # Thus like the LASSO, the HorseShoe is a good default shrinkage prior for sparse signals.
        # Unlike the LASSO,the HoreseShoe prior’s flat tails are robust to heavy tailed data i.e. leptokurtic data 

WW=blasso(X=cbind(DIBM[1:500],DKO[1:500]), y=DSP500[1:500],case="hs",T=5000)
coefWW=as.numeric((gsub("[[:alpha:]:]", "",summary(WW)$coef[3,])))
coefWW
[1] 0.0003936 0.0000000 0.0000000









} else if (CLASS_ALGO=="NonlinearSVM"){

### Optimal Holding Period Rankings: Y Variable in Classification
### CUmulative Return,Standarized Cumulative Return, 
CUMRET_RANK=function(data){order(unlist(lapply(1:ncol(data),function(i){SD=sd(data);ZZ=cumsum(as.ts(data[,i])); ZZ[length(ZZ)]})))}
STD_CUMRET_RANK=function(data){order(unlist(lapply(1:ncol(data),function(i){SD=sd(data);ZZ=cumsum(as.ts(data[,i])); ZZ[length(ZZ)]/SD})))}

CumSUM_OPT=lapply(1:97,function(i){CUMRET_RANK(FINAL_PORT_RET[c((1+21*(i-1)):(21*i))+231,])})
STD_CumSUM_OPT=lapply(1:97,function(i){STD_CUMRET_RANK(FINAL_PORT_RET[c((1+21*(i-1)):(21*i))+231,])})


WL_CumSUM_OPT=lapply(1:97,function(i){UpperQuantile=quantile(CumSUM_OPT[[i]],0.8);LowerQuantile=quantile(CumSUM_OPT[[i]],0.2)                          
                                      ifelse(CumSUM_OPT[[i]]>UpperQuantile,1,ifelse(CumSUM_OPT[[i]]<LowerQuantile,1,0))})
XREG_HOLD=lapply(1:97,function(i){XREG_SORT(FINAL_PORT_RET[c(1:210)+21*(i-1),],SP500_RET[c(1:210)+21*(i-1)],RFF[c(1:210)+21*(i-1)])})

svp <- ksvm(XREG_HOLD[[1]],WL_CumSUM_OPT[[1]],type="C-svc",kernel="rbf",kpar=list(sigma=1),C=1,prob.model=TRUE)
predict(svp,XREG_HOLD[[1]], type="probabilities")


i=10
FULL=1:i; HH=tail(FULL,3)
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
WL_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){WL_CumSUM_OPT[[m]]}))

svp <- ksvm(scale(XREG_MM),WL_CumSUM_OPT_MM,type="C-svc",kernel="rbf",kpar = "automatic",C=2000,prob.model=TRUE)
SVP_PRED=predict(svp,scale(XREG_HOLD[[(max(HH)+1)]]), type="probabilities")

WML_Inclusion_Probability=ifelse(predictions$predAUTHORITY>0.6,1,0)


} else if (CLASS_ALGO=="Sparse PLS"){



STD_CUMRET_RANK=function(data){order(unlist(lapply(1:ncol(data),function(i){SD=sd(data);ZZ=cumsum(as.ts(data[,i])); ZZ[length(ZZ)]})))}
CumSUM_OPT=lapply(1:97,function(i){STD_CUMRET_RANK(FINAL_PORT_RET[c((1+21*(i-1)):(21*i))+231,])})
WL_CumSUM_OPT=lapply(1:97,function(i){UpperQuantile=quantile(CumSUM_OPT[[i]],0.8);LowerQuantile=quantile(CumSUM_OPT[[i]],0.2)                          
                                      ifelse(CumSUM_OPT[[i]]>UpperQuantile,1,ifelse(CumSUM_OPT[[i]]<LowerQuantile,1,0))})
XREG_HOLD=lapply(1:97,function(i){XREG_SORT(FINAL_PORT_RET[c(1:210)+21*(i-1),],SP500_RET[c(1:210)+21*(i-1)],RFF[c(1:210)+21*(i-1)],MINAR=0.001)})
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
WL_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){WL_CumSUM_OPT[[m]]}))


ZZ=matrix(0,17,97)
for(i in 1:97){ZZ[,i]=coef(splsda(x=XREG_HOLD[[i]],y=WL_CumSUM_OPT[[i]],K=2,eta=0.8,kappa=0.5,classifier=c('logistic')))}
ADJ_ZZ=apply(ZZ,2,function(u)ifelse(u>0,1,ifelse(u<0,-1,0)))
pheatmap(t(ADJ_ZZ),cluster_rows =FALSE, cluster_cols=FALSE)


ZZ=splsda(x=XREG_MM,y=as.numeric(unlist(WL_CumSUM_OPT_MM)),K=3,eta=0.8,kappa=0.5,classifier=c('logistic'))
COEF=coef(ZZ);PRED=predict(ZZ,type="probabilities")


source("http://bioconductor.org/biocLite.R")
biocLite("Rgraphviz")

# complicated formula example, poisson response: 

m2 <- spikeSlabGAM(as.numeric(unlist(WL_CumSUM_OPT_MM))~ x1 * (x2 + f1) + (x2 + x3 + f2)^2 sm(x2):sm(x3), data = d, family = "poisson", 
                   mcmc = mcmc, hyperparameters = hyper) 




summary(m2) 
plot(m2)


} else if (CLASS_ALGO=="FuzzyRuleClassification"){


i=97;FULL=1:i; HH=tail(FULL,97)
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
WL_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){WL_CumSUM_OPT[[m]]}))
Winner_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Winner_CumSUM_OPT[[m]]}))

#################### Shuffle the data then split the data to train and test on ####################

Shuffled <- iris[sample(nrow(iris)), ];YShuffled<- unclass(irisShuffled[, 5])

tra.iris <- irisShuffled[1 : 105, ]
tst.iris <- irisShuffled[106 : nrow(irisShuffled), 1 : 4]
real.iris <- matrix(irisShuffled[106 : nrow(irisShuffled), 5], ncol = 1)
 
## Define range of input data. Note that it is only for the input variables.
range.data.input <- apply(iris[, -ncol(iris)], 2, range)
 
## Set the method and its parameters. In this case we use FRBCS.W algorithm
method.type <- "FRBCS.W"
control <- list(num.labels = , type.mf = "GAUSSIAN", type.tnorm = "MIN",
               type.snorm = "MAX", type.implication.func = "ZADEH")
 
## Learning step: Generate fuzzy model
object.cls <- frbs.learn(tra.iris, range.data.input, method.type, control)
 
## Predicting step: Predict newdata
res.test <- predict(object.cls, tst.iris)
 




} else if (CLASS_ALGO=="gamboostLSS"){

##SPLS regression exhibits good performance even when (1) the sample size is much smaller than the total number of variables; 
##and (2) the covariates are highly correlated. One additional advantage of SPLS regression is its ability to handle both univariate 
##and multivariate responses. 


i=97;FULL=1:i; HH=tail(FULL,97)
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
WL_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){WL_CumSUM_OPT[[m]]}))
Winner_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Winner_CumSUM_OPT[[m]]}))

RSP=glmnet(x=scale(XREG_HOLD[[1]],scale=FALSE),y=as.numeric(Winner_CumSUM_OPT[[1]]),family="multinomial",alpha=0)
cv.RR1<-cv.glmnet(x=scale(XREG_HOLD[[1]],scale=FALSE),y=as.numeric(Winner_CumSUM_OPT[[1]]),family="multinomial",alpha=0)
CVVSP500<-cv.RR1$lambda.1se;as.double(coef(RSP,s=CVVSP500))

m=10
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
Winner_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Winner_CumSUM_OPT[[m]]}))

RSP=glmnet(x=data.matrix(scale(XREG_MM,scale=FALSE)),y=as.numeric(unlist(Winner_CumSUM_OPT_MM)),family="multinomial",alpha=0)
cv.RR1<-cv.glmnet(x=data.matrix(data.frame(scale(XREG_MM,scale=FALSE))),y=as.vector((Winner_CumSUM_OPT_MM)),family="multinomial",alpha=0)
CVVSP500<-cv.RR1$lambda.1se;coef(RSP,s=CVVSP500)


m=10
XREG_MM=do.call(rbind,lapply(HH,function(m){XREG_HOLD[[m]]}))
Winner_CumSUM_OPT_MM=do.call(c,lapply(HH,function(m){Winner_CumSUM_OPT[[m]]}))

lassoSP= glmnet(x=data.matrix(unlist(XREG_MM)),y=as.numeric(unlist(Winner_CumSUM_OPT_MM)),family="multinomial",alpha=1)
cv.lasso1<-cv.glmnet(x=data.matrix(data.frame(data.matrix(unlist(XREG_MM)))),y=as.numeric(unlist(Winner_CumSUM_OPT_MM)),family="multinomial",alpha=1,nfolds=5)
CVVSP500<-cv.lasso1$lambda.1se;coef(lassoSP,s=CVVSP500))

ElasticSP= glmnet(x=data.matrix(XREG_HOLD[[1]]),y=as.numeric(unlist(WL_CumSUM_OPT[[1]])),alpha=0.5)
cv.Elastic1<-cv.glmnet(x=data.matrix(data.frame(XREG_HOLD[[1]])),y=as.numeric(unlist(WL_CumSUM_OPT[[1]])),alpha=0.5,nfolds=5)
CVVSP500<-cv.Elastic1$lambda.1se;as.double(coef(ElasticSP,s=CVVSP500))

SCADSP<- ncvreg(X=data.matrix(XREG_HOLD[[1]]),y=as.numeric(unlist(WL_CumSUM_OPT[[1]])),penalty="SCAD")
cv.SCAD <- cv.ncvreg(X=data.matrix(XREG_HOLD[[1]]),y=as.numeric(unlist(WL_CumSUM_OPT[[1]])),nfolds=5)
CVVSP500<-cv.SCAD$lambda.min;SCAD_Beta=ncvreg(X=data.matrix(XREG_HOLD[[1]]),y=as.numeric(unlist(WL_CumSUM_OPT[[1]])),lambda=CVVSP500)$beta
ifelse(abs(SCAD_Beta)>=0.2,SCAD_Beta,0)




####################
C is the parameter for the soft margin cost function, which controls the influence of each individual support vector; this process involves 
trading error penalty for stability.

Higher sigma means that the kernel is a "flatter" Gaussian and so the decision boundary is "smoother"; lower sigma makes it a "sharper" peak, 
and so the decision boundary is more flexible and able to reproduce strange shapes if they're the right answer. If sigma is very high, your data 
points will have a very wide influence; if very low, they will have a very small influence.
Thus, often, increasing the sigma values will result in more support vectors: for more-or-less the same decision boundary, more points will fall 
within the margin, because points become "fuzzier." Increased sigma also means, though, that the slack variables "moving" points past the margin are more
expensive, and so the classifier might end up with a much smaller margin and fewer SVs. Of course, it also might just give you a dramatically different
decision boundary with a completely different number of SVs.

Due to the ξ i in Eq.(24), data points are allowed to be misclassiﬁed, and the amount of misclassiﬁcation will be minimized while maximizing the margin
according to the objective function (23). C is a parameter that determines the tradeoff between the margin size and the amount of error in training. 
#####################










#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
HMM_BADREG=function(data){
HMM_RAW<- depmix(as.zoo(data)~1,nstates=2,data=data);fms_HMM_RAW <- fit(HMM_RAW)
HMM_ABS<- depmix(abs(as.zoo(data))~1,nstates=2,data=data);fms_HMM_ABS<- fit(HMM_ABS)
PARS_RAW=getpars(fms_HMM_RAW); PARS_ABS=getpars(fms_HMM_ABS)
BRRAW=which.max(PARS_RAW[names(PARS_RAW)=="sd"]);BRABS=which.max(PARS_ABS[names(PARS_ABS)=="sd"])
BADRegime_RRAW=posterior(fms_HMM_RAW)[,(BRRAW+1)];BADRegime_RABS=posterior(fms_HMM_ABS)[,(BRABS+1)]
return(cbind(BADRegime_RRAW,BADRegime_RABS))}

HMM_BADREGIME=lapply(1:ncol(FINAL_PORT_RET), function(i)HMM_BADREG(data=FINAL_PORT_RET[,i])) 
CC_HMM=lapply(1:ncol(FINAL_PORT_RET), function(i) 
RAW=HMM_BADREG[[i]][,1];HMM_BADREG[[i]][,2]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                              
      