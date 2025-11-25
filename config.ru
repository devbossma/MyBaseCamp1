require_relative "config/environment"

if ActiveRecord::Base.connection.migration_context.needs_migration?
  raise "Migrations are pending. Run `rake db:migrate` to resolve the issue."
end

use Rack::MethodOverride
run ApplicationController
use AuthController
use ProjectController
use CommentController
use AdminController
use UserController
