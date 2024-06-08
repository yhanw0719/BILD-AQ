#!/usr/bin/Rscript
rm(list=ls())
#install.packages('optparse')
## R version 4.1.1
library(tidyr)
library(dplyr)
library(stringr)


##############################################
# parse cmd arguments and setup
##############################################
## set input and output paths
inputdir = '/input'
outputdir = '/output'

## parse cmd arguements
useparser = T 

if(useparser){
  
  suppressPackageStartupMessages(library("optparse"))

  # parse command-line options
  option_list <- list(
    make_option(c("--input_fname"),  dest="input_fname",  action="store", help="name of VMT input file", default="Sample_Input_CA.csv" ),
    make_option(c("--output_fname"), dest="output_fname", action="store", help="name of output file", default="Sample_Output_CA.csv" ),
    make_option(c("--emis_inputfname_btw"), dest="emis_inputfname_btw", action="store", help="name of NEI brake and tire wear emission file", default="onroad_NEI2017_LDV_btw.csv"),
    make_option(c("--emis_inputfname_nbtw"), dest="emis_inputfname_nbtw", action="store", help="name of NEI non-brake-and-tire-wear emission file", default="onroad_NEI2017_LDV_nbtw.csv"),
    make_option(c("--nbtw_adj_factor_fname"), dest="nbtw_adj_factor_fname", action="store", help="name of adjustment factor file for non-brake-and-tire-wear emission", default="adj_factor_from2017_nbtw.csv"),
    make_option(c("--nbtw_adj_factor_year"), dest="nbtw_adj_factor_year", action="store", help="output year (determines which year of adjustment factors will be applied)", default=2040),
    make_option(c("--btw_pm25_increment"), dest="btw_pm25_increment", action='store', help="incremental adjustment factor for brake and tire wear PM2.5 emissions", default=0.1),
    make_option(c("--emis_category"), dest="emis_category", action='store', help="emission category in NEI input file", default="Onroad"),
    make_option(c("--basedir"), dest="basedir", action="store", help="working dir", default="/" ),
    make_option(c("--codedir"), dest="codedir", action="store", help="base dir where R code is located", default="/opt/gitrepo/BILD-AQ/" )
  )
  opt <- parse_args(OptionParser(option_list=option_list))
  
  # read out the global variables so that subsequent programs can all use them
  input_fname = opt$input_fname
  output_fname = opt$output_fname
  emis_inputfname_btw = opt$emis_inputfname_btw
  emis_inputfname_nbtw = opt$emis_inputfname_nbtw
  nbtw_adj_factor_fname = opt$nbtw_adj_factor_fname
  nbtw_adj_factor_year = opt$nbtw_adj_factor_year
  btw_pm25_increment = opt$btw_pm25_increment
  emis_category = opt$emis_category
  basedir = opt$basedir
  codedir = opt$codedir

  # print for users to confirm
  print("input file names:")
  print(input_fname)
  print(emis_inputfname_btw)
  print(emis_inputfname_nbtw)
  print("output file name:")
  print(output_fname)
  print("adjustment factor sources:")
  print(nbtw_adj_factor_fname)
  print(paste0('btw_pm25_increment = ',btw_pm25_increment))

}



##############################################
# prepare ISRM VMT_base and VMT_scenario 
##############################################
## call process_VMT.R and it will return vmt_isrm
source(file.path(codedir,'process_VMT.R'))
vmt = vmt_isrm

## check if VMT input is correct
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



##############################################
# prepare ISRM NEI emission data 
##############################################
## call process_emission.R and it will return em_btw & em_nbtw
source(file.path(codedir,'process_emission.R'))

## crop ISRM emission input by VMT input isrm range
em_btw = filter(em_btw, isrm %in% unique(vmt$isrm))
em_nbtw = filter(em_nbtw, isrm %in% unique(vmt$isrm))

