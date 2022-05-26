#!/usr/bin/Rscript
rm(list=ls())

## R version 4.1.1
# install.packages(c('sf','geojsonsf'))
#library(sf)
library(geojsonsf)
library(dplyr)




##############################################
# set up
##############################################
# setwd('G:/Shared drives/CMAQ_Adjoint/Yuhan/Fall_2021/Task5_InMAP/BILD-AQ/')

## set input and output paths
inputdir = './input'
outputdir = './output'

## set emission category and region of interest
category = "Gas LD Veh."
rgn = 'CA'

## set fnames if ISRM vmt/emission data already processed
## otherwise process_VMT.R / process_emissions.R will be called
vmt_input_fname = NA
em_input_fname = NA

## set output fname if needed, otherwise "Sample_Output_ISRM_{$rgn}_{$category}.csv"
output_fname = NA


##############################################
# prepare ISRM VMT_base and VMT_scenario 
##############################################
if (!is.na(vmt_input_fname)) {
  
  ## if ISRM VMT data already processed, read directly
  vmt = read.csv(file.path(inputdir, vmt_input_fname))
  print('---------------')
  print(paste0('ISRM-level VMT data read from:'))
  print(file.path(inputdir, vmt_input_fname))
  
} else {
  
  ## if not procrssed yet, vmt_input_fname = NA, call preprocessor
  ## Inputs required:
  ##   1) network_isrm_{$rgn}.RData 
  ##   -> var network_isrm, cols c("lanemiles",'isrm','GEOID')
  ##   2) Sample_Input_{$rgn}.csv
  ##   -> cols c("tract_geoid",'VMT_base','VMT_scenario')
  source('process_VMT.R')
  vmt = read.csv(file.path(inputdir,paste0('Sample_Input_ISRM_',rgn,'.csv')))

}


##############################################
# prepare ISRM NEI emission data 
##############################################
if (!is.na(em_input_fname)){
  
  ## if ISRM emission data already processed, read directly
  em = read.csv(file.path(inputdir, em_input_fname))
  print('---------------')
  print(paste0('ISRM-level Emission data read from:'))
  print(file.path(inputdir, em_input_fname))
  
} else {
  
  ## if category is among 14 processed by InMAP group, read directly
  categories_processed = c("Ag.", "Coal Elec.", "Const.",
                           "Cooking", "Diesel HD Veh.", "Gas LD Veh.",
                           "Industrial", "Misc.", "Non-coal Elec",
                           "Offroad", "Res. Gas", "Res. Other",
                           "Res. Wood", "Road Dst.")
  if (category %in% categories_processed){
    em = read.csv(file.path(inputdir,'nei_isrm_summary_state_new.csv')) %>%
         filter(sector==category)
    print('---------------')
    print(paste0('ISRM-level ',category,' Emission data read from:'))
    print(file.path(inputdir, 'nei_isrm_summary_state_new.csv'))
    
    
  } else {
    
  ## if not processed, call preprocessor
    source('process_emission.R')
    em = read.csv(file.path(inputdir,paste0('nei_isrm_summary_',category,'.csv')))
    
  }
  
}


##############################################
# format and check input data
##############################################
## check ISRM VMT input
if (!all(c('isrm','VMT_base','VMT_scenario') %in% colnames(vmt))){
  print('ERROR: ISRM VMT input colnames mismatch.')
  
} else if (length(unique(vmt$isrm)) != dim(vmt)[1]){
  print('ERROR: ISRM VMT input has duplicate isrm rows.')
  
} else if (any(is.na(vmt))){
  print('WARNING: ISRM VMT input has NA values - replaced by 0.')
  vmt[is.na(vmt)] = 0
  
} else if (any(vmt$VMT_base<0, vmt$VMT_scenario<0)){
  print('WARNING: ISRM VMT input has negative values - rows dropped.')
  vmt = filter(vmt, VMT_base >= 0, VMT_scenario >= 0)
}


## crop ISRM emission input by VMT input isrm range
em = filter(em, isrm %in% unique(vmt$isrm))

## check ISRM emission input 
if (!all(c('isrm','VOC','NOx','NH3','SOx','PM25') %in% colnames(em))){
  print('ERROR: ISRM Emission input colnames mismatch.')
  
} else if (length(unique(em$isrm)) != dim(em)[1]){
  print('ERROR: ISRM Emission input has duplicate isrm rows.')
  
} else if (any(is.na(em))){
  print('WARNING: ISRM Emission input has NA values - replaced by 0.')
  em[is.na(em)] = 0

} else if (any(em[,c('VOC','NOx','NH3','SOx','PM25')]<0)){
  print('WARNING: ISRM VMT input has negative values - rows dropped.')
  em = filter(em, VOC>=0, NOx>=0, NH3>=0, SOx>=0, PM25>=0)

} else if (length(unique(vmt$isrm)) > dim(em)[1]){
  print('WARNING: There are ISRM grids has VMT but no Emissions.')
  
}



##############################################
# main calcualtion
##############################################
out = merge(vmt, em, by='isrm', all=FALSE) %>%
      mutate(VOC_scenario = VOC / VMT_base * VMT_scenario,
             NOx_scenario = NOx / VMT_base * VMT_scenario,
             NH3_scenario = NH3 / VMT_base * VMT_scenario,
             SOx_scenario = SOx / VMT_base * VMT_scenario,
             PM25_scenario = PM25 / VMT_base * VMT_scenario)



##############################################
# format, check and output
##############################################
## extrat useful columns only
out = out[,c('sector','isrm','VOC','VOC_scenario','NOx','NOx_scenario',
             'NH3','NH3_scenario','SOx','SOx_scenario','PM25','PM25_scenario')]

## check output
if (any(is.na(out))){
  print(paste0('WARNING: Output has NA values - ', sum(apply(out, 1, anyNA)),' rows dropped'))
  out = drop_na(out)
}
print(paste0('Input VMT_base sum: ', formatC(sum(vmt$VMT_base), format = "e", digits = 2)))
print(paste0('Output VMT_base dum: ', formatC(sum(out$VMT_base), format = "e", digits = 2)))
print(paste0('Input VMT_scenario sum: ', formatC(sum(vmt$VMT_scenario), format = "e", digits = 2)))
print(paste0('Output VMT_scenario dum: ', formatC(sum(out$VMT_scenario), format = "e", digits = 2)))

## write output
if (!is.na(output_fname)){
  write.csv(out, file.path(outputdir, output_fname), row.names = FALSE)
  print('---------------')
  print('Done! Output written to:')
  print(file.path(outputdir, output_fname))
  
  
} else {
  write.csv(out, file.path(outputdir,paste0('Sample_Output_ISRM_',rgn,'_',
                                            str_replace_all(category,' ','_'),'.csv')),
            row.names = FALSE)
  print('---------------')
  print('Done! Output written to:')
  print(file.path(outputdir,paste0('Sample_Output_ISRM_',rgn,'_',
                                   str_replace_all(category,' ','_'),'.csv')))
  
}




