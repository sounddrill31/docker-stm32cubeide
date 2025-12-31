ARG IMAGE=ubuntu:24.04

# Use base image as extractor for the zip file
FROM ${IMAGE} AS base

RUN apt-get -y update && \
    apt-get -y install zip wget

RUN wget 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x869689FE09306074' \
  -O '/etc/apt/trusted.gpg.d/phd-chromium.asc' && \
  echo "deb https://freeshell.de/phd/chromium/$(lsb_release -sc) /" \
  | tee /etc/apt/sources.list.d/phd-chromium.list && \
  apt-get -y update && \
  apt-get -y install chromium

COPY st-stm32cubeide_1.19.0_25607_20250703_0907_amd64.deb_bundle.sh.zip /tmp/stm32cubeide-installer.sh.zip

# Unzip STM32 Cube IDE and delete zip file
RUN unzip -p /tmp/stm32cubeide-installer.sh.zip > /tmp/stm32cubeide-installer.sh && rm /tmp/stm32cubeide-installer.sh.zip

# Set environment variables and labels in the last tag
FROM ${IMAGE}
ENV STM32CUBEIDE_VERSION=1.19.0
ENV DEBIAN_FRONTEND=noninteractive
ENV LICENSE_ALREADY_ACCEPTED=1
ENV TZ=Etc/UTC
ENV PATH="${PATH}:/opt/st/stm32cubeide_${STM32CUBEIDE_VERSION}"
ENV DISPLAY=:0

LABEL org.opencontainers.image.authors="Xander Hendriks <xander.hendriks@nx-solutions.com>"

# Install dependencies
RUN apt-get -y update && \
    apt-get -y install gcc g++ x11-apps libswt-gtk-4-java

COPY --from=base /tmp/stm32cubeide-installer.sh /tmp

# Install STM32 Cube IDE and delete installer
RUN chmod +x /tmp/stm32cubeide-installer.sh && \
    /tmp/stm32cubeide-installer.sh && \
    rm /tmp/stm32cubeide-installer.sh