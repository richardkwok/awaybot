FROM ruby:2.2.4

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["ruby", "bin/scheduler.rb"]
