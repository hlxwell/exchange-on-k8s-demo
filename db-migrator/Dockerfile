FROM ruby:2.5.1
ENV LC_ALL C.UTF-8
# Specify timezone
ENV TZ Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Home dir
ENV APP_HOME /app
RUN mkdir -p $APP_HOME
ENV RACK_ENV production
# Bundler
RUN gem install bundler
ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN cd $APP_HOME && bundle install --without development test --deployment
# COPY FILES
ADD . $APP_HOME
# Change config
RUN mv $APP_HOME/database.yml.example $APP_HOME/database.yml
WORKDIR $APP_HOME
CMD ["rake -T"]
