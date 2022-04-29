FROM rocker/geospatial:4.1.0

# add tidyverse and devtools
RUN /rocker_scripts/install_tidyverse.sh
# add text publishing related features
RUN /rocker_scripts/install_verse.sh
# add shiny
RUN /rocker_scripts/install_shiny_server.sh

# use renv to install R packages
ENV RENV_VERSION 0.15.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /project
COPY renv.lock renv.lock
RUN R -e 'renv::restore()'

CMD ["/init"]
