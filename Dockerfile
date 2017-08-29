FROM ruby:2.3.0

ARG APP_DIR
ENV APP_DIR $APP_DIR

ENV PDFTK_VERSION 2.02
WORKDIR /$APP_DIR

COPY . /$APP_DIR
ADD https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-${PDFTK_VERSION}-src.zip /tmp/

RUN apt-get update -qq && apt-get install bash && \
    apt-get install -y build-essential libpq-dev nodejs ruby-mysql2 && \
    apt-get install -y --no-install-recommends unzip build-essential gcj-jdk && \
    apt-get clean && \
    unzip /tmp/pdftk-${PDFTK_VERSION}-src.zip -d /tmp && \
    sed -i 's/VERSUFF=-4.6/VERSUFF=-4.9/g' /tmp/pdftk-${PDFTK_VERSION}-dist/pdftk/Makefile.Debian && \
    cd /tmp/pdftk-${PDFTK_VERSION}-dist/pdftk && \
    make -f Makefile.Debian && \
    make -f Makefile.Debian install && \
    bundle install

EXPOSE 2030

CMD rackup config.ru -p 2030 -o '0.0.0.0'