## check if emission input is correct
if (!all(c('isrm','VOC','NOx','NH3','SOx','PM25') %in% colnames(em_btw))){
  print('ERROR: btw Emission input colnames mismatch.')
} else if (!all(c('isrm','VOC','NOx','NH3','SOx','PM25') %in% colnames(em_nbtw))){
  print('ERROR: nbtw Emission input colnames mismatch.')
} else if (length(unique(em_btw$isrm)) != dim(em_btw)[1]){
  print('ERROR: btw Emission input has duplicate isrm rows.')
} else if (length(unique(em_nbtw$isrm)) != dim(em_nbtw)[1]){
  print('ERROR: nbtw Emission input has duplicate isrm rows.')
} else if (any(is.na(em_btw[,c('VOC','NOx','NH3','SOx','PM25')]))){
  print('WARNING: btw Emission input has NA values - replaced by 0.')
  em_btw[is.na(em_btw)] = 0
} else if (any(is.na(em_nbtw[,c('VOC','NOx','NH3','SOx','PM25')]))){
  print('WARNING: nbtw Emission input has NA values - replaced by 0.')
  em_nbtw[is.na(em_nbtw)] = 0
} else if (any(em_btw[,c('VOC','NOx','NH3','SOx','PM25')]<0)){
  print('WARNING: btw emission input has negative values - rows dropped.')
  em_btw = filter(em_btw, VOC>=0, NOx>=0, NH3>=0, SOx>=0, PM25>=0)
} else if (any(em_nbtw[,c('VOC','NOx','NH3','SOx','PM25')]<0)){
  print('WARNING: nbtw emission input has negative values - rows dropped.')
  em_nbtw = filter(em_nbtw, VOC>=0, NOx>=0, NH3>=0, SOx>=0, PM25>=0)
} else if (length(unique(vmt$isrm)) > length(unique(em_btw$isrm, em_nbtw$isrm))){
  print('WARNING: There are ISRM grids that have VMT but no Emissions.')
}


##############################################
# main calculation for non-brake-and-tire-wear
##############################################
## read nbtw adjustment factors by year and pollutant
adj_nbtw = read.csv(file.path(inputdir,nbtw_adj_factor_fname)) %>%
           filter(as.numeric(year) == as.numeric(nbtw_adj_factor_year))
print('nbtw adjustment factors:')
VOC_adj = adj_nbtw[adj_nbtw=='VOC','adj_factor']; print(paste0('VOC: ', VOC_adj))
NOx_adj = adj_nbtw[adj_nbtw=='NOx','adj_factor']; print(paste0('NOx: ', NOx_adj))
NH3_adj = adj_nbtw[adj_nbtw=='NH3','adj_factor']; print(paste0('NH3: ', NH3_adj))
SOx_adj = adj_nbtw[adj_nbtw=='SOx','adj_factor']; print(paste0('SOx: ', SOx_adj))
PM25_adj = adj_nbtw[adj_nbtw=='PM25','adj_factor']; print(paste0('PM25: ', PM25_adj))

## nbtw calculation
out_nbtw = merge(vmt, em_nbtw, by='isrm', all=FALSE) %>%
           mutate(VOC = VOC / VMT_base * VMT_scenario * VOC_adj - VOC,
                  NOx = NOx / VMT_base * VMT_scenario * NOx_adj - NOx,
                  NH3 = NH3 / VMT_base * VMT_scenario * NH3_adj - NH3,
                  SOx = SOx / VMT_base * VMT_scenario * SOx_adj - SOx,
                  PM25 = PM25 / VMT_base * VMT_scenario * PM25_adj - PM25)


##############################################
# main calcualtion for brake and tire wear
##############################################
## check btw adjustment assumption
print(paste0('assuming electrifying VMT will increase brake and tire wear PM2.5 by ', 
      btw_pm25_increment*100, '%'))

## btw calculation (zero except for PM2.5)
out_btw = merge(vmt, em_btw, by='isrm', all=FALSE) %>%
          mutate(PM25 = PM25 / VMT_base * (VMT_scenario-VMT_base) * btw_pm25_increment)


##############################################
# format, check and output
##############################################
# ## print stats
# print(paste0('Input VMT_base sum: ', formatC(sum(vmt$VMT_base), format = "e", digits = 2)))
# print(paste0('Output VMT_base sum: ', formatC(sum(out$VMT_base), format = "e", digits = 2)))
# print(paste0('Input VMT_scenario sum: ', formatC(sum(vmt$VMT_scenario), format = "e", digits = 2)))
# print(paste0('Output VMT_scenario dum: ', formatC(sum(out$VMT_scenario), format = "e", digits = 2)))

## extract useful columns, merge, and format
out = rbind(out_nbtw[,c('isrm','VOC','NOx','NH3','SOx','PM25')],
            out_btw[,c('isrm','VOC','NOx','NH3','SOx','PM25')]) %>%
      group_by(isrm) %>%
      summarise(VOC=sum(VOC), NOx=sum(NOx), NH3=sum(NH3), SOx=sum(SOx), PM25=sum(PM25))


## check output
if (any(is.na(out))){
  print(paste0('WARNING: Output has NA values - ', sum(apply(out[,c('VOC','NOx','NH3','SOx','PM25')], 1, anyNA)),' rows dropped'))
  out = drop_na(out, any_of(c('VOC','NOx','NH3','SOx','PM25')))
}

## write output
write.csv(out, file.path(outputdir, output_fname), row.names = FALSE)
print('---------------')
print('Done! Output written to:')
print(file.path(outputdir, output_fname))
