libname utd 'H:\Project'; run;

data _null_; 
      rc=dlgcdir("C:\Users\jdc065000\Desktop\SAS Files");
      put rc=;
   run;

proc import datafile = 'H:\Project\express6.csv'
 out = work.express
 dbms = CSV
 ;
run;


DATA work.express ;
  SET work.express ;
 
  IF income_cat = 'lt25k' THEN lt25k = 1; 
    ELSE lt25k = 0;
  IF income_cat = '25k-45k' THEN lt45k = 1; 
    ELSE lt45k = 0;
  IF income_cat = '45k-65k' THEN lt65k = 1; 
    ELSE lt65k = 0;
  IF income_cat = '65k-85k' THEN lt85k = 1; 
    ELSE lt85k = 0;
  IF income_cat = '85k-115k' THEN lt115k = 1; 
    ELSE lt115k = 0;
  IF income_cat = ' 115k-125k' THEN lt125k = 1; 
    ELSE lt125k = 0;
  IF income_cat = 'gt125k' THEN gt125k = 1; 
    ELSE gt125k = 0;
 
RUN;

data express;
set express;
std_em_received_ty = em_received_ty;
std_dm_received_ty = dm_received_ty;
std_prod_category_count = prod_category_count;
run;



PROC STANDARD DATA=work.express MEAN=0.5 STD=.5 OUT=work.express;
 var
std_em_received_ty	std_dm_received_ty std_prod_category_count;
RUN;

DATA work.express;
  SET work.express;
if sales_pcnt > 1 then sales_pcnt =1;
if spring_pcnt > 1 then spring_pcnt = 1;
if fall_pcnt > 1 then fall_pcnt = 1;
if holiday_pcnt > 1 then holiday_pcnt = 1;
if bts_pcnt > 1 then bts_pcnt = 1;
if clearance_pcnt > 1 then clearance_pcnt = 1;
if pcnt_m_prod	> 1 then pcnt_m_prod = 1;
if pcnt_w_prod > 1 then pcnt_w_prod = 1;
if sales_pcnt < 0 then sales_pcnt =0;
if spring_pcnt < 0 then spring_pcnt = 0;
if fall_pcnt < 0 then fall_pcnt = 0;
if holiday_pcnt < 0 then holiday_pcnt = 0;
if bts_pcnt < 0 then bts_pcnt = 0;
if clearance_pcnt < 0 then clearance_pcnt = 0;
if pcnt_m_prod	< 0 then pcnt_m_prod = 0;
if pcnt_w_prod < 0 then pcnt_w_prod = 0;
run;


proc fastclus data = work.express
maxclusters = 6 out = final;
var
lt25k	lt45k	lt65k	lt85k	lt115k	gt125k management_occ	technical_occ	professinal_occ	sales_occ	
officeadmin_occ	bluecollar_occ	farmer_occ	other_occ	retired_occ
std_em_received_ty	std_dm_received_ty	is_redeemer
sales_pcnt	spring_pcnt	fall_pcnt	holiday_pcnt	bts_pcnt	clearance_pcnt	
RETAIL	WEB	std_PROD_CATEGORY_COUNT
pcnt_m_prod	pcnt_w_prod;
run;

data market;
set final;
logit_pcnt_m_casual_bottoms = 0; logit_pcnt_m_knits = 0; logit_pcnt_m_shirts = 0; logit_pcnt_m_suits = 0; logit_pcnt_w_denim = 0;
logit_pcnt_w_dress = 0; logit_pcnt_w_knit_tops = 0; logit_pcnt_w_pants = 0; logit_pcnt_w_sweaters = 0; logit_pcnt_w_woven_tops = 0;
if pcnt_m_casual_bottoms > 0 then logit_pcnt_m_casual_bottoms = 1;
if pcnt_m_knits > 0 then logit_pcnt_m_knits = 1;
if pcnt_m_shirts > 0 then logit_pcnt_m_shirts = 1;
if pcnt_m_suits > 0 then logit_pcnt_m_suits = 1;
if pcnt_w_denim > 0 then logit_pcnt_w_denim = 1;
if pcnt_w_dress > 0 then logit_pcnt_w_dress = 1;
if pcnt_w_knit_tops > 0 then logit_pcnt_w_knit_tops = 1;
if pcnt_w_pants > 0 then logit_pcnt_w_pants = 1;
if pcnt_w_sweaters > 0 then logit_pcnt_w_sweaters = 1;
if pcnt_w_woven_tops > 0 then logit_pcnt_w_woven_tops = 1;

run;

proc sort data = market; 
by cluster; run;

proc reg data = work.market;
by cluster;
model QTY = price discount_amt WEB pcnt_m_casual_bottoms	pcnt_m_knits	pcnt_m_shirts	
pcnt_m_suits	pcnt_w_denim	pcnt_w_dress	pcnt_w_knit_tops	pcnt_w_pants	pcnt_w_sweaters
pcnt_w_woven_tops sales_pcnt	spring_pcnt	fall_pcnt	holiday_pcnt	bts_pcnt	clearance_pcnt
em_received_ty dm_received_ty profile	is_redeemer;
run;


Proc Means data=work.market;
by cluster;
run;

proc reg data = work.market;
where logit_pcnt_m_casual_bottoms;
model QTY = price discount_amt WEB pcnt_m_casual_bottoms	pcnt_m_knits	pcnt_m_shirts	
pcnt_m_suits	pcnt_w_denim	pcnt_w_dress	pcnt_w_knit_tops	pcnt_w_pants	pcnt_w_sweaters
pcnt_w_woven_tops sales_pcnt	spring_pcnt	fall_pcnt	holiday_pcnt	bts_pcnt	clearance_pcnt
em_received_ty dm_received_ty profile	is_redeemer;
run;

Proc Means data=work.market;
where logit_pcnt_m_casual_bottoms;
run;

proc logistic descending data = market;
by cluster;
model logit_pcnt_m_casual_bottoms = logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits logit_pcnt_w_denim
logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;
proc logistic descending data = market;
by cluster;
model logit_pcnt_m_knits = logit_pcnt_m_casual_bottoms logit_pcnt_m_shirts logit_pcnt_m_suits logit_pcnt_w_denim
logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;
proc logistic descending data = market;
by cluster;
model logit_pcnt_m_shirts = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_suits logit_pcnt_w_denim
logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;
proc logistic descending data = market;
by cluster;
model logit_pcnt_m_suits = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_w_denim
logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;
proc logistic descending data = market;
by cluster;
model logit_pcnt_w_denim = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;
proc logistic descending data = market;
by cluster;
model logit_pcnt_w_dress = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_denim logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;

proc logistic descending data = market;
by cluster;
model logit_pcnt_w_knit_tops = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_denim logit_pcnt_w_dress logit_pcnt_w_pants logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;

proc logistic descending data = market;
by cluster;
model logit_pcnt_w_pants = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_denim logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_sweaters logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;

proc logistic descending data = market;
by cluster;
model logit_pcnt_w_sweaters = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_denim logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_woven_tops
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;

proc logistic descending data = market;
by cluster;
model logit_pcnt_w_woven_tops = logit_pcnt_m_casual_bottoms logit_pcnt_m_knits logit_pcnt_m_shirts logit_pcnt_m_suits
logit_pcnt_w_denim logit_pcnt_w_dress logit_pcnt_w_knit_tops logit_pcnt_w_pants logit_pcnt_w_sweaters
WEB	PROD_CATEGORY_COUNT em_received_ty	dm_received_ty profile	is_redeemer;
run;

