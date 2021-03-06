## EPL Styling via ggplot2 in R  

# Wanted to try a few new techniques with ggplot2, so recreated the EPL Next 6 Games graphic using only R as well as grabbing 
# the needed data from the soccerway.com website. 

# I will get the time at some point to comment out the below code to help others learn, but thought I would post now.
#  You can switch the CLUB_WEBPAGE variable to another club page and it should all work out automatically. 

# Here is the result:

# ![](https://github.com/FCrSTATS/Visualisations/blob/master/Images/Rplot08.jpeg)

#### The Code 


### ------ Get the Data ----------------------------------------------------------||
CLUB_WEBPAGE <- "https://nr.soccerway.com/teams/england/manchester-city-football-club/676/"
require(rvest); require(xml2); require(dplyr); require(extrafont)

extrafont::font_import()

ws <- read_html(CLUB_WEBPAGE)
club.name <- ws %>% html_node("h1") %>% html_text() %>% as.character()
links <- paste0("https://nr.soccerway.com", ws %>% html_nodes(".score-time a") %>% html_attr("href") %>% as.character())
links <- links[5:10]
fixtures.clubs <- data.frame(stringsAsFactors = F)

for (i in links) {
  ws2 <- read_html(i)
  clubnames <- ws2 %>% html_nodes(".thick a") %>% html_text() %>% as.character()
  temp <- data.frame(HomeTeam = clubnames[1], AwayTeam = clubnames[2], stringsAsFactors = F)
  fixtures.clubs <- bind_rows(fixtures.clubs, temp)
}

date <- ws %>% html_nodes(".full-date") %>% html_text() %>% as.character()
date <- date[6:11]
date <- gsub("/18", "", date)
date.string <- list()

for (i in date) {
  day <- unlist(strsplit(i, "/"))[1]
  month <- unlist(strsplit(i, "/"))[2]
  month <- gsub("08", "Aug", month)
  month <- gsub("09", "Sep", month)
  month <- gsub("10", "Oct", month)
  month <- gsub("11", "Nov", month)
  month <- gsub("12", "Dec", month)
  temp <- paste0(day, " ", month)
  date.string <- append(unlist(date.string), temp)
}

fixtures.clubs$date <- date.string
selected.club <- names(which.max(table(fixtures.clubs$HomeTeam))) 
fixtures.clubs$H_A <- ifelse(fixtures.clubs$HomeTeam == selected.club, "H", "A")
logo_url <- ws %>% html_node("#page_team_1_block_team_info_3 img") %>% html_attr("src") %>% as.character()


### ------ Get Plotting ----------------------------------------------------------||
require(ggplot2)
## set up the background and size of plot 
p <- ggplot() + xlim(c(0,1320)) + ylim(c(0,660)) 
## setup a blank theme function that is styled by variables 
    theme_blank = function(size=12, background_colour) {
    theme(
      #axis.line=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank(),
      #axis.ticks.y=element_text(size=size),
      #   axis.ticks=element_blank(),
      axis.ticks.length=unit(0, "lines"),
      #axis.ticks.margin=unit(0, "lines"),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      legend.background=element_rect(fill=background_colour, colour=NA),
      legend.key=element_rect(colour=background_colour,fill=background_colour),
      legend.key.size=unit(1.2, "lines"),
      legend.text=element_text(size=size),
      legend.title=element_text(size=size, face="bold",hjust=0),
      strip.background = element_rect(colour = background_colour, fill = background_colour, size = .5),
      panel.background=element_rect(fill=background_colour,colour=background_colour),
      #panel.border(remove = TRUE),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      panel.spacing=element_blank(),
      plot.background=element_blank(),
      plot.margin=unit(c(0, 0, 0, 0), "lines"),
      plot.title=element_text(size=size*1.2),
      strip.text.y=element_text(colour=background_colour,size=size,angle=270),
      strip.text.x=element_text(size=size*1))}
	  
	  

