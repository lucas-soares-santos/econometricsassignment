drop _all

*importing data and saving in dta format
import excel "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset\DataSet.xlsx", sheet("DataSet") cellrange (B1:O135) firstrow

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

******************************************************* update 02/04/22 **************************************
*******************************************************                 **************************************
generate logpop=log(Populationdensity)
generate logune=log(Unemployment)
*generate logsch=log(Averagetotalyearsofschooling)
generate logstr=log(Covidpolicymeanstringencyind/Populationdensity)
generate logstr2=log(Covidpolicymaximumstringency/Populationdensity)
generate logcases=log(Covidcasestotal/Populationdensity)


*second set of variables
hist Giniinequalityindex2019, kden name(hist6, replace)
hist Unemployment, kden name(hist7, replace)
hist Populationdensity,kden name(hist8, replace) 
*hist logune, kden name(hist7, replace)
*hist logpop,kden name(hist8, replace) 
hist Averagetotalyearsofschooling, kden name(hist9, replace)
*hist logsch, kden name(hist9, replace)
graph combine hist6 hist7 hist8 hist9


* multiple tries to check the models
reg  Lifesatisfaction LoggedGDPpercapita Freedomtomakelifechoices Socialsupport Giniinequalityindex2019 logune Perceptionsofcorruption pol1 pol2 pol3



******************************************** First model *******************************



reg  Lifesatisfaction HumanDevelopmentIndex Freedomtomakelifechoices Socialsupport Giniinequalityindex2019 logune Perceptionsofcorruption
vif

*model adding dummy variables
reg  Lifesatisfaction HumanDevelopmentIndex Freedomtomakelifechoices Socialsupport Giniinequalityindex2019 logune Perceptionsofcorruption pol3

vif
*********************************************









