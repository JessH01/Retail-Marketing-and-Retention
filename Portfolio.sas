FILENAME REFFILE '/folders/myfolders/MIS543/clothing_store_mod8.csv';
FILENAME REFFILE2 '/folders/myfolders/MIS543/Copy of uszips.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=RAWSALES;
	GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=REFFILE2
	DBMS=XLSX
	OUT=ZIPCODE_F;
	GETNAMES=YES;
RUN;

PROC MEANS Data=RAWSALES;
RUN;

Data NEWSALES;
set RAWSALES;
if PROMOS>11 then promo_responder="FREQ";
else promo_responder="NOT";
run;

Data NEWSALES;
set newsales;
if FRE>10 then freq_class="FREQ";
else freq_class="NOT";
run;

Data NEWSALES;
length cluster_det $ 25;
set newsales;
if CLUSTYPE=10 THEN cluster_det="Home Sweet Home";
else if CLUSTYPE=1 THEN cluster_det='Upper Crust';
else if CLUSTYPE=4 THEN cluster_det='Mid-Life Success';
else if CLUSTYPE=16 THEN cluster_det='Country Home Family';
else if CLUSTYPE=8 THEN cluster_det='Movers and Shakers';
else if CLUSTYPE=15 THEN cluster_det='Great Beginnings';
else if CLUSTYPE=18 THEN cluster_det='White Picket Fence';
else if CLUSTYPE=23 THEN cluster_det='Settled In';
else if CLUSTYPE=11 THEN cluster_det='Family Ties';
else if CLUSTYPE=5 THEN cluster_det='Prosperous Metro Mix';
else cluster_det="Other Type";
run;

PROC SORT Data=NEWSALES;
BY ZIP_CODE;
RUN;

DATA NEWSALES2;
MERGE NEWSALES ZIPCODE_F;
by ZIP_CODE;
PROC SORT Data=newsales2;
BY Customer_id;
RUN;

DATA SALES_FINAL;
SET NEWSALES2;
IF Customer_id="" then delete;
RUN;

PROC FREQ Data=SALES_FINAL;
TABLES promo_responder*cluster_det/ chisq;
RUN;

PROC FREQ Data=SALES_FINAL;
TABLES promo_responder*Region/ chisq;
RUN;

PROC REG Data=sales_final;
MODEL PROMOS = FRE;
RUN;

PROC SGPLOT Data=sales_final;
title 'Linear Regression Plot Fit';
reg y= PROMOS x= FRE / cli clm;
RUN;

DATA SALES_FINAL;
SET SALES_FINAL;
amt_blouse= MON*PBLOUSES;
amt_jacket= MON*PJACKETS;
RUN;

PROC REG Data=sales_final;
MODEL FRE = amt_jacket;
RUN;

PROC SGPLOT Data=sales_final;
title 'Linear Regression Plot Fit';
reg y= FRE x= amt_jacket / cli clm;
RUN;

PROC REG Data=sales_final;
MODEL FRE = amt_blouse;
RUN;

PROC SGPLOT Data=sales_final;
title 'Linear Regression Plot Fit';
reg y= FRE x= amt_blouse / cli clm;
RUN;
