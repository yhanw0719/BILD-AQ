#!/usr/bin/Rscript
library(sf)
inputdir = './input'
outputdir = './output'

## end of script
print('---------------')
print(paste0('ISRM-level NEI emission data processed for category: ', category))
print(file.path(inputdir,paste0('nei_isrm_summary_',category,'.csv')))





## Backup Scrpt
# 
# 
# ## 22 sectors
# sectors = c('afdust','ag','agfire','cmv','nonpt','nonroad','np_oilgas',
#             'onroad','onroad_can','onroad_mex','othafdust','othar','othpt',
#             'pt_oilgas','ptagfire','ptegu','ptfire_f','ptfire_mxca',
#             'ptfire_s','ptnonipm','rail','rwc')
# 
# 
# full_list = readxl::read_xlsx("G:/Shared drives/CMAQ_Adjoint/Yuhan/Fall_2021/Task5_InMAP/Data/revised_onroad_sccs112414.xlsx",
#                              sheet='Onroad SCC Revisions', skip=1)
# avail_list = NULL
# for (sector in sectors){
#   # shp = sf::st_read(paste0(inputdir,'/2014_nei_isrm_emissions/',sector,'.shp'))
#   # save(shp, file=paste0(inputdir,'/2014_nei_isrm_emissions_RData/',sector,'.RData'))
#   load(paste0(inputdir,'/2014_nei_isrm_emissions_RData/',sector,'.RData'))
#   avail_list = c(avail_list, unique(shp$SCC))
# }
# avail_list = unique(avail_list) ## 7053 -> 5687 SCC
# 
# write.csv(filter(full_list, SCC %in% avail_list), 
#           file = paste0("G:/Shared drives/CMAQ_Adjoint/Yuhan/Fall_2021/Task5_InMAP/Data/avail_SCC_list.csv"),
#           row.names = FALSE)
