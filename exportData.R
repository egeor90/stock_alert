# Export Data
# everyday at 23:00

setwd("...")
path_ <- paste0(getwd(),"/Shanghai2.csv")

source("functions.R")
source("function_positionR.R")

a <- stockCombine(path_)

write_data(data=a)
