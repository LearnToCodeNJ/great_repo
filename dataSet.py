import quandl

SKEW_CBOE=Quandl("CBOE/SKEW",start_date=data_Start_REG,end_date=data_END_REG,order="asc", type="xts")
VIX_CBOE=Quandl("CBOE/VIX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4,drop =FALSE]
TED=Quandl("FRED/TEDRATE",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
BAAYield=Quandl("FRED/BAAFF",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
AAAYield=Quandl("FRED/AAAFF",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
BlackSwan_VIX=Quandl("CBOE/VXTH",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
SpreadTBILL_10YR_2YR=Quandl("FRED/T10Y2Y",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
TBILL_4Week=Quandl("FRED/DTB4WK",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
TBILL_13Week=Quandl("YAHOO/INDEX_IRX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4,drop =FALSE]
FFM=Quandl("KFRENCH/FACTORS_D",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,-c(4),drop =FALSE]
MLEEMCCorpSpreads=Quandl("ML/EEMCBI",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
MLHYCorpSpreads=Quandl("ML/HYOAS",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
MLEMGCorpSpreads=Quandl("ML/EMHGY",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
TENYR_TREASFFR=Quandl("FRED/T10YFF",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
STLFSI=Quandl("FRED/STLFSI",src="FRED",start_date=data_Start_REG,end_date=data_END_REG,order="asc")
VXZ=Quandl("GOOG/NYSE_VXZ",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4]
VXX=Quandl("GOOG/NYSE_VXX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4]
VVIX=Quandl("CBOE/VVIX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")
LSGLX=Quandl("YAHOO/FUND_LSGLX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4]
PRITX=Quandl("YAHOO/FUND_PRTIX",start_date=data_Start_REG,end_date=data_END_REG,order="asc",type="xts")[,4]
INDEXX=index(FFM)


getSymbols(c("^GSPC","^VIX","^VXV","XLB", "XLE", "XLF", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY", "RWR", "SHY"),from = as.Date("2007-11-04"), to = as.Date("2018-04-04"))

https://rdrr.io/rforge/qmao/man/getSymbols.cfe.html
https://stackoverflow.com/questions/13282094/download-vix-futures-prices-from-cboe,
https://bommaritollc.com/2012/11/05/retrieving-the-vix-term-structure-in-r/

https://rpubs.com/JanpuHou/378663
https://r-forge.r-project.org/scm/viewvc.php/pkg/qmao/R/getSymbols.cfe.R?r1=352&r2=351&sortby=author&root=twsinstrument&pathrev=352&diff_format=c
https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/qmao/R/getSymbols.cfe.R?revision=430&root=twsinstrument
https://quantstrattrader.wordpress.com/2017/05/18/constant-expiry-vix-futures-using-public-data/

http://systematicinvestor.github.io/Volatility-Strategy
https://github.com/gsee/qmao/blob/master/R/getSymbols.cfe.R
http://www.ntu.edu.sg/home/nprivault/MA5182/volatility-estimation.pdf

##SKEW...VXTH...VIX###
### "GOOG/AMEX_SHY","KFRENCH/FACTORS_D", "YAHOO/INDEX_IRX", "CBOE/SKEW", "CBOE/VIX", "CBOE/VXTH" #####

https://www.quandl.com/data/URC-Unicorn-Research-Corporation
http://www.cboe.com/products/vix-index-volatility/vix-related-strategy-benchmarks/cboe-low-volatility-index-lovol