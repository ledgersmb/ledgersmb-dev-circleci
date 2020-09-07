FROM        ledgersmb/ledgersmb_circleci-primary
MAINTAINER  ylavoie@yveslavoie.com

# Perl version
ARG perl=5.28.2

ENV HOME /home/circleci
SHELL ["/bin/bash", "-c"]

USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qyy install perlbrew && \
    apt-get -qqy autoremove && \
    apt-get -qqy autoclean && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
    DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql-client && \
    apt-get -qqy autoremove && \
    apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/*

USER circleci
WORKDIR $HOME

# Build time variables
ENV NODE_PATH /usr/lib/node_modules

# Install a fresh LedgerSMB
ADD https://api.github.com/repos/ledgersmb/ledgersmb/git/refs/heads/master \
    /tmp/version.json
RUN cd && \
  git clone -b master https://github.com/ledgersmb/LedgerSMB.git project

# install the standalone perlbrew
RUN perlbrew init --shell=/bin/bash && \
    source ~/perl5/perlbrew/etc/bashrc && \
    perlbrew install-patchperl && \
    perlbrew install --notest -j 4 $perl && \
    perlbrew use perl-$perl && \
    perlbrew install-cpanm && \
    echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.profile && \
    cpanm --notest inc::Module::Install Starman && \
    rm -rf ~/.cpanm && \
    rm -rf ~/perl5/perlbrew/build/

RUN cd ~/project && \
  source ~/perl5/perlbrew/etc/bashrc && \
  perlbrew use perl-$perl && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  git checkout 1.8 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  git checkout 1.7 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  git checkout 1.6 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  git checkout 1.5 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  rm -rf ~/.cpanm

RUN cd ~/project && \
  source ~/perl5/perlbrew/etc/bashrc && \
  perlbrew use perl-$perl && \
  cpanm --quiet --notest Dancer2 Dancer2::Session::Cookie \
      Dancer2::Plugin::Auth::Extensible \
      URL::Encode URL::Encode::XS \
      Pod::ProjectDocs \
      Devel::Cover Devel::Cover::Report::Coveralls \
      Dist::Zilla \
      Locale::Country && \
  rm -rf ~/.cpanm

USER root

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

COPY start.sh /usr/local/bin/start.sh
COPY update_ssmtp.sh /usr/local/bin/update_ssmtp.sh

RUN chown circleci /etc/ssmtp /etc/ssmtp/ssmtp.conf && \
    chmod +x /usr/local/bin/update_ssmtp.sh /usr/local/bin/start.sh && \
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

USER circleci

# To make sure that all the proper perl version is always used
RUN echo "perlbrew use perl-$perl" >> .profile

# We don't need to install it globally after brewing Perl here
RUN npm install uglify-js@">=2.0 <3.0"
RUN npm --loglevel=error install --save-dev webpack webpack-cli && \
    npm install && \
    npm dedupe

# Fix PATH
ENV PATH $HOME/perl5/perlbrew/perls/perl-$perl/bin:$PATH

# Internal Port Expose
EXPOSE 5762

CMD ["start.sh"]
