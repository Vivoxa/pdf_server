FROM alpine:3.7

ARG APP_DIR
ENV APP_DIR $APP_DIR

RUN mkdir /$APP_DIR

WORKDIR /$APP_DIR

COPY Gemfile Gemfile.lock . /$APP_DIR/
WORKDIR /$APP_DIR
COPY id_rsa /root/.ssh/id_rsa

#add ruby and bundler
RUN apk --update add --no-cache openssh-client bash ruby ruby-bigdecimal \
pdftk ruby-irb ruby-bundler grep less curl zlib openssh git\
&& rm -rf /var/cache/apk/* \
&& set -ex \
&& apk --update add --virtual build_deps \
build-base ruby-dev libc-dev linux-headers libxml2-dev libxslt-dev \
&& gem install -N nokogiri -- --use-system-libraries \
&& gem install -N json --version '2.1.0' -- --use-system-libraries \
&& gem install -N nio4r -- --use-system-libraries \
&& gem install -N websocket-driver -- --use-system-libraries \
&& gem install -N byebug -- --use-system-libraries \
&& gem install -N pry-byebug -- --use-system-libraries \
&& gem install -N puma -- --use-system-libraries \
&& apk del build_deps

RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts \
&& chown 0400 /root/.ssh/id_rsa

RUN bundle install --system

EXPOSE 2030

CMD bundle exec rackup config.ru -p 2030 -o '0.0.0.0'
