#!/usr/bin/Rscript

## read emission input
em_input = read.csv(file.path(inputdir,emis_inputfname))
em_input$sector = tolower(em_input$sector)

## filter by category
em = filter(em_input, sector==tolower(emis_category))

## check emission input 
if (dim(em)[1]==0){
  print('ERROR: No emission data - Check emission input or category')
} 

## end of script
print('---------------')
print('ISRM-level NEI emission inputs ready')
#print(emis_inputfname)
#print(emis_category)

