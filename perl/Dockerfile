# Perl default version
ARG perl=5.28

FROM        perldocker/perl-tester:$perl
LABEL       maintainer="ylavoie@yveslavoie.com"

# FROM resets ARG, so redeclare
ARG perl

USER root

# make Apt non-interactive
ARG DEBIAN_FRONTEND=noninteractive

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

RUN echo 'APT::Install-Recommends "0";' 'APT::Install-Suggests "0";' \
       >> /etc/apt/apt.conf && \
  apt-get update && \
  apt-get -y install curl ca-certificates wget gnupg2 && \
  curl -L https://deb.nodesource.com/setup_16.x -o ./setup && \
  bash ./setup && rm ./setup && \
  apt-get -y update && \
  apt-get -y upgrade && \
  apt-get -y install \
    gnupg \
    libauthen-sasl-perl libcgi-emulate-psgi-perl libconfig-inifiles-perl \
    libcookie-baker-perl libdbd-pg-perl libdbi-perl libdata-uuid-perl \
    libdatetime-perl libdatetime-format-strptime-perl \
    libemail-sender-perl libemail-stuffer-perl libfile-find-rule-perl \
    libhtml-escape-perl libhttp-headers-fast-perl libio-stringy-perl \
    libjson-maybexs-perl libcpanel-json-xs-perl libjson-pp-perl \
    liblist-moreutils-perl \
    liblocale-maketext-perl liblocale-maketext-lexicon-perl \
    liblog-log4perl-perl libmime-types-perl \
    libmath-bigint-gmp-perl libmodule-runtime-perl libmoo-perl \
    libmoox-types-mooselike-perl libmoose-perl \
    libmoosex-nonmoose-perl libnumber-format-perl \
    libpgobject-perl libpgobject-simple-perl libpgobject-simple-role-perl \
    libpgobject-type-bigfloat-perl libpgobject-type-datetime-perl \
    libpgobject-type-bytestring-perl libpgobject-util-dbmethod-perl \
    libpgobject-util-dbadmin-perl libplack-perl \
    libplack-builder-conditionals-perl libplack-middleware-reverseproxy-perl \
    libplack-request-withencoding-perl libscope-guard-perl \
    libsession-storage-secure-perl libstring-random-perl \
    libtemplate-perl libtext-csv-perl libtext-csv-xs-perl \
    libtext-markdown-perl libtry-tiny-perl libversion-compare-perl \
    libxml-simple-perl libnamespace-autoclean-perl \
    starman starlet libhttp-parser-xs-perl \
    libtemplate-plugin-latex-perl libtex-encode-perl \
    libxml-twig-perl libopenoffice-oodoc-perl \
    libexcel-writer-xlsx-perl libspreadsheet-writeexcel-perl \
    libclass-c3-xs-perl liblocale-codes-perl \
    texlive-latex-recommended texlive-fonts-recommended \
    texlive-xetex fonts-liberation \
    lsb-release \
    git cpanminus make gcc nodejs libperl-dev lsb-release libcarp-always-perl \
    ssh tar gzip \
    gettext procps libtap-parser-sourcehandler-pgtap-perl \
    libtest-dependencies-perl libtest-exception-perl libtest-trap-perl \
    libperl-critic-perl libmodule-cpanfile-perl libfile-util-perl \
    libclass-trigger-perl libclass-accessor-lite-perl libtest-requires-perl \
    libmodule-install-perl python3-setuptools libdist-zilla-perl \
    python3-pip python3-urllib3 \
    locales sudo jq bc gnuplot \
    docker.io docker-compose && \
  pip3 install transifex-client && \
  pip3 install --upgrade urllib3 && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
  apt-get -y update && \
  apt-get -y install postgresql-client && \
  apt-get -qqy autoremove && \
  apt-get -qqy autoclean && \
  rm -rf /var/lib/apt/lists/*

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

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
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

# Use App::cpm to run cpan in parallel
RUN cd $HOME/project && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
    --with-develop \
    --feature=starman \
    --feature=latex-pdf-ps \
    --feature=openoffice \
    --feature=xls \
    --feature=edi && \
  git checkout 1.8 && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
    --with-develop \
    --feature=starman \
    --feature=latex-pdf-ps \
    --feature=openoffice \
    --feature=xls \
    --feature=edi && \
  git checkout 1.7 && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
    --with-develop \
    --feature=starman \
    --feature=latex-pdf-ps \
    --feature=openoffice \
    --feature=xls \
    --feature=edi && \
  git checkout 1.6 && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
    --with-develop \
    --feature=starman \
    --feature=latex-pdf-ps \
    --feature=openoffice \
    --feature=xls \
    --feature=edi && \
  git checkout 1.5 && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
    --with-develop \
    --feature=starman \
    --feature=latex-pdf-ps \
    --feature=openoffice \
    --feature=edi && \
  rm -rf $HOME/.cpanm

RUN cd $HOME/project && \
  cpm install --local-lib-contained=$HOME/perl5 --no-test \
      Starman \
      URL::Encode URL::Encode::XS \
      Pod::ProjectDocs \
      Devel::Cover Devel::Cover::Report::Coveralls \
      Dist::Zilla \
      Locale::Country && \
  rm -rf $HOME/.cpanm

RUN npm --loglevel=error install --save-dev webpack webpack-cli && \
    npm install && \
    npm dedupe

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
