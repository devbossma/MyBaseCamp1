# Base image
FROM ruby:3.3.10-slim

# Install only production system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Set application directory
ENV APP_ROOT=/usr/src/app
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

# Install ONLY production gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 5

# Copy application code
COPY . .

# Copy and set the entrypoint script
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Set the entrypoint to handle migrations
ENTRYPOINT ["docker-entrypoint.sh"]

# Set production environment
ENV RACK_ENV=production

# Expose production
EXPOSE 8080

# Production command
CMD ["bundle", "exec", "rake", "server"]