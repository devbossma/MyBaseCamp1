require "bundler/setup"

# Set environment before requiring gems
ENV["RACK_ENV"] ||= "development"

# Require gems for current environment
Bundler.require(:default, ENV["RACK_ENV"])

# Load environment variables from .env file in development/test
if ENV["RACK_ENV"] != "production"
  require "dotenv"
  Dotenv.load
end

# Configure based on environment
configure :development do
  ActiveRecord::Base.logger = Logger.new($stdout)
end

configure do
  set :public_folder, "../public"
  set :views, "../app/views"
end

# Set up root path
$LOAD_PATH.unshift(File.expand_path("..", __dir__))

# Configure sessions with environment variable for secret
use Rack::Session::Cookie,
  key: "rack.session",
  secret: ENV.fetch("SESSION_SECRET") {
    if ENV["RACK_ENV"] == "production"
      raise "SESSION_SECRET environment variable is required in production"
    else
      warn "WARNING: Using default session secret. Set SESSION_SECRET environment variable."
      "development_secret_change_this_in_production"
    end
  },
  same_site: :lax,
  max_age: 86400 * 30, # 30 days
  httponly: true,
  secure: ENV["RACK_ENV"] == "production" # Only send over HTTPS in production

# Require models
require_relative "../app/models/comment"
require_relative "../app/models/project_assignment"
require_relative "../app/models/project"
require_relative "../app/models/user"
require_relative "../app/models/profile"
require_relative "../app/models/attachment"
require_relative "../app/models/thread"
require_relative "../app/models/message"

# Require controllers
require_relative "../app/controllers/application_controller"
require_relative "../app/controllers/admin_controller"
require_relative "../app/controllers/auth_controller"
require_relative "../app/controllers/comment_controller"
require_relative "../app/controllers/project_controller"
require_relative "../app/controllers/user_controller"
require_relative "../app/controllers/attachment_controller"
require_relative "../app/controllers/thread_controller"
require_relative "../app/controllers/message_controller"