require "bundler/setup"
Bundler.require

configure :development do
  ActiveRecord::Base.logger = Logger.new($stdout)
end

configure do
  set :public_folder, "../public"
  set :views, "../app/views"
end

ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"])

# Set up root path
$LOAD_PATH.unshift(File.expand_path("..", __dir__))

# Configure sessions
use Rack::Session::Cookie,
  key: "rack.session",
  same_site: :lax,
  max_age: 86400 * 30

require_relative "../app/models/comment"
require_relative "../app/models/project_assignment"
require_relative "../app/models/project"
require_relative "../app/models/user"
require_relative "../app/models/profile"

require_relative "../app/controllers/application_controller"
require_relative "../app/controllers/admin_controller"
require_relative "../app/controllers/auth_controller"
require_relative "../app/controllers/comment_controller"
require_relative "../app/controllers/project_controller"
require_relative "../app/controllers/user_controller"
