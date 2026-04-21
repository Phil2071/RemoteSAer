FROM rocker/r-ver:4.3.2
 
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*
 
RUN Rscript -e "install.packages('plumber', repos='https://cloud.r-project.org')"
RUN Rscript -e "install.packages('seasonal', repos='https://cloud.r-project.org')"
RUN Rscript -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"
 
RUN Rscript -e "seasonal::checkX13()"
 
WORKDIR /app
COPY api.R .
COPY run.R .
 
EXPOSE 8080
 
CMD ["Rscript", "run.R"]
 
