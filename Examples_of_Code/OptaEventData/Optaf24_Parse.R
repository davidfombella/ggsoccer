library(XML)
library(plyr)
library(reshape)

fnm <- "Bolton_ManCityF24.xml"

#utility function
grabAll <- function(XML.parsed, field){
  parse.field <- xpathSApply(XML.parsed, paste("//", field, "[@*]", sep=""))
  results <- t(sapply(parse.field, function(x) xmlAttrs(x)))
  if(typeof(results)=="list"){
    do.call(rbind.fill, lapply(lapply(results, t), data.frame, stringsAsFactors=F))
  } else {
    as.data.frame(results, stringsAsFactors=F)
  }
}

#XML Parsing
pbpParse <- xmlInternalTreeParse(fnm)
eventInfo <- grabAll(pbpParse, "Event")
eventParse <- xpathSApply(pbpParse, "//Event")
NInfo <- sapply(eventParse, function(x) sum(names(xmlChildren(x)) == "Q"))
QInfo <- grabAll(pbpParse, "Q")
EventsExpanded <- as.data.frame(lapply(eventInfo[,1:2], function(x) rep(x, NInfo)), stringsAsFactors=F)
QInfo <- cbind(EventsExpanded, QInfo)
names(QInfo)[c(1,3)] <- c("Eid", "Qid")
QInfo$value <- ifelse(is.na(QInfo$value),-1, QInfo$value)
Qual <- cast(QInfo, Eid ~ qualifier_id)

#final data set
events <- merge(eventInfo, Qual, by.x="id", by.y="Eid", all.x=T)
events$min <- as.numeric(as.character(events$min))
events$sec <- as.numeric(as.character(events$sec))
events$x <- as.numeric(as.character(events$x))
events$y <- as.numeric(as.character(events$y))
