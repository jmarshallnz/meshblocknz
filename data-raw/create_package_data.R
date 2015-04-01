# load concordance file to map urban/rural status

mb_2006_ur <- read.csv("concordance-2006.csv")[,1:2]
names(mb_2006_ur) <- c("Meshblock06", "UR_cat")

# convert UR_cat to a number, and U/R binary

#            Area outside urban/rural profile,         NA, NA 
#            Highly rural/remote area,                 -3, Rural
#            Rural area with low urban influence,      -2, Rural
#            Rural area with moderate urban influence, -1, Rural
#            Rural area with high urban influence,      0, Urban
#            Independent Urban Area,                    1, Urban
#            Satellite Urban Area,                      2, Urban
#            Main urban area,                           3, Urban"

mb_2006_ur$UR_num <- mb_2006_ur$UR_cat
levels(mb_2006_ur$UR_num) <- c(NA, -3, 1, 3, 0, -2, -1, 2)
mb_2006_ur$UR_num <- suppressWarnings(as.numeric(as.character(mb_2006_ur$UR_num)))
mb_2006_ur$UR_bool <- ifelse(mb_2006_ur$UR_num < 0, "Rural", "Urban")

table(mb_2006_ur$UR_cat, mb_2006_ur$UR_bool)

devtools::use_data(mb_2006_ur)
