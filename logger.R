# Every hour
setwd(".../logs/")

a <- as.POSIXct(gsub("^\\s+|\\s+$", "",gsub(pattern = "UTC:.*","",x = readLines("outfile.txt"))), 
                format = "%Y-%m-%d %H:%M", tz = "UTC")
cat(readLines("outfile.txt")[which(a >= (Sys.time() - 60*60*24*2))], file = "outfile2.txt", sep="\n")
system("mv outfile2.txt outfile.txt")
