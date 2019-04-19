FROM ruby:2.6.2

RUN apt-get update && apt-get install -y
RUN apt-get -y install sqlite3 libsqlite3-dev
RUN apt-get -y install curl libcurl3 libcurl3-gnutls libcurl4-openssl-dev

ENV APP_HOME /app
ENV HOME /root

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/

RUN gem update --system
RUN gem install bundler
RUN bundle install

COPY . $APP_HOME

CMD ["foreman", "start"]
