# #install.packages("mailR",repos="http://cran.r-project.org")
suppressWarnings(suppressMessages(require(mailR)))

if(grepl(tail(readLines(".../logs/outfile.txt"),1), pattern = "New signal!")){
  send.mail(from = "mail@mail.com",
            to = "mail@mail.com",
            subject = "New signal",
            body = paste0("We have alert for your investment. ", tail(readLines(".../logs/outfile.txt"),1)),
            smtp = list(host.name = "email-smtp.us-east-1.amazonaws.com", 
                        port = 587, 
                        user.name = "...", 
                        passwd = "...", 
                        ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
  cat(paste0(substr(as.POSIXct(Sys.time(), "UTC", format = "%Y-%m-%d %H:%M"), 1,16), ": ", paste0("We have alert for your investment. ", tail(readLines(".../logs/outfile.txt"),1))),file=".../logs/mailer.log",sep="\n",append = T)
}
