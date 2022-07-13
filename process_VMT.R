#!/usr/bin/Rscript

## R version 4.1.1
library(dplyr) # 1.0.7


## read tract VMT input
vmt <- read.csv(file.path(inputdir, input_fname))

## find out states in vmt input
state_codes = unique(floor(as.numeric(vmt$tract_geoid)/1e9))
state_map = data.frame(
              code=c(1:2,4:6,8:10,
                     12:13,15:20,
                     21:28,
                     29:36,
                     37:42,44:45,
                     46:51,53:54,
                     55:56,60,66,69,72,78),
              name=c('AL','AK','AZ','AR','CA','CO','CT','DE',
                     'FL','GA','HI','ID','IL','IN','IA','KS',
                     'KY','LA','ME','MD','MA','MI','MN','MS',
                     'MO','MT','NE','NV','NH','NJ','NM','NY',
                     'NC','ND','OH','OK','OR','PA','RI','SC',
                     'SD','TN','TX','UT','VT','VA','WA','WV',
                     'WI','WY','AS','GU','MP','PR','VI'))
state_names = state_map[state_map$code %in% state_codes,'name']

## load Rdata of those states
network_isrm_all = NULL
for (state_name in state_names){
  load(file=file.path(inputdir,paste0('network_isrm_',state_name,'.RData')))
  network_isrm_all = rbind(network_isrm_all, network_isrm)
}
network_isrm = network_isrm_all[,c('GEOID','isrm','lanemiles')]

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


## end of script
print('---------------')
print(paste0('ISRM-level VMT data processed for input tracts in ', state_names))
