require_relative "config/environment"

if ActiveRecord::Base.connection.migration_context.needs_migration?
  raise "Migrations are pending. Run `rake db:migrate` to resolve the issue."
end

use Rack::MethodOverride

# Compose modular Sinatra apps.
# Rack::Cascade will try each app in order and only stop when a request is handled
# (i.e., response status not in [404, 405]). This avoids "first app returns 404" issues.
run Rack::Cascade.new([
  AuthController.new,
  ProjectController.new,
  CommentController.new,
  AttachmentController.new,
  ThreadController.new,
  MessageController.new,
  AdminController.new,
  UserController.new,
  ApplicationController.new
])
