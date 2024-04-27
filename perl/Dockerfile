# Perl default version
ARG perl=5.36
ARG branches="1.8,1.9,1.10,master"

# postgresql-autodoc isn't in bullseye, so choose buster or bookworm
FROM        perl:$perl-slim-bookworm
LABEL       maintainer="ylavoie@yveslavoie.com"

# FROM resets ARG, so redeclare
ARG perl

USER root

# make Apt non-interactive
ARG DEBIAN_FRONTEND=noninteractive

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

RUN echo 'APT::Install-Recommends "0";' 'APT::Install-Suggests "0";' \
       >> /etc/apt/apt.conf
RUN apt-get update && apt-get -y install gnupg2 \
    libexpat1-dev libexpat1 \
    libpq-dev libpq5 \
    texlive-latex-recommended texlive-fonts-recommended \
    texlive-xetex fonts-liberation \
    git cpanminus make gcc libperl-dev \
    libxml2 libxml2-dev \
    ssh tar gzip graphviz \
    gettext procps && \
  apt-get -y install curl ca-certificates wget gnupg2 lsb-release && \
  mkdir -p /etc/apt/keyrings && \
  (curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor > /etc/apt/keyrings/nodesource.gpg ) && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list  && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
  apt-get -y update && \
  apt-get -y install nodejs postgresql-client

RUN npm --loglevel=error install --no-save -g webpack webpack-cli yarn

RUN apt-get -y install locales sudo jq bc gnuplot \
    docker.io docker-compose

# Including postgresql-autodoc in the above total lump didn't work;
#   splitting out did...
RUN apt-get -y install postgresql-autodoc

RUN cpanm install local::lib

#CircleCI++, copied from CircleCI-Node:14.9.0-buster

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

#CircleCI--

COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    mkdir -p /var/www && chown www-data /var/www

# Work around an aufs bug related to directory permissions:
RUN mkdir -p /tmp && \
    chmod 1777 /tmp

# Install proxies. They should be in their own image but CircleCI doesn't
# support bind mounts and proxies need access to UI

RUN apt-get update && \
    apt-get --no-install-recommends --yes install nginx lighttpd && \
    apt-get -qqy autoremove && \
    apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/*

COPY nginx*.conf /etc/nginx/
COPY nginx.sh /usr/local/bin
RUN chmod +x /usr/local/bin/nginx.sh
COPY lighttpd.sh /usr/local/bin
COPY lighttpd*.conf /etc/lighttpd/
RUN chmod +x /usr/local/bin/lighttpd.sh

## Use Mailhog/mhsendmail as sendmail
RUN \
  wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && \
  chmod +x mhsendmail_linux_amd64 && \
  mv mhsendmail_linux_amd64 /usr/local/bin/sendmail

# Remove startup warnings
RUN chown circleci:circleci -R /var/log/nginx /var/log/lighttpd

ENV HOME /home/circleci
SHELL ["/bin/bash", "-c"]

USER circleci
WORKDIR $HOME

# Build time variables
ENV NODE_PATH /usr/lib/node_modules

# Install a fresh LedgerSMB
ADD https://api.github.com/repos/ledgersmb/ledgersmb/git/refs/heads/master \
    /tmp/version.json
RUN cd && \
  git clone -b master https://github.com/ledgersmb/LedgerSMB.git project

RUN cd $HOME/project && \
    cpanm --local-lib=$HOME/perl5 -nq App::cpm inc::Module::Install && \
    perl -Mlocal::lib  >> $HOME/.profile

# FROM resets ARG, so redeclare
ARG branches

# Use App::cpm to run cpan in parallel
RUN bash -c 'for branch in ${branches//,/ }; do \
    cd $HOME/project && \
    git checkout $branch && \
    cpm install --local-lib-contained=$HOME/perl5 --no-test --show-build-log-on-failure \
      --with-develop \
      --feature=starman \
      --feature=latex-pdf-ps \
      --feature=openoffice \
      --feature=xls \
      --feature=edi; \
  done' && \
  rm -rf $HOME/.cpanm

RUN cd $HOME/project && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test --show-build-log-on-failure \
      Starman \
      URL::Encode URL::Encode::XS \
      Pod::ProjectDocs \
      DBD::Mock \
      Devel::Cover Devel::Cover::Report::Coveralls && \
  rm -rf $HOME/.cpanm

RUN if [[ "$perl" > "5.27.999" && "$perl" < "5.29" ]] ; then \
    cd $HOME/project && \
    cpm install --local-lib-contained=$HOME/perl5 --no-test --show-build-log-on-failure \
        B::Debug && \
    rm -rf $HOME/.cpanm; \
  fi

# Fix PATH
ENV PATH $HOME/perl5/perlbrew/perls/perl-$perl/bin:$PATH

# Internal Port Expose
EXPOSE 5762

# Configure outgoing mail to use host, other run time variable defaults

## sSMTP
ENV SSMTP_ROOT=ar@example.com \
    SSMTP_MAILHUB=172.17.0.1 \
    SSMTP_HOSTNAME=172.17.0.1 \
    SSMTP_FROMLINE_OVERRIDE=YES
#ENV SSMTP_USE_STARTTLS=
#ENV SSMTP_AUTH_USER=
#ENV SSMTP_AUTH_PASS=
#ENV SSMTP_AUTH_METHOD=

## PostgreSQL
ENV POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    DEFAULT_DB=lsmb

CMD ["start.sh"]
