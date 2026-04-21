FROM rocker/r-ver:4.3.2

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/lib/R/site-library

RUN Rscript -e "install.packages('plumber',  lib='/usr/local/lib/R/site-library', repos='https://cloud.r-project.org')"
RUN Rscript -e "install.packages('seasonal', lib='/usr/local/lib/R/site-library', repos='https://cloud.r-project.org')"
RUN Rscript -e "install.packages('jsonlite', lib='/usr/local/lib/R/site-library', repos='https://cloud.r-project.org')"

WORKDIR /app
COPY api.R .
COPY run.R .

ENV R_LIBS_USER=/usr/local/lib/R/site-library

EXPOSE 8080

CMD ["Rscript", "run.R"]
