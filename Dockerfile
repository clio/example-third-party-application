FROM ruby:4.0.9-trixie

RUN apt-get update -qq && apt-get install -y nodejs

ENV APP_HOME /Switchboard
WORKDIR $APP_HOME
COPY . .

RUN gem install bundler:2.4.20 && bundle install

COPY ./scripts/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
COPY ./scripts/resolve_docker_host.rb /usr/bin/
RUN chmod +x /usr/bin/resolve_docker_host.rb
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3013

CMD ["rails", "server", "-p", "3013", "-b", "0.0.0.0"]
