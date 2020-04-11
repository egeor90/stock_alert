# Strategy
# Apply everyday at 02:00
options(warn=-1)
setwd("...")
path_ <- paste0(getwd(),"/Shanghai2.csv")

source("functions.R")
source("function_positionR.R")

suppressWarnings(suppressMessages(require(data.table)))
suppressWarnings(suppressMessages(require(dplyr)))
suppressWarnings(suppressMessages(require(TTR)))
suppressWarnings(suppressMessages(require(xts)))


#a <- stockCombine(path_)
#a <- investing(path_)

a <- fread(path_, stringsAsFactors = F,sep = ",") %>% as.data.frame
a$date <- as.Date(a$date)
a <- xts(a[,-1],a[,1])
a <- a[which(index(a) >= as.Date("2015-01-01")),]

# plot(a$price, lwd = 2, ylim = c(min(na.omit(TTR::BBands(a$price,maType = "EMA")[,1:3])),
#                                 max(na.omit(TTR::BBands(a$price,maType = "EMA")[,1:3]))),
#      main = "Shanghai Stock Index")
# lines(TTR::BBands(a$price,maType = "EMA"), lwd = c(1,0.5,1), col = c("red", "red", "red"))
#lines(TTR::EMA(a$price,n=40),type = "l", col = "dark blue", lwd = 2)
#lines(TTR::EMA(a$price,n=70),type = "l", col = "dark green", lwd = 2)



# Signal ------------------------------------------------------------------

b <- a
b$pos <- positionR(signal = a$price, lower = TTR::BBands(a$price,maType = "EMA")$dn,
                   upper = TTR::BBands(a$price,maType = "EMA")$up,strategy = "mom")


b$changepos <- diff.xts(b$pos)
b$dprice <- diff.xts(b$price)
# 
# b <- na.omit(b)
# plot(cumsum(b$dprice * b$pos))
# lines(cumsum(b$dprice * b$pos) - cumsum(abs(b$changepos)*(mean(b$price) * (15/10000))), col = "red")

if(as.numeric(tail(b$changepos,1)) == 2){
  signal_ <- "Buy"
}else if(as.numeric(tail(b$changepos,1)) == -2){
  signal_ <- "Sell"
}else if(as.numeric(tail(b$changepos,1)) == 1){
  signal_ <- "Buy"
}else if(as.numeric(tail(b$changepos,1)) == -1){
  signal_ <- "Sell"
}else{
  signal_ <- "Neutral"
}

# if(index(tail(b$pos,1)) == Sys.Date()){
#   if(signal_ != "Neutral"){
#     print(paste0("New Signal. We recommend you to ",signal_, "!"))
#   }else{
#     print(paste0("New Signal. We do not recommend you to change position."))
#   }
# }else{
#   print("No market action")
# }

if(index(tail(b$pos,1)) == Sys.Date()){
  if(signal_ != "Neutral"){
    cat(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: New signal! We recommend you to ",signal_, "!"),
        file=paste0(getwd(),"/logs/outfile.txt"),sep="\n",append = T)
    print(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: New signal! We recommend you to ",signal_, "!"))
  }else{
    cat(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: No new signal. We do not recommend you to change current position!"),
        file=paste0(getwd(),"/logs/outfile.txt"),sep="\n", append = T)
    print(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: No new signal. We do not recommend you to change current position!"))
  }
}else{
  cat(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: No market action"),
      file=paste0(getwd(),"/logs/outfile.txt"),sep="\n", append = T)
  print(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), " UTC: No market action"))
}
