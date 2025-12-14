FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache build-base sqlite-dev nodejs tzdata sqlite-libs

# Set application directory
ENV APP_ROOT /usr/src/app
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

# Install gems first for better layer caching
COPY Gemfile Gemfile.lock ./
RUN bundle config set force_ruby_platform true && \
    bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 5 --verbose

# Copy the rest of the application
COPY . .

# Copy and set the entrypoint script
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Set the entrypoint to handle migrations
ENTRYPOINT ["docker-entrypoint.sh"]

# Expose both ports (development:4567, production:8080)
EXPOSE 4567 8080
# Default command will be overridden by docker-compose or uses simple_server
CMD ["bundle", "exec", "rake", "server"]