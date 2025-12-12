class ApplicationController < Sinatra::Base
  configure do
    set :views, File.expand_path("../../views", __FILE__)
    set :public_folder, File.expand_path("../../../public", __FILE__)
    set :erb, layout: :layout, default_encoding: "utf-8"
    enable :sessions
  end

  require_relative "../helpers/comment_helpers"
  require_relative "../helpers/project_helpers"
  require_relative "../helpers/time_helpers"
  require_relative "../helpers/pagination_helpers"

  helpers do
    include CommentHelpers
    include ProjectHelpers
    include TimeHelpers
    include PaginationHelpers

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def can?(action, resource = nil)
      return false unless logged_in?

      case action
      when :manage_profile
        if resource? && params[:id]
          current_user.id == params[:id]
        end
      when :manage_users
        current_user.admin?
      when :edit, :destroy
        return false unless resource
        current_user.admin? || resource.user_id == current_user.id
      when :create_project
        true
      else
        false
      end
    end

    def logged_in?
      !!current_user
    end

    def require_login
      unless logged_in?
        redirect "/login"
      end
    end

    def require_admin
      unless current_user&.admin?
        halt 403, erb(:"errors/403")
      end
    end

    def flash
      @flash ||= session.delete(:flash) || {}
    end

    def flash_now
      flash
    end

    # Set flash message
    def set_flash(type, message)
      session[:flash] = {type.to_sym => message}
    end

    # Redirect with flash
    def redirect_with_flash(path, type, message)
      set_flash(type, message)
      redirect path
    end

    # HTML escaping helper for views (Sinatra apps may not provide `h` by default)
    def h(value)
      Rack::Utils.escape_html(value.to_s)
    end

    alias_method :html_escape, :h
  end

  before do
    # @flash = flash
    # Public routes that should not force a redirect to login
    pass if request.path == "/login" || request.path == "/register" || request.path == "/" || request.path == "/debug_session"
    require_login
  end

  get "/" do
    if !!current_user
      redirect "/projects"
    end
    erb :index
  end
  # ============================================
  # Error Handlers
  # ============================================

  not_found do
    erb :"errors/404"
  rescue
    "404 - Page Not Found"
  end

  error do
    erb :"errors/403"
  rescue
    "403 - You do not have permission to view this page. Not an admin"
  end

  error do
    erb :"errors/500"
  rescue
    "500 - Internal Server Error"
  end
end
