# Use the official Python image as the base image
FROM meldproject/meld_graph:v2.2.5

ARG FS_LICENSE
ARG MELD_LICENSE
ARG ASSET_FILE

LABEL maintainer="Onset-Lab"

RUN python scripts/new_patient_pipeline/prepare_classifier.py

WORKDIR /
RUN apt-get update && apt-get -y install git unzip dcm2niix wget dcmtk
RUN pip install dcm2bids

WORKDIR /
RUN apt-get install -y default-jre-headless
RUN wget https://github.com/nextflow-io/nextflow/releases/download/v21.10.6/nextflow-21.10.6-all
RUN mv nextflow-21.10.6-all /usr/local/bin/nextflow
RUN chmod +x /usr/local/bin/nextflow
RUN nextflow -v
RUN apt install -y rsync

COPY ${ASSET_FILE} /assets/

RUN echo "$FS_LICENSE" > /run/secrets/license.txt
RUN echo "$MELD_LICENSE" > /run/secrets/meld_license.txt

WORKDIR /