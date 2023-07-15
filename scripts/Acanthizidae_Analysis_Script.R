library(tidyverse)

dataM <- read.csv(
  file = "Analysis/Acanthizidae_Data_MtMichael.csv",
  header = TRUE,
  sep = ",",
  dec = "."
)
dataM <- dataM[,-(11:19)]
dataM <- dataM[,-5]


dataM1 <- dataM %>% 
  pivot_longer(c(D0.10, D11.20, D21.30, D31.40, D41.50), 
                       names_to="Distance_Class", values_to="Count") %>% 
  na.omit() %>% 
  uncount(Count) %>% 
  mutate(Count=1)



dataW <- read.csv(
  file = "Analysis/Acanthizidae_Data_MtWilhelm.csv",
  header = TRUE,
  sep = ",",
  dec = "."
) 
dataW <- dataW[,-(10:25)]
dataW1 <- dataW %>% pivot_longer(c(D0.10, D11.20, D21.30, D31.40, D41.50), 
                                 names_to="Distance_Class", values_to="Count") %>% 
  na.omit() %>% 
  uncount(Count) %>% 
  mutate(Count=1)
  

