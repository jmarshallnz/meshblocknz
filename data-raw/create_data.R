library(dplyr)

download <- FALSE

if (download) {
  # download census information
  download.file("http://www3.stats.govt.nz/meshblock/2013/csv/2013_mb_dataset_Total_New_Zealand_CSV.zip",
                destfile = "data-raw/census2013/2013_mb_census.zip", mode = "wb")
  unzip("data-raw/census2013/2013_mb_census.zip", exdir = "data-raw/census2013")
}

if (download) {
  download.file("http://www3.stats.govt.nz/meshblock/2006/excel/2006mbdatasetallnz.zip",
                destfile = "data-raw/census2006/2006_mb_census.zip", mode = "wb")
  unzip("data-raw/census2006/2006_mb_census.zip", exdir = "data-raw/census2006")
}

if (download) {
  download.file("http://www3.stats.govt.nz/digitalboundaries/annual/2013_Areas_Table.zip",
                destfile = "data-raw/census2013/2013_area_table.zip", mode = "wb")
  unzip("data-raw/census2013/2013_area_table.zip", exdir = "data-raw/census2013")
}

# unfortunately the 2013 MB map (to figure out urban/rural areas) is only downloadable via
# stats NZ and contains SHEDLOADS of data.
# it can be grabbed from https://datafinder.stats.govt.nz
if (download) {
  unzip("data-raw/census2013/meshblock-2013-CSV.zip", exdir = "data-raw/census2013")
  # first column contains shapefile information, so remove that first
  read.csv("data-raw/census2013/statsnzmeshblock-2013-CSV/meshblock-2013.csv", stringsAsFactors = FALSE) %>%
    select(-WKT) %>% write.csv("data-raw/census2013/meshblock-2013.csv", row.names=FALSE)
}

# read in the data
mb2013 <- read.csv("data-raw/census2013/meshblock-2013.csv", stringsAsFactors = FALSE)
concordance2013 <- read.csv("data-raw/census2013/2013_Areas_Table.txt")
concordance2006 <- read.csv("data-raw/concordance-2006.csv", stringsAsFactors = FALSE)

# mapping of categories to UR num
lookup2013 <- read.table(header=TRUE, stringsAsFactors = FALSE, text=
                          "UrbanAreaType                         UR2013_num
                        'Inland Water not in Urban Area'      NA
                        'Inlet-in TA but not in Urban Area'   NA  
                        'Inlet-not in TA'                     NA
                        'Main Urban Area'                      3
                        'Minor Urban Area'                     1                    
                        'Oceanic'                             NA
                        'Oceanic-in Region but not in TA'     NA
                        'Rural (Incl.some Off Shore Islands)' -1
                        'Rural Centre'                         0
                        'Secondary Urban Area'                 2")

lookup2006 <- read.table(header=TRUE, stringsAsFactors = FALSE, text=
                          "Urban.Rural.Profile.Classification.Category UR2006_num
                          'Area outside urban/rural profile'           NA
                          'Highly rural/remote area'                   -3  
                          'Rural area with low urban influence'        -2
                          'Rural area with moderate urban influence'   -1
                          'Rural area with high urban influence'       0                    
                          'Independent Urban Area'                     1
                          'Satellite Urban Area'                       2
                          'Main urban area'                            3")

# join everything up
mb2013 = mb2013 %>%
  left_join(concordance2013, by=c("MeshblockNumber" = "MB2013_code")) %>%
  left_join(lookup2013) %>%
  left_join(concordance2006, by=c("MB2006_code" = "mb06")) %>%
  left_join(lookup2006) %>%
  mutate(UR2013 = ifelse(UR2013_num <= 0, "Rural", "Urban"),
         UR2006 = ifelse(UR2006_num <= 0, "Rural", "Urban")) %>%
  select(MB2013 = MeshblockNumber,
         MB2006 = MB2006_code,
         UR2013_num,
         UR2006_num,
         UR2013,
         UR2006,
         DHB_code,
         DHB_label)

# ok, now join to population summaries
indiv <- read.csv("data-raw/census2013/2013-mb-dataset-Total-New-Zealand-Individual-Part-1.csv",
                        stringsAsFactors = FALSE, na.strings = c("..C", "*"))

indiv <- indiv %>% filter(grepl("^MB", Area_Code_and_Description)) %>%
  select(MB2013=Code, Pop2001 = X2001_Census_census_usually_resident_population_count.1.,
                    Pop2006 = X2006_Census_census_usually_resident_population_count.1.,
                    Pop2013 = X2013_Census_census_usually_resident_population_count.1.) %>%
  mutate(MB2013 = as.numeric(MB2013))

mb2013 <- mb2013 %>% left_join(indiv)

# create the 2006 dataset by filtering this one
mb2006 <- mb2013 %>%
  select(MB2006, UR2006_num, UR2006, DHB_code, DHB_label, Pop2001, Pop2006, Pop2013) %>%
  group_by(MB2006, UR2006_num, UR2006, DHB_code, DHB_label) %>%
  summarise(Pop2001 = sum(Pop2001),
            Pop2006 = sum(Pop2006),
            Pop2013 = sum(Pop2013)) %>% ungroup

# save this information
devtools::use_data(mb2013, overwrite=TRUE)
devtools::use_data(mb2006, overwrite=TRUE)
