drop _all

*importing data and saving in dta format
import excel "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset\DataSet3.xlsx", sheet("DataSet3") cellrange(B1:T121) firstrow


cd "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset"

save assignment, replace

sum _all


rename Lifesatisfaction lifesat
rename LoggedGDPpercapita gdppc
rename Healthylifeexpectancy lifexp
rename Generosity gnr
rename Perceptionsofcorruption corru
rename Socialsupport socsup
rename Freedomtomakelifechoices free
rename Politics pol
rename Covidpolicymaximumstringency covidmax
rename Covidpolicymeanstringencyind covidmean
rename Covidcasestotal covidtotal
rename Coviddeathstotal covideaths
rename Populationdensity denpop
rename Unemploymenttotaloftotal unemp
rename Giniinequalityindex gini
rename Averagetotalyearsofschooling school
rename Populationsize pop
rename HumanDevelopmentIndex hdi


************* GENERATING VARIABLES **********

gen totcovid = covidtotal/pop
gen deathscovid = covideaths/pop
gen ltotcov = log(totcovid)
gen ldeathcov = log(deathscovid)
gen lcovmax = log(covidmax)
label variable lcovmax "Log of covid max stringency index"
gen lcovmean = log(covidmean)
label variable lcovmean "Log of covid mean stringency index"
gen lune = log(unemp)


*generating GDP in level for comparison
gen gdplvl = exp(gdppc) 
label variable gdplvl "GDP per capita in level"
label variable unemp "Unemployment, total (% of total labor force)"
label variable lune "Log of unemployment rate"


*generating dummy variables for politics

gen pol1=0
replace pol1=1 if pol==1 
gen pol2=0
replace pol2=1 if pol==2  
gen pol3=0
replace pol3=1 if pol==3 




****************************************************
*************  DESCRIPTIVE STATISTICS  *************
****************************************************




*First chart: overview
graph matrix lifesat gdppc lifexp gnr corru socsup free gini pop covidmax covidmean ltotcov ldeathcov denpop lune gini school hdi


*histograms
hist gdplvl, kden name(hist1, replace)
hist unemp, kden name(hist2, replace)
hist gdppc, kden name(hist3, replace)
hist lune, kden name(hist4, replace)

graph combine hist1 hist2 hist3 hist4


graph export "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist0.png", as(png) name("Graph0")
file C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist0.png saved as PNG format





hist lifesat, kden name(hist5, replace)
hist lifexp, kden name(hist6, replace)
hist gnr, kden name(hist7, replace)
hist corru, kden name(hist8, replace)

graph combine hist5 hist6 hist7 hist8


graph export "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist1.png", as(png) name("Graph1")
file C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist1.png saved as PNG format





hist covidmax, kden name(hist9, replace)
hist covidmean, kden name(hist10, replace)
hist lcovmax, kden name(hist11, replace)
hist lcovmean, kden name(hist12, replace)

graph combine hist9 hist10 hist11 hist12

graph export "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist2.png", as(png) name("Graph2")
file C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\hist2.png saved as PNG format






**********************************************************
*********************   FIRST MODEL   ********************
**********************************************************




reg lifesat gdppc lifexp gnr corru socsup free covidmax covidmean ltotcov ldeathcov denpop lune gini school hdi pol1 pol2 pol3

vif 

corr lifesat hdi gdppc school lifexp ltotcov ldeathcov pol1 pol3 pol2 covidmax covidmean socsup 

corr lifesat hdi gdppc school lifexp ltotcov ldeathcov pol1 pol3 pol2 covidmax covidmean socsup free corru lune gini gnr denpop

*strong multicollinearity issues, merging dummies

replace pol3 = 1 if pol == 2


reg lifesat hdi ltotcov ldeathcov pol3 gnr corru socsup free covidmax covidmean ldeathcov denpop lune gini
vif 


corr lifesat school ldeathcov pol3 gnr corru socsup free covidmean  denpop lune gini



reg lifesat gdppc school ldeathcov pol3 gnr corru socsup free covidmean  denpop lune gini
vif 


reg lifesat gdppc lifexp ldeathcov pol3 gnr corru socsup free covidmean  denpop lune gini
vif 


*not possible to keep GDP and school or life expectancy in the same model, we decided to keep HDI
reg lifesat hdi ldeathcov pol3 gnr corru socsup free covidmean  denpop lune gini
vif 



*************************************************************
*********************  HETEROSKEDASTICITY  ****************** *************************************************************
  
estat imtest, white


hettest


hettest, fstat


hettest, rhs fstat

  
*Checking Homoscedasticity of Residuals visually
rvfplot, yline(0) mlabel(Country)
 
 graph export "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\Graphs\het3.png", as(png) name("Graph3")
file C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd
    Semester\Econometrics\Assignment\Graphs\het3.png
    saved as PNG format


*the model is heteroskedastic but we fix it by droping the outliers



*********************************************************  
************************   OUTLIERS   *******************
*********************************************************  
  
  
*outilers/influential

predict r, rstudent


* see the distribution
stem r
*looking carefully the ones with std residual > 2

list r lifesat gdppc free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean Country if abs(r) > 3


*Conditional fits to check outliers visually (another way)
avplots

*check leverage
*leverage: identify observations with great influence on the regression coefficient estimates
predict lev, leverage
stem lev
* a point with leverage greater than (2k+2)/n should be carefully examined. Here k is the number of predictors and n is the number of observations.
list lifesat gdppc free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean Country if lev >(2*11 +2)/120

lvr2plot, mlabel(Country)

*Now let's move on to overall measures of influence, specifically let's look at Cook's D and DFITS.  These measures both combine information on the residual and leverage. Cook's D and DFITS are very similar except that they scale differently but they give us similar answers.
*The lowest value that Cook's D can assume is zero, and the higher the Cook's D is, the more influential the point. The convention cut-off point is 4/n
predict e, cooksd
list lifesat gdppc free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean Country e if e>4/120


*Now let's take a look at DFITS. The cut-off point for DFITS is 2*sqrt(k/n). DFITS can be either positive or negative, with numbers close to zero corresponding to the points with small or zero influence.
predict efit, dfits
list lifesat gdppc free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean Country efit if abs(efit)>2*sqrt(3/120)

*removing problematic outliers Botswana Rwanda and Myanmar

drop if abs(efit)>1





*****************************************************************
**********************  FINAL MODEL  ****************************
*****************************************************************


*checking heteroskedasticity again
reg lifesat hdi ldeathcov pol3 gnr corru socsup free covidmean  denpop lune gini

estat imtest, white


hettest


hettest, fstat


hettest, rhs fstat





*the model now has a tolerable level of heteroskedasticity and we are able to drop variables based on the significance statistics

test gnr covidmean denpop gini

*based on this test we can drop all of these 4 variables and the last model is 

reg lifesat hdi ldeathcov pol3 corru socsup free lune 


*the model now is the most reduced version satisfying Gauss-Marokov hypothesis


vif


estat imtest, white

hettest, rhs
