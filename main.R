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
inputdir = './input'
outputdir = './output'

## parse cmd arguements
useparser = T 

if(useparser){
  
  suppressPackageStartupMessages(library("optparse"))

  # parse command-line options
  option_list <- list(
    make_option(c("--input_fname"),  dest="input_fname",  action="store", help="name of VMT input file", default="Sample_Input.csv" ),
    make_option(c("--output_fname"), dest="output_fname", action="store", help="name of output file", default="Sample_Output.csv" ),
    make_option(c("--emis_inputfname"), dest="emis_inputfname", action="store", help="name of NEI input file", default="nei_isrm_summary_state_new.csv"),
    make_option(c("--emis_category"), dest="emis_category", action='store', help="emission category in NEI input file", default="Gas LD Veh."),
    make_option(c("--basedir"), dest="basedir", action="store", help="working dir", default="/" ),
    make_option(c("--codedir"), dest="codedir", action="store", help="base dir where R code is located", default="/opt/gitrepo/BILD-AQ/" ),
    make_option(c("--PMfactor"), dest="PMfactor", action="store", help="% PM25 change = PMfactor * % VMT change", default=0)
  )
  opt <- parse_args(OptionParser(option_list=option_list))
  
  # read out the global variables so that subsequent programs can all use them
  input_fname = opt$input_fname
  output_fname = opt$output_fname
  emis_inputfname = opt$emis_inputfname
  emis_category = opt$emis_category
  basedir = opt$basedir
  codedir = opt$codedir
  PMfactor = opt$PMfactor

  # print for users to confirm
  print("input file names:")
  print(input_fname)
  print(emis_inputfname)
  print("output file name:")
  print(output_fname)
  print("PM 2.5 factor:")
  print(PMfactor)

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
## call process_emission.R and it will return em
source(file.path(codedir,'process_emission.R'))

## crop ISRM emission input by VMT input isrm range
em = filter(em, isrm %in% unique(vmt$isrm))

## check if emission input is correct
if (!all(c('isrm','VOC','NOx','NH3','SOx','PM25') %in% colnames(em))){
  print('ERROR: ISRM Emission input colnames mismatch.')
} else if (length(unique(em$isrm)) != dim(em)[1]){
  print('ERROR: ISRM Emission input has duplicate isrm rows.')
} else if (any(is.na(em[,c('VOC','NOx','NH3','SOx','PM25')]))){
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
out = merge(vmt, em, by='isrm', all=FALSE)  %>%
      mutate(VOC = VOC / VMT_base * VMT_scenario - VOC,
             NOx = NOx / VMT_base * VMT_scenario - NOx,
             NH3 = NH3 / VMT_base * VMT_scenario - NH3,
             SOx = SOx / VMT_base * VMT_scenario - SOx,
             PM25 = (PM25 / VMT_base * VMT_scenario - PM25)*PMfactor)



##############################################
# format, check and output
##############################################
# ## print stats
# print(paste0('Input VMT_base sum: ', formatC(sum(vmt$VMT_base), format = "e", digits = 2)))
# print(paste0('Output VMT_base sum: ', formatC(sum(out$VMT_base), format = "e", digits = 2)))
# print(paste0('Input VMT_scenario sum: ', formatC(sum(vmt$VMT_scenario), format = "e", digits = 2)))
# print(paste0('Output VMT_scenario dum: ', formatC(sum(out$VMT_scenario), format = "e", digits = 2)))

## extrat useful columns only
out = out[,c('isrm','VOC','NOx','NH3','SOx','PM25',
             'Height','Diam','Temp','Velocity','STATEFP','x','y')]

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
