##########################
## INSTALL DEPENDENCIES ##
##########################

install.packages("rsconnect")
library(rsconnect)

#############################
## PUBLISH ON shinyapps.io ##
#############################

rsconnect::setAccountInfo(name='weerou-francis-calingo',
                          token='DFC62FC2EABFB1340029C74C081ACDE4',
                          secret='[REDACTED]')

rsconnect::deployApp('.')


