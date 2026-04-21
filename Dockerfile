FROM rocker/r-ver:4.3.2

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('plumber',  lib=.Library, repos='https://cloud.r-project.org')"
RUN R -e "install.packages('seasonal', lib=.Library, repos='https://cloud.r-project.org')"
RUN R -e "install.packages('jsonlite', lib=.Library, repos='https://cloud.r-project.org')"

WORKDIR /app
COPY api.R .
COPY run.R .

EXPOSE 8080

CMD ["Rscript", "run.R"]
