#!/usr/bin/Rscript

## read emission input
em_btw = read.csv(file.path(inputdir,emis_inputfname_btw)) %>% rename('isrm'='ISRM')
em_nbtw = read.csv(file.path(inputdir,emis_inputfname_nbtw)) %>% rename('isrm'='ISRM')

## check emission input 
if (dim(em_btw)[1]==0){
  print('ERROR: No brake-and-tire-wear emission data - Check emission input or category')
} 
if (dim(em_nbtw)[1]==0){
  print('ERROR: No non-brake-and-tire-wear emission data - Check emission input or category')
} 

## end of script
print('---------------')
print('ISRM-level NEI emission inputs:')
print(em_input_btw)
print(em_input_nbtw)


