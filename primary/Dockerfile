# Even though Node.js 6.17 is old, we need to stay there until Dojo fixes its
# uglify implementation.
# See: https://github.com/dojo/util/pull/78

FROM        cimg/node:current
MAINTAINER  ylavoie@yveslavoie.com

ENV DEBIAN_FRONTEND=noninteractive

USER root

# Base image for CircleCI
RUN echo -e "\nAPT::Install-Recommends \"0\";\nAPT::Install-Suggests \"0\";\n" \
       >> /etc/apt/apt.conf && \
  apt-get update && apt-get -y install wget gnupg2 ssh tar gzip \
    texlive-xetex texlive-latex-recommended fonts-liberation2 \
    git cpanminus make gcc lsb-release gettext procps \
    ssmtp && \
  apt-get -qqy autoremove && \
  apt-get -qqy autoclean && \
  rm -rf /var/lib/apt/lists/*

# Install Transifex
RUN curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash ; mv tx /usr/local/bin/

user circleci
