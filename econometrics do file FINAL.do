drop _all

*importing data and saving in dta format
import excel "\Users\djr\Desktop\Current\Econometrics\DataSet3.xlsx", sheet("DataSet") cellrange (B1:O135) firstrow

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



*generating gdp level to compare
gen gdplvl = exp(gdppc) 
label variable gdplvl "GDP per capita in level"


************** COVID ****************************************************

gen totcovid = covidtotal/pop
gen deathscovid = covideaths/pop

gen ltotcov = log(totcovid)
gen ldeathcov = log(deathscovid)
gen lcovmax = log(covidmax)
gen lcovmean = log(covidmean)


graph matrix lifesat totcovid deathscovid covidmax covidmean

graph matrix lifesat ltotcov ldeathcov lcovmax lcovmean


reg lifesat totcovid deathscovid covidmax covidmean
vif


reg lifesat ltotcov ldeathcov lcovmax lcovmean
vif

***********************************************************************














***************************
*  DESCRIPTIVE STATISTICS *
***************************


*HISTOGRAMS AND GRAPHS 

*gdp variables
hist gdplvl, kden name(hist0, replace)

hist gdppc, kden name(hist1, replace)

graph combine hist0 hist1



*first set of variables
hist lifesat, kden name(hist2, replace)

hist lifexp, kden name(hist3, replace)

hist gnr, kden name(hist4, replace)

hist corru, kden name(hist5, replace)


graph combine hist2 hist3 hist4 hist5



*second set of variables
hist socsup, kden name(hist6, replace)

hist free, kden name(hist7, replace)

hist pol, name(hist8, replace) discrete

*this variable will be the education when Djordje update the dataset we generate this graph
hist hdi, kden name(hist9, replace)


graph combine hist6 hist7 hist8 hist9

* ########### Tomas 31/03 #############
* Basically I chose three explanatory variables and I played with them, until the heterokedasticity part

describe

summarize Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita Socialsupport Perceptionsofcorruption Generosity HumanDevelopmentIndex

*This graph plots all the variables in a multiple scatter plot to see visually posible correlations
*graph matrix Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita

*scatter Lifesatisfaction Healthylifeexpectancy, mlabel(Country)
reg  Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita

* examine the studentized residuals as a first means for identifying outliers. Below we use the predict command with the rstudent option to generate studentized residuals and we name the residuals r.
predict r, rstudent
* see the distribution
stem r
*looking carefully the ones with std residual > 2
list r Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita Country if abs(r) > 2
*leverage: identify observations with great influence on the regression coefficient estimates
predict lev, leverage
stem lev
* a point with leverage greater than (2k+2)/n should be carefully examined. Here k is the number of predictors and n is the number of observations.
list Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita Country lev if lev >.05970149

* We can make a plot that shows the leverage by the residual squared and look for observations that are jointly high on both of these measures (we can do this using the lvr2plot command). lvr2plot stands for leverage versus residual squared plot. Using residual squared instead of residual itself, the graph is restricted to the first quadrant and the relative positions of data points are preserved. This is a quick way of checking potential influential observations and outliers at the same time. Both types of points are of great concern for us.
lvr2plot, mlabel(Country)

*Now let's move on to overall measures of influence, specifically let's look at Cook's D and DFITS.  These measures both combine information on the residual and leverage. Cook's D and DFITS are very similar except that they scale differently but they give us similar answers.
*The lowest value that Cook's D can assume is zero, and the higher the Cook's D is, the more influential the point. The convention cut-off point is 4/n
predict d, cooksd
list Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita Country d if d>4/134


*Now let's take a look at DFITS. The cut-off point for DFITS is 2*sqrt(k/n). DFITS can be either positive or negative, with numbers close to zero corresponding to the points with small or zero influence.
predict dfit, dfits
list Lifesatisfaction Healthylifeexpectancy Freedomtomakelifechoices LoggedGDPpercapita Country dfit if abs(dfit)>2*sqrt(3/134)

*Checking for Multicollinearity
vif

*Partial fits to check outliers visually
*avplots  

*Checking Normality of Residuals
kdensity r, normal

*Checking Homoskedasticity of Residuals
rvfplot, yline(0)

* !!! not sure about how these commands work
estat imtest, white
estat hettest

******************************************************* update 02/04/22 ***********************************************
*******************************************************         we did it        **************************************

clear all
import excel "C:\Users\tomso\Downloads\DataSet3.xlsx", sheet("DataSet3") firstrow

describe

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

gen totcovid = covidtotal/pop
gen deathscovid = covideaths/pop

gen ltotcov = log(totcovid)
gen ldeathcov = log(deathscovid)
gen lcovmax = log(covidmax)
gen lcovmean = log(covidmean)
gen lune=log(unemp)

 
gen pol1=0
replace pol1=1 if pol==1 
gen pol2=0
replace pol2=1 if pol==2  
gen pol3=0
replace pol3=1 if pol==3 





******* 1 thing
graph matrix lifesat hdi free socsup gini lune corru  gdppc lifexp gnr school denpop   pol3 totcovid deathscovid covidmax covidmean 

******* 2 thing (make logs before)

reg   lifesat hdi free socsup gini lune corru  gdppc lifexp gnr school denpop ltotcov pol1 pol2 pol3 ldeathcov lcovmax lcovmean 
****** 3 thing
*heterokesdaticity, due to heterokesdaticity we cannot drop variables
estat imtest, white
estat hettest
*with all independent variablesles
hettest, rhs 
*multivollinearity
vif  

*drop gdp, schooling,lifeexpectancy,covid deaths
*merging politics in two catgepries tp avoid multivollinearity - one of the reasons for dropiing gdp instead of schooling or life exp or hdi is endogeneity issues - comment in paper.
replace pol3=0
replace pol3=1 if pol==3 
replace pol3=1 if pol==2

*we run regre again
reg lifesat hdi free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean
vif


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
list lifesat gdppc free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean Country dfit if abs(dfit)>2*sqrt(3/120)

*removing problematic outliers Botswana Rwanda and Myanmar

drop if abs(r)>3


*we run regre again
reg lifesat hdi free socsup gini lune corru ldeathcov pol3 gnr denpop covidmean
vif

*Checking Normality of Residuals
kdensity r, normal

*Checking Homoscedasticity of Residuals
rvfplot, yline(0) mlabel(Country)
estat imtest, white
hettest, rhs fstat

*final regre droping gini denpop and covidmean because of t stat - so they were insignificatn
* check the f tests tomorrow
*to test whether the variables we want to drop maybe have a significant impact on life satisfaction whenb taken together, we perform an f test - here H0 is that all of these variables have effect 0, and since the p value is bigger than 0.05, we cannot reject null, so they have no effect.
test gini gnr denpop covidmean

reg lifesat hdi free socsup lune corru ldeathcov pol3 
vif












