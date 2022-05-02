#!/usr/bin/Rscript

## R version 4.1.1
library(sf) # 1.0-2
## libLinking to GEOS 3.9.0, GDAL 3.2.2, PROJ 7.2.1
## rgdal 1.5-25, rgeos 0.5-8, gprojroot 2.0.2
library(dplyr) # 1.0.7




#####################################################
# tract to isrm VMT conversion
#####################################################
## load lanemiles by isrm and tract
load(file=file.path(inputdir,paste0('network_isrm_',rgn,'.RData')))

## read tract VMT input
vmt <- read.csv(file.path(inputdir,paste0('Sample_Input_',rgn,'.csv')))

## convert tract VMT to ISRM VMT
vmt_isrm <- data.frame(network_isrm) %>%
            group_by(GEOID) %>%
            summarise(tract_geoid = as.numeric(GEOID),
                      isrm = isrm,
                      lanemiles_tractsum = sum(lanemiles),
                      lanemiles_tractpec = lanemiles/sum(lanemiles)) %>%
            merge(vmt, all=FALSE) %>%
            mutate(VMT_base = VMT_base * lanemiles_tractpec,
                   VMT_scenario = VMT_scenario * lanemiles_tractpec)  %>%
            ungroup %>% group_by(isrm) %>%
            summarise(VMT_base = sum(VMT_base),
                      VMT_scenario = sum(VMT_scenario))

## write converted VMT output
write.csv(vmt_isrm, file=file.path(inputdir,paste0('Sample_Input_ISRM_',rgn,'.csv')),
          row.names = FALSE)


## end of script
print('---------------')
print(paste0('ISRM-level VMT data processed for region: ', rgn))
print(file.path(inputdir,paste0('Sample_Input_ISRM_',rgn,'.csv')))
