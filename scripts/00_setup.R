# import and prepare data for analyses

library(tidyverse)
library(readxl)
library(glue)

data_path <- "data/Acanthizidae_Data_Sep2020.xlsx"


# table of species codes and English and scientific names
spec_codes <- read_xlsx(data_path, sheet = "somenotes", range = "A1:C27") %>% 
  na.omit() %>% 
  magrittr::set_colnames(c("SPEC.CODE", "ENGLISH.NAME", "SCIENTIFIC.NAME")) %>% 
  separate_wider_delim(SCIENTIFIC.NAME, delim = " ", names = c("GENUS", "SPECIES"),
                       cols_remove = FALSE)
  

# habvars
hab_m <- read_xlsx(data_path, sheet = "HabChar_M") %>% 
  arrange(Place) %>% 
  mutate(MOUNTAIN = "Michael",
         PLACE.NO = dense_rank(Place)) %>% 
  mutate(PLACE.CODE = glue("MM_{PLACE.NO}_{Place}"),
         PLACE.ELEV = Place,
         PLACE.NO = NULL,
         Place = NULL) %>% 
  rename(POINT = Point,
         HEIGHT.GRASS = H_Grass,
         HEIGHT.SHRUB = H_Shrub,
         FLOWER.TREE = FlowerTree) %>% 
  dplyr::select(MOUNTAIN, PLACE.CODE, PLACE.ELEV, POINT, 
                ends_with("_avg"), 
                HEIGHT.GRASS, HEIGHT.SHRUB, FLOWER.TREE, 
                starts_with("CO_")) %>% 
  rename_with(.cols = ends_with("_avg"), ~ .x %>% str_replace("_", ".") %>% str_to_upper()) %>% 
  rename_with(.cols = starts_with("CO_"), ~ .x %>% str_replace("_", "."))
         
hab_w <- read_xlsx(data_path, sheet = "HabChar_W") %>% 
  arrange(Place) %>% 
  mutate(MOUNTAIN = "Wilhelm",
         PLACE.NO = dense_rank(Place)) %>% 
  mutate(PLACE.CODE = glue("MW_{PLACE.NO}_{Place}"),
         PLACE.ELEV = Place,
         PLACE.NO = NULL,
         Place = NULL) %>% 
  rename(POINT = Point,
         POINT.ELEV = Elevation,
         HEIGHT.GRASS = H_Grass,
         HEIGHT.SHRUB = H_Shrub,
         FLOWER.TREE = FlowerTree) %>% 
  dplyr::select(MOUNTAIN, PLACE.CODE, PLACE.ELEV, POINT, POINT.ELEV,
                ends_with("_avg"), 
                HEIGHT.GRASS, HEIGHT.SHRUB, FLOWER.TREE, 
                starts_with("CO_")) %>% 
  rename_with(.cols = ends_with("_avg"), ~ .x %>% str_replace("_", ".") %>% str_to_upper()) %>% 
  rename_with(.cols = starts_with("CO_"), ~ .x %>% str_replace("_", "."))

hab_vars <- bind_rows(hab_w, hab_m)         


data_w <- read_xlsx(data_path, sheet = "Mt Wilhelm") %>% 
  dplyr::select(Plot, Day, Point, contains("-"), Time_Part, Spec_Code) %>% 
  pivot_longer(cols = contains("-"), names_to = "DISTANCE.CAT", values_to = "DETECTIONS") %>% 
  mutate(DISTANCE.CAT = str_remove(DISTANCE.CAT, "D")) %>% 
  group_by(Plot, Day, Point, Time_Part) %>% 
  mutate(DISTANCE.CLASS = dense_rank(DISTANCE.CAT)) %>% 
  ungroup() %>% 
  na.omit() %>% 
  rename_with(~ .x %>% str_replace("_", ".") %>% str_to_upper()) %>% 
  rename(PLACE.ELEV = PLOT,
         TIME.CLASS = TIME.PART) %>% 
  mutate(MOUNTAIN = "Wilhelm",
         PLACE.ELEV = as.numeric(PLACE.ELEV))

data_m <- read_xlsx(data_path, sheet = "Mt Michael", range = cell_cols("A:S")) %>% 
  dplyr::select(Plot, Day, Point, contains("-"), Spec_Code) %>% 
  pivot_longer(cols = contains("-"), names_to = "DISTANCE.CAT", values_to = "DETECTIONS") %>% 
  mutate(DISTANCE.CAT = str_remove(DISTANCE.CAT, "D")) %>% 
  group_by(Plot, Day, Point) %>% 
  mutate(DISTANCE.CLASS = dense_rank(DISTANCE.CAT)) %>% 
  ungroup() %>% 
  na.omit() %>% 
  rename_with(~ .x %>% str_replace("_", ".") %>% str_to_upper()) %>% 
  rename(PLACE.ELEV = PLOT) %>% 
  mutate(MOUNTAIN = "Michael") %>% 
  arrange(PLACE.ELEV, DAY, POINT, DISTANCE.CLASS)

bird_data <- bind_rows(data_w, data_m)

rm(data_m, data_w, hab_m, hab_w)
