# install.packages("devtools")
# devtools::install_github("torvaney/ggsoccer")
# I have to install manually rlang

# Usage
# This example uses ggsoccer to plot a set of passes onto a soccer pitch.

library(ggplot2)
library(ggsoccer)
library(dplyr)
library(RCurl)

myCsv <- getURL("https://raw.githubusercontent.com/davidfombella/Parse_OptaF24_Feed_Soccer/master/Generated_files/goal_data_Bolton%20Wanderers_Manchester%20City.csv")
goals <- read.csv(textConnection(myCsv))

passes <- read.csv(textConnection(getURL("https://raw.githubusercontent.com/davidfombella/Parse_OptaF24_Feed_Soccer/master/Generated_files/pass_data_Bolton%20Wanderers_Manchester%20City.csv")))


# GOALS

ggplot(goals) +
  annotate_pitch(colour = "gray70", fill = "gray90") +
  geom_point(aes(x = x, y = y, colour=team,shape=body.part), size = 4) +
  geom_text(aes(x = x, y = y,label=player,hjust=0.2, vjust=0.3))+
  theme_pitch() +
  direction_label() +
  ggtitle("Bolton Wanderers 2 - 3 Manchester City", "Sun 11 Aug 2011")

# GOALS ggREPEL

ggplot(goals) +
  annotate_pitch(colour = "gray70", fill = "gray90") +
  geom_point(aes(x = x, y = y, colour=team,shape=body.part), size = 4) +
  geom_text_repel(aes(x = x, y = y,label=player)) +
  theme_pitch() +
  direction_label() +
  ggtitle("Bolton Wanderers 2 - 3 Manchester City", "Sun 11 Aug 2011")



# GOALS SHOT MAP

ggplot(goals) +
  annotate_pitch(colour = "gray70", fill = "gray90") +
  geom_point(aes(x = x, y = y,colour=team,shape=body.part), size = 4) +
  theme_pitch()+
  coord_flip(xlim = c(50, 101), ylim = c(-1, 101))+
  ggtitle("Shotmap", "EPL ")+theme_classic()


# GOALS SHOT MAP
ggplot(goals) +
  annotate_pitch(colour = "gray70", fill = "gray90") +
  geom_point(aes(x = x, y = y,colour=team,shape=body.part), size = 4) +
  theme_pitch()+
  coord_flip()+
  scale_y_reverse()+
  ggtitle("Shotmap", "EPL ")+theme_classic()



# Passes

passes %>%
  dplyr::filter(player=="David Silva")%>%
  ggplot() +
  annotate_pitch() +
  geom_segment(aes(x = x, y = y, xend = x_end, yend = y_end,colour=as.factor(outcome)),size=0.5,
   arrow = arrow(length = unit(0.25, "cm"),type = "closed")) +
  theme_pitch() +
  direction_label() +
  ggtitle("David Silva Passes", "EPL 2011 vs Bolton")



unique(passes$pass.zone)
# Because ggsoccer is implemented as ggplot layers, it makes customising a plot very easy.
# Here is a different example, plotting shots on a **gray** pitch.

# Note that by default, ggsoccer will display the whole pitch. To display a
# subsection of the pitch, simply set the plot limits as you would with any other
# ggplot2 plot. Here, we use the `xlim` and `ylim` arguments to `coord_flip`:


#  SHOTS

shots <- data.frame(x = c(90, 85, 82, 78, 83, 74),
                    y = c(43, 40, 52, 56, 44, 71))

ggplot(shots) +
  annotate_pitch(colour = "gray70", fill = "gray90") +
  geom_point(aes(x = x, y = y),  fill = "white", size = 4,  pch = 21) +
  theme_pitch()+
  coord_flip(xlim = c(49, 101), ylim = c(-1, 101))+
  ggtitle("Shotmap", "EPL ")


### StatsBomb data

# Finally, different data providers may use alternative co-ordinate systems to ggsoccer default 100x100.
#  For instance,[StatsBomb's release of free data]() uses a 120x80 co-ordinate system.
#  This can be easily handled with the `*_scale` arguments to `annotate_pitch`:


# Rescale shots to use StatsBomb-style coordinates

shots_rescaled <- data.frame(x = shots$x * 1.20,  y = shots$y * 0.80)

ggplot(shots_rescaled) +
  annotate_pitch(x_scale = 1.2,  y_scale = 0.8, colour = "white",  fill = "green4") +
  geom_point(aes(x = x, y = y), fill = "yellow2", size = 5, pch = 21) +
  theme_pitch() +
  coord_flip(xlim = c(59, 121),   ylim = c(-1, 81)) +
  ggtitle("Shotmap", "ggsoccer example (120x80 co-ordinates)")



## Other options

# There are other packages that offer alternative pitch plotting options.
# Depending on your use case, you may want to check these out too:

#  * [soccermatics](https://github.com/JoGall/soccermatics)
#  * [SBpitch](https://github.com/FCrSTATS/SBpitch)