BG.col <- "#FC125D"
cell.lines <- "#3D033B"
## apply the theme 
p <- p + theme_blank(background_colour = BG.col)
## set side rectangles 
rectangle.colour <- "#3D033B" # set the colour of the side rectangles to plot 
# add left rect
p <- p + geom_rect(aes(xmin = 0, xmax = 33, ymin = 50, ymax = 610), colour = NA, fill = rectangle.colour)
# add right rect
p <- p + geom_rect(aes(xmin = 1120, xmax = 1320, ymin = 50, ymax = 610), colour = NA, fill = rectangle.colour)
## Add club header rectangle 
table.bg.colour <- "#f3f4f6"
p <- p + geom_rect(aes(xmin = 370, xmax = 945, ymin = 465, ymax = 544), colour = NA, fill = table.bg.colour)
p <- p + geom_rect(aes(xmin = 370, xmax = 945, ymin = 150, ymax = 390), colour = NA, fill = table.bg.colour)

## add some lines to the tables 
# line between club logo and title 
p <- p + annotate("segment", x = 450, xend = 450, y = 465, yend = 544, colour = cell.lines)
# line between club title and "next 6 games"
p <- p + annotate("segment", x = 450, xend = 945, y = 496, yend = 496, colour = cell.lines)
# line between cells in fixture tables
p <- p + annotate("segment", x = 370, xend = 945, y = 190, yend = 190, colour = cell.lines)
p <- p + annotate("segment", x = 370, xend = 945, y = 230, yend = 230, colour = cell.lines)
p <- p + annotate("segment", x = 370, xend = 945, y = 270, yend = 270, colour = cell.lines)
p <- p + annotate("segment", x = 370, xend = 945, y = 310, yend = 310, colour = cell.lines)
p <- p + annotate("segment", x = 370, xend = 945, y = 350, yend = 350, colour = cell.lines)
# line between club and date
p <- p + annotate("segment", x = 850, xend = 850, y = 150, yend = 390, colour = cell.lines)
# line between club and home/away
p <- p + annotate("segment", x = 450, xend = 450, y = 150, yend = 390, colour = cell.lines)

## add some text 
# main cub title 
p <- p + annotate("text", x = 470, y = 518, label =  toupper(selected.club), hjust = 0, family="Arial Black", size = 5)
## home and away title data 
Home.Away.Data <- data.frame(H_A = fixtures.clubs$H_A, y = seq(170,370,40), stringsAsFactors = F)
Home.Away.Data$x <- 412
## home and away title data 
opposition <- ifelse(fixtures.clubs$HomeTeam == selected.club, fixtures.clubs$AwayTeam, fixtures.clubs$HomeTeam)
opposition.Data <- data.frame(Opposition = opposition, y = seq(170,370,40), stringsAsFactors = F)
opposition.Data$x <- 471
## date title data 
date.Data <- data.frame(Date.plt = fixtures.clubs$date, y = seq(170,370,40), stringsAsFactors = F)
date.Data$x <- 870
  
# next 6 games 
p <- p + annotate("text", x = 470, y = 479, label = "Next 6 Games", hjust = 0, family="Arial", size = 4)
p <- p + annotate("text", x = Home.Away.Data$x, y = Home.Away.Data$y, label = Home.Away.Data$H_A, family="Arial", size = 4)
p <- p + annotate("text", x = opposition.Data$x, y = opposition.Data$y, label = opposition.Data$Opposition, hjust = 0, family="Arial Black", size = 4)
p <- p + annotate("text", x = date.Data$x, y = date.Data$y, label = date.Data$Date.plt, hjust = 0, family="Arial", size = 4)

require(cowplot)
plot_grid(p, scale=1.1)

## add logo 
library(png)
library(grid)
library(RCurl)

img <- readPNG("epl_premier_pink.png")

g <- rasterGrob(img, interpolate=TRUE) 

p <- p + annotation_custom(g, xmin=1179, xmax=1179 + 100 , ymin=241, ymax=241 + 166)
img <- readPNG(getURLContent(logo_url))
g <- rasterGrob(img, interpolate=TRUE) 
p <- p + annotation_custom(g, xmin=375, xmax=374 + 70 , ymin=468, ymax=468 + 70)
plot_grid(p, scale=1.1)
