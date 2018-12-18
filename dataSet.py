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