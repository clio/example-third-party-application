FROM ruby:2.6.8

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV APP_HOME /Switchboard
WORKDIR $APP_HOME
COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN gem install bundler:2.2.21 && bundle install

COPY ./scripts/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
COPY ./scripts/resolve_docker_host.rb /usr/bin/
RUN chmod +x /usr/bin/resolve_docker_host.rb
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3013

CMD ["rails", "server", "-b", "0.0.0.0"]
