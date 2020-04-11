investing <- function(path){
  suppressWarnings(suppressMessages(require(data.table)))
  suppressWarnings(suppressMessages(require(xts)))
  
  dt <- fread(path, stringsAsFactors = FALSE)
  
  dt[,2:5] <- data.table(apply(dt[,2:5],2,FUN = function(x)gsub(pattern = ",","",x)))
  
  for(i in 1:nrow(dt)){
    if(substr(dt$Vol.[i],nchar(dt$Vol.[i]),nchar(dt$Vol.[i])) == "B"){
      dt$Vol.[i] <- as.numeric(substr(dt$Vol.[i],1,nchar(dt$Vol.[i])-1)) * 1000000000
    }else if(substr(dt$Vol.[i],nchar(dt$Vol.[i]),nchar(dt$Vol.[i])) == "M"){
      dt$Vol.[i] <- as.numeric(substr(dt$Vol.[i],1,nchar(dt$Vol.[i])-1)) * 1000000
    }else{
      dt$Vol.[i] <- dt$Vol.[i]
    }
  }
  
  dt$`Change %` <- substr(dt$`Change %`,1,nchar(dt$`Change %`)-1)
  dt$Date <- as.Date(dt$Date, format = "%b %d, %Y")
  
  colnames(dt) <- c("date", "price", "open", "high", "low", "vol", "change")
  dt[,2:ncol(dt)] <- data.table(apply(dt[,-1], 2, FUN= function(x)as.numeric(x)))
  
  df <- data.frame(dt)
  xts_ <- xts(df[,-1],df[,1])
  
  return(xts_)
}

importData <- function(path){
  options(warn=-1)
  suppressWarnings(suppressMessages(require(data.table)))
  suppressWarnings(suppressMessages(require(xts)))
  
  dt <- fread(path_, stringsAsFactors = FALSE)
  colnames(dt)[1] <- "date"
  
  return(dt)
}



get_quote_data <- function(symbol='%5ESSEC', data_range='1y', data_interval='1d'){
  suppressWarnings(suppressMessages(require(xts)))
  suppressWarnings(suppressMessages(require(jsonlite)))
  res <- paste0("https://query1.finance.yahoo.com/v8/finance/chart/",symbol,"?range=",data_range,"&interval=",data_interval)
  data <- fromJSON(res)
  names_ <- data.frame(names(unlist(data)))
  
  time_nr <- which(grepl('^chart.result.timestamp',names_[,1]))
  time_ <- as.POSIXct(as.numeric(as.character(data.frame(unlist(data))[time_nr,])), tz = "UTC", origin = "1970-01-01 00:00:00")
  
  for(i in c("open","high","low","close","volume")){
    nr_ <- which(grepl(paste0('^chart.result.indicators.quote.',i),names_[,1]))
    var_ <- data.frame(as.numeric(as.character(data.frame(unlist(data))[nr_,])))
    colnames(var_) <- i
    if(!exists("var_2")){
      var_2 <- var_
    }else{
      var_2 <- cbind(var_2,var_)
    }
  }  
  
  colnames(var_2)[4] <- "price"
  
  var_2 <- data.frame(date=time_,var_2)
  return(var_2)
}


stockCombine <- function(path){
  suppressWarnings(suppressMessages(require(dplyr)))
  data_ <- importData(path)
  data_$date <- as.Date(data_$date)
  data_$vol <- as.numeric(data_$vol)
  
  data_1 <- get_quote_data()
  data_1 <- data_1[,c("date", "price", "open", "high", "low", "volume")]
  data_1$date <- as.Date(data_1$date)
  colnames(data_1)[ncol(data_1)] <- "vol"
  
  all_data <- bind_rows(data_,data_1)
  
  all_data <- rbind(data_,data_1[which(data_1[,"date"] > tail(data_[,"date"],1)),]) %>% as.data.frame()
  all_data <- xts(all_data[,-1],all_data[,1])
  return(all_data)
}

write_data <- function(data){
  df <- data.frame(data)
  df$date <- as.Date(row.names(df))
  rownames(df) <- 1:nrow(df)
  df <- df[,c("date","price","open","high","low","vol")]
  write.table(x=df, file = "/home/ege/AsiaStocks/Shanghai2.csv", 
              row.names = F, col.names = TRUE, sep = ",")
}
