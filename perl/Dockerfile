# Perl default version
ARG perl=5.28

FROM        perldocker/perl-tester:$perl
LABEL       maintainer="ylavoie@yveslavoie.com"

# FROM resets ARG, so redeclare
ARG perl

USER root

# make Apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
    apt-get -qyy install lsb-release && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
    apt-get -y update && \
    apt-get -y install postgresql-client && \
    apt-get -qqy autoremove && \
    apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'APT::Install-Recommends "0";' 'APT::Install-Suggests "0";' \
       >> /etc/apt/apt.conf
RUN apt-get update && apt-get -y install gnupg2 \
    libauthen-sasl-perl libcgi-emulate-psgi-perl libconfig-inifiles-perl \
    libcookie-baker-perl libdbd-pg-perl libdbi-perl libdata-uuid-perl \
    libdatetime-perl libdatetime-format-strptime-perl \
    libemail-sender-perl libemail-stuffer-perl libfile-find-rule-perl \
    libhttp-headers-fast-perl libio-stringy-perl \
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
    libplack-middleware-reverseproxy-perl libscope-guard-perl \
    libsession-storage-secure-perl libstring-random-perl \
    libtemplate-perl libtext-csv-perl libtext-csv-xs-perl \
    libtext-markdown-perl libtry-tiny-perl \
    libxml-simple-perl libnamespace-autoclean-perl \
    starman starlet libhttp-parser-xs-perl \
    libtemplate-plugin-latex-perl libtex-encode-perl \
    libxml-twig-perl libopenoffice-oodoc-perl \
    libexcel-writer-xlsx-perl libspreadsheet-writeexcel-perl \
    libclass-c3-xs-perl liblocale-codes-perl \
    texlive-latex-recommended texlive-fonts-recommended \
    texlive-xetex fonts-liberation lsb-release \
    git cpanminus make gcc nodejs libperl-dev lsb-release libcarp-always-perl \
    ssh tar gzip \
    gettext procps libtap-parser-sourcehandler-pgtap-perl \
    libtest-dependencies-perl libtest-exception-perl libtest-trap-perl \
    libperl-critic-perl libmodule-cpanfile-perl libfile-util-perl \
    libclass-trigger-perl libclass-accessor-lite-perl libtest-requires-perl \
    libmodule-install-perl python3-setuptools libdist-zilla-perl \
    python3-pip python3-urllib3 \
    locales sudo jq bc gnuplot && \
  apt-get -qqy autoremove && \
  apt-get -qqy autoclean && \
  rm -rf /var/lib/apt/lists/*

RUN if [[ "$perl" > "5.25.999" ]] ; then \
    apt-get update && apt-get -y install libplack-builder-conditionals-perl \
                                         libplack-request-withencoding-perl \
                                         libversion-compare-perl \
                                         libhtml-escape-perl && \
    apt-get -qqy autoremove && \
    apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/*; \
  fi

# Install Transifex
RUN pip3 install wheel && \
    pip3 install transifex-client && \
    pip3 install --upgrade urllib3

#CircleCI++, copied from CircleCI-Node:14.9.0-buster

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# Install Docker
RUN set -ex \
  && export DOCKER_VERSION=docker-19.03.12.tgz \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

# docker compose
RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
  && chmod +x /usr/bin/docker-compose \
  && docker-compose version

RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

#CircleCI--

# Install browsers++
# Copied from https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/node/images/15.2.1-stretch/browsers/Dockerfile
#
# Install Java 11 LTS / OpenJDK 11
#
RUN if grep -q Debian /etc/os-release && grep -q stretch /etc/os-release; then \
		echo 'deb http://deb.debian.org/debian stretch-backports main' | sudo tee -a /etc/apt/sources.list.d/stretch-backports.list; \
	elif grep -q Ubuntu /etc/os-release && grep -q xenial /etc/os-release; then \
		sudo apt-get update && sudo apt-get install -y software-properties-common && \
		sudo add-apt-repository -y ppa:openjdk-r/ppa; \
	fi && \
	sudo apt-get update && sudo apt-get install -y openjdk-11-jre openjdk-11-jre-headless openjdk-11-jdk openjdk-11-jdk-headless && \
	sudo apt-get install -y bzip2 libgconf-2-4 # for extracting firefox and running chrome, respectively

# install firefox
#
RUN FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" \
  && ACTUAL_URL=$(curl -Ls -o /dev/null -w %{url_effective} $FIREFOX_URL) \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/firefox.tar.bz2 $ACTUAL_URL \
  && sudo tar -xvjf /tmp/firefox.tar.bz2 -C /opt \
  && sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox \
  && sudo apt-get install -y libgtk3.0-cil-dev libasound2 libasound2 libdbus-glib-1-2 libdbus-1-3 \
  && rm -rf /tmp/firefox.* \
  && firefox --version

# install geckodriver

RUN export GECKODRIVER_LATEST_RELEASE_URL=$(curl https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r ".assets[] | select(.name | test(\"linux64.tar.gz$\")) | .browser_download_url") \
     && curl --silent --show-error --location --fail --retry 3 --output /tmp/geckodriver_linux64.tar.gz "$GECKODRIVER_LATEST_RELEASE_URL" \
     && cd /tmp \
     && tar xf geckodriver_linux64.tar.gz \
     && rm -rf geckodriver_linux64.tar.gz \
     && sudo mv geckodriver /usr/local/bin/geckodriver \
     && sudo chmod +x /usr/local/bin/geckodriver \
     && geckodriver --version

# install chrome

RUN cd /tmp && wget -O google-chrome-stable_current_amd64.deb -t 5 "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
    && (sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get -fy install)  \
    && rm -rf google-chrome-stable_current_amd64.deb \
    && sudo sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' \
        "/opt/google/chrome/google-chrome" \
    && google-chrome --version

RUN CHROME_VERSION="$(google-chrome --version)" \
    && export CHROMEDRIVER_RELEASE="$(echo $CHROME_VERSION | sed 's/^Google Chrome //')" && export CHROMEDRIVER_RELEASE=${CHROMEDRIVER_RELEASE%%.*} \
    && CHROMEDRIVER_VERSION=$(curl --silent --show-error --location --fail --retry 4 --retry-delay 5 http://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_RELEASE}) \
    && curl --silent --show-error --location --fail --retry 4 --retry-delay 5 --output /tmp/chromedriver_linux64.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
    && cd /tmp \
    && unzip chromedriver_linux64.zip \
    && rm -rf chromedriver_linux64.zip \
    && sudo mv chromedriver /usr/local/bin/chromedriver \
    && sudo chmod +x /usr/local/bin/chromedriver \
    && chromedriver --version

# Install PhantomJS

RUN PHANTOMJS_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/phantomjs-latest.tar.bz2" \
  && sudo apt-get install libfontconfig \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/phantomjs.tar.bz2 ${PHANTOMJS_URL} \
  && tar -x -C /tmp -f /tmp/phantomjs.tar.bz2 \
  && sudo mv /tmp/phantomjs-*-linux-x86_64/bin/phantomjs /usr/local/bin \
  && rm -rf /tmp/phantomjs.tar.bz2 /tmp/phantomjs-*

# Install browsers--

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

RUN wget --quiet -O - https://deb.nodesource.com/setup_15.x | bash - && \
    apt-get install -y nodejs

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

RUN if [[ "$perl" > "5.27.999" && "$perl" < "5.29" ]] ; then \
    cd $HOME/project && \
    cpm install --local-lib-contained=$HOME/perl5 --no-test \
        B::Debug && \
    rm -rf $HOME/.cpanm; \
  fi


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
