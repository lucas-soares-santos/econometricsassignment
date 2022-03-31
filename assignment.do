drop _all

*importing data and saving in dta format
import excel "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset\DataSet.xlsx", sheet("DataSet") cellrange (B1:O135) firstrow

cd "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset"

save assignment, replace



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

* !!! not sure about how this commands work
estat imtest, white
estat hettest


