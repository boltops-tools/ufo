FROM ruby:2.5.1

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --system

ADD . /app
RUN bundle install --system

EXPOSE 4567

# If you do not have a bin/web wrapper file, create one or update this command
RUN chmod a+x bin/web
CMD ["bin/web"]
