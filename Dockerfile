# Dockerfile for creating R container
# call a shell script to install CRAN libraries
# 
# To Build container, run:
# docker build -t tin6150/bild-aq:1 -f Dockerfile . | tee LOG.Dockerfile.txt


FROM debian:bullseye

MAINTAINER TBD 
ARG DEBIAN_FRONTEND=noninteractive
ARG TERM=dumb
ARG TZ=PST8PDT
ARG NO_COLOR=1


## this stanza below should be disabled when building FROM: r-base:4.1.1
RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "This container build as os, then add r-base package " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    apt-get update ;\
    apt-get -y --quiet install r-base ;\
    cd /    ;\
    echo ""

# OS packages to support R and the libraries we need
RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "begining docker build process at " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    echo "installing packages via apt"       | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    #apt-get update ;\
    # ubuntu:   # procps provides uptime cmd
    apt-get -y --quiet install git file wget gzip bash less vim procps ;\
    apt-get -y --quiet install units libudunits2-dev curl r-cran-rcurl libcurl4 libcurl4-openssl-dev libssl-dev r-cran-httr  r-cran-xml r-cran-xml2 libxml2 rio  java-common javacc javacc4  openjdk-8-jre-headless ;\
    apt-get -y --quiet install openjdk-14-jre-headless   ;\
    # gdal cran install fails, cuz no longer libgdal26, but now libgdal28
    # apt-file search gdal-config
    apt-get -y --quiet install gdal-bin gdal-data libgdal-dev  libgdal28  ;\
    apt-get -y --quiet install r-cran-rgdal  ;\
    apt-get -y --quiet install libgeos-dev   ;\
    # default-jdk is what provide javac !   # -version = 11.0.6
    # ref: https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-18-04
    # update-alternatives --config java --skip-auto # not needed, but could run interactively to change jdk
    apt-get -y --quiet install default-jdk r-cran-rjava  ;\
    R CMD javareconf  ;\
    # debian calls it libnode-dev (ubuntu call it libv8-dev?)
    apt-get -y --quiet install libnode-dev libv8-dev ;\
    cd /     ;\
    apt-get -y --quiet install apt-file ;\
    ##?? apt-file update ;\
    cd /    ;\
    echo ""

