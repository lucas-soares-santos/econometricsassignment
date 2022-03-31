drop _all

*importing data and saving in dta format
import excel "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset\DataSet.xlsx", sheet("DataSet") cellrange (B1:O135) firstrow

cd "C:\Users\Lucas\Documents\Workarea\QEM Msc\2nd Semester\Econometrics\Assignment\dataset"

save assignment, replace
