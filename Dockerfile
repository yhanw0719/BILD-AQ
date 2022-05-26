# Dockerfile layer 2 for BILD-AQ
# this append to layer 1 (base) for quick code update


FROM ghcr.io/yhanw0719/bild-aq:base


MAINTAINER Yuhan Wang
ARG DEBIAN_FRONTEND=noninteractive
ARG TERM=dumb
ARG TZ=PST8PDT
ARG NO_COLOR=1


RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo "layer 2 bild-aq code addition " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    cd /    ;\
    echo ""


#### BILD-AQ customization here
RUN echo ''  ;\
    echo '==================================================================' ;\
    echo '' ;\
    export TERM=dumb  ;\
    cd /     ;\
    mkdir -p /opt/gitrepo/BILD-AQ ;\
    pwd      ;\
    echo ""

# add some marker of how Docker was build.
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


#ENTRYPOINT [ "/bin/bash" ]
#ENTRYPOINT [ "/usr/bin/R" ]
#ENTRYPOINT [ "Rscript", "/opt/gitrepo/BILD-AQ/main.R" ]
ENTRYPOINT [ "Rscript", "/opt/gitrepo/BILD-AQ/test.R" ]