# generic CRAN libraries used in Atlas
RUN echo ''  ;\
    cd   /   ;\
    echo '==================================================================' ;\
    echo '==================================================================' ;\
    echo '==================================================================' ;\
    echo "installing packages cran packages" | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a      _TOP_DIR_OF_CONTAINER_                        ;\
    echo '==================================================================' ;\
    echo '==================================================================' ;\
    echo '==================================================================' ;\
    echo '' ;\
    export TERM=dumb  ;\
    # initialization1.R
    Rscript --quiet --no-readline --slave -e 'install.packages("ggplot2",    repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("maps",    repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("dplyr",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("sf",  repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("fields",  repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("Imap",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("raster",  repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("readxl",    repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("ncdf4",   repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("rgdal", repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("ggmap",   repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("lawn",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("sp",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("shapefiles",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("tmap",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("spdplyr",     repos = "http://cran.us.r-project.org")'    ;\
    # initialization2.R
    Rscript --quiet --no-readline --slave -e 'install.packages("MASS",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("reshape2",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("cowplot",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("corrplot",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("RColorBrewer",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("fmsb",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("ggmap",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("tictoc",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("stargazer",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("psych",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("GPArotation",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("cluster",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("factoextra",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("DandEFA",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("xtrable",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("psychTools",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("aCRM",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("clusterCrit",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("data.table",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("tigris",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("DAAG",     repos = "http://cran.us.r-project.org")'    ;\
    # initialization3.R
    Rscript --quiet --no-readline --slave -e 'install.packages("RSQLite",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("rgeos",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("gpclib",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("utils",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("plyr",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("maptools",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("datamart",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("dismo",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("openair",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("broom",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("gridExtra",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("foreach",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("doParallel",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("sandwich",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("lmtest",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("cvTools",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("timeDate",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("lubridate",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("zoo",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("stringr",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("stringi",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("chron",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("proj4",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("akima",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("RColorBrewer",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("directlabels",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("FactoMineR",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("rstudioapi",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("iterators",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("doSNOW",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("Hmisc",     repos = "http://cran.us.r-project.org")'    ;\

    # from library() calls
    Rscript --quiet --no-readline --slave -e 'install.packages(c("aCRM", "akima", "broom", "cluster", "clusterCrit", "corrplot", "DandEFA", "datamart", "data.table", "directlabels", "dismo", "dplyr", "factoextra", "FactoMineR", "fields", "fmsb", "gdata", "ggmap", "ggplot2", "ggthemes", "gpclib", "gridExtra", "Hmisc", "lubridate", "maps", "maptools", "ncdf", "ncdf4", "openair", "openxlsx", "proj4", "psych", "psychTools", "raster", "RColorBrewer", "readxl", "reshape2", "rgdal", "rgeos", "rJava", "rstudioapi", "scales", "sf", "sp", "stargazer", "stringi", "stringr", "tibble", "tictoc", "tidyr", "tigris", "timeDate", "tmap", "units", "utils", "xlsx", "xtable", "zoo"),     repos = "http://cran.us.r-project.org")'    ;\
    # next one added 2021.0829 for Ling's parallel foreach SNOW cluster
    Rscript --quiet --no-readline --slave -e 'install.packages(c( "ster", "sp", "rgeos", "geosphere", "doParallel", "iterators", "foreach", "rgdal", "doSNOW", "openxlsx"),     repos = "http://cran.us.r-project.org")'    ;\

    echo ''  ;\
    Rscript --quiet --no-readline --slave -e 'install.packages("tidycensus",     repos = "http://cran.us.r-project.org")'    ;\
    Rscript --quiet --no-readline --slave -e 'install.packages(c("psych", "ggpairs", "tableone"),     repos = "http://cran.us.r-project.org")'    ;\
    # https://www.rdocumentation.org/packages/pacman/versions/0.5.1
    # pacman provides wrapper function like p_load() to install package if needed, then load the library // R 3.5+, seems in R 4.0.3 now ;\
    Rscript --quiet --no-readline --slave -e 'install.packages( "pacman" )'       ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( utils, foreign, pastecs, mlogit, graphics, VGAM, aod, plotrix, Zelig, Zelig, vctrs, maxLik, plyr, MASS, ordinal, mltest, haven, stargazer, stringr, tidyverse ) }' ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( gWidgets2, gWidgets2tcltk, miscTools, lmtest, dplyr, BiocManager ) }' ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( ggplot2, scales ) }' ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( snow, foreach, parallel, doParallel, tictoc ) }' ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( apollo ) }' ;\
    Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load( optparse, argparse, stats ) }' ;\
    #Rscript --quiet --no-readline --slave -e 'p_load( )' ;\
    #Rscript --quiet --no-readline --slave -e '{ library(pacman); p_load(  ) }' ;\

    dpkg --list | tee dpkg--list.txt   ;\
    Rscript --quiet --no-readline --slave -e 'library()'   | sort | tee R_library_list.out.5.txt  ;\
    ls /usr/local/lib/R/site-library | sort | tee R-site-lib-ls.out.5.txt   ;\
    echo "Done installing packages cran packages - part 5" | tee -a _TOP_DIR_OF_CONTAINER_     ;\
    date | tee -a      _TOP_DIR_OF_CONTAINER_   ;\
    cd /     ;\
    pwd  ;\
    echo ""


#### BILD-AQ customization here
RUN echo ''  ;\
    echo '==================================================================' ;\
    echo '' ;\
    export TERM=dumb  ;\
    cd /     ;\
    mkdir -p /opt/gitrepo/BILD-AQ ;\
    # tmp for test with Ling's tmp code
    mkdir -p /global/data/transportation/ATLAS/static/urbansim ;\
    mkdir -p /global/data/transportation/ATLAS/static/urbansim/model_application ;\
    pwd      ;\
    echo ""

# add some marker of how Docker was build.
##COPY Dockerfile* /opt/gitrepo/container/
##COPY . /
COPY . /opt/gitrepo/BILD-AQ

RUN  cd / \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && echo  "--------" >> _TOP_DIR_OF_CONTAINER_   \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_  


ENV TZ America/Los_Angeles
# ENV TZ likely changed/overwritten by container's /etc/csh.cshrc


# below is from bash -x /usr/bin/R
ENV LD_LIBRARY_PATH=/usr/lib/R/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/default-java/lib/server
ENV R_LD_LIBRARY_PATH=/usr/lib/R/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/default-java/lib/server
ENV R_binary=/usr/lib/R/bin/exec/
ENV R_LIBS=/usr/local/lib/R/site-library:/usr/lib/R/site-library:/usr/lib/R/library


ENTRYPOINT [ "/bin/bash" ]
#ENTRYPOINT [ "/usr/bin/R" ]
#ENTRYPOINT [ "Rscript", "/opt/gitrepo/BILD-AQ/main.R" ]


