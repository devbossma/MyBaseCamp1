# AdminController - Handles all administrative functionality for the application
#
# This controller provides administrative routes for managing users and viewing
# system statistics. All routes (except the dashboard) require admin privileges.
#
# Routes:
#   GET  /admin                    - Admin dashboard with system statistics
#   GET  /admin/users              - List all users
#   GET  /admin/users/new          - New user creation form
#   POST /admin/users              - Create a new user
#   GET  /admin/users/:id          - View user details
#   GET  /admin/users/:id/edit     - Edit user form
#   PUT  /admin/users/:id          - Update a user
#   POST /admin/users/:id/promote  - Promote a user to admin role
#   POST /admin/users/:id/demote   - Demote a user from admin role
#
# @see ApplicationController for shared controller functionality
# @see User model for user-related operations
class AdminController < ApplicationController
  # GET /admin - Admin Dashboard
  #
  # Displays the main admin dashboard with system statistics and recent activity.
  # Provides an overview of:
  # - Total user count
  # - Total project count
  # - Total comment count
  # - Growth rate percentage
  # - Recent activity feed
  # - Recently registered users
  #
  # @return [String] Rendered admin/index.erb template
  get "/admin" do
    require_admin
    # Aggregate statistics for the dashboard widgets
    @users_count = User.count       # Total registered users
    @projects_count = Project.count # Total projects in the system
    @comments_count = Comment.count # Total comments across all projects
    @growth_rate = 12.4             # Growth rate percentage (TODO: calculate from actual data)

    # Recent activity feed for the dashboard
    # Each activity item contains:
    #   - user_initial: First letter of username for avatar display
    #   - username: Full display name of the user
    #   - action: Description of the action performed
    #   - time: Human-readable time since the action
    #   - type: Category of activity (project, comment, user)
    #   - icon: Font Awesome icon class for visual representation
    # TODO: Replace with actual activity tracking from database
    @recent_activity = [
      {user_initial: "J", username: "John Doe", action: "created a new project", time: "2 hours ago", type: "project", icon: "fa-solid fa-diagram-project"},
      {user_initial: "S", username: "Sarah Wilson", action: "commented on Project X", time: "4 hours ago", type: "comment", icon: "fa-solid fa-comment"},
      {user_initial: "M", username: "Mike Chen", action: "updated profile settings", time: "6 hours ago", type: "user", icon: "fa-solid fa-user"},
      {user_initial: "A", username: "Admin", action: "promoted user to admin", time: "1 day ago", type: "user", icon: "fa-solid fa-shield-halved"}
    ]

    # Fetch the 3 most recently registered users for the dashboard sidebar
    @recent_users = User.order(created_at: :desc).limit(3)

    erb :"admin/index"
  end

  # GET /admin/users - User Management List
  #
  # Displays a paginated list of all users in the system, ordered by
  # creation date (newest first). Requires admin privileges.
  #
  # @require_admin Ensures only administrators can access this route
  # @return [String] Rendered admin/users.erb template
  # @see #require_admin defined in ApplicationController
  get "/admin/users" do
    require_admin
    @users = User.all.order(created_at: :desc)
    erb :"admin/users/index"
  end

  # GET /admin/users/new - New User Form
  #
  # Renders the form for creating a new user account.
  # Requires admin privileges.
  #
  # @require_admin Ensures only administrators can access this route
  # @return [String] Rendered admin/users/new.erb template
  get "/admin/users/new" do
    require_admin
    erb :"admin/users/new"
  end

  # POST /admin/users - Create New User
  #
  # Processes the new user form submission and creates a user account.
  # Requires admin privileges.
  #
  # @param username [String] The unique username for the new user
  # @param email [String] The user's email address
  # @param password [String] The user's password (will be hashed)
  # @param admin [String] "true" if user should have admin privileges, any other value for regular user
  #
  # @require_admin Ensures only administrators can access this route
  # @return [Redirect] Redirects to /admin/users on success with flash message
  # @return [String] Re-renders new user form on validation failure with error messages
  post "/admin/users" do
    require_admin

    # Build new user with form parameters
    # Note: admin flag is converted from string "true" to boolean
    user = User.new(
      username: params[:username],
      email: params[:email],
      password: params[:password],
      admin: params[:admin] == "true"
    )

    # Attempt to save and handle success/failure
    if user.save
      redirect_with_flash("/admin/users", :success, "User created successfully!")
    else
      # Display validation errors and re-render the form
      redirect_with_flash("/admin/users", :error, "Failed to create user: #{user.errors.full_messages.join(", ")}")
      erb :"admin/users/new"
    end
  end

  # GET /admin/users/:id - Show User Details
  #
  # Displays detailed information about a specific user.
  # Requires admin privileges.
  #
  # @param id [Integer] The ID of the user to view (URL parameter)
  #
  # @require_admin Ensures only administrators can access this route
  # @return [String] Rendered admin/users/show.erb template
  # @return [Redirect] Redirects to /admin/users if user not found
  get "/admin/users/:id" do
    require_admin
    @user = User.find_by(id: params[:id])

    unless @user
      redirect_with_flash("/admin/users", :error, "User not found")
    end

    erb :"admin/users/show"
  end

  # GET /admin/users/:id/edit - Edit User Form
  #
  # Renders the form for editing an existing user's account details.
  # Requires admin privileges.
  #
  # @param id [Integer] The ID of the user to edit (URL parameter)
  #
  # @require_admin Ensures only administrators can access this route
  # @return [String] Rendered admin/users/edit.erb template
  # @return [Redirect] Redirects to /admin/users if user not found
  get "/admin/users/:id/edit" do
    require_admin
    @user = User.find_by(id: params[:id])

    unless @user
      redirect_with_flash("/admin/users", :error, "User not found")
    end

    erb :"admin/users/edit"
  end

  # PUT /admin/users/:id - Update User
  #
  # Processes the edit user form submission and updates the user account.
  # Requires admin privileges. Handles password updates only when provided.
  #
  # @param id [Integer] The ID of the user to update (URL parameter)
  # @param username [String] The unique username for the user
  # @param email [String] The user's email address
  # @param password [String] Optional new password (only updated if provided)
  # @param admin [String] "true" if user should have admin privileges
  #
  # @require_admin Ensures only administrators can access this route
  # @return [Redirect] Redirects to /admin/users/:id on success with flash message
  # @return [String] Re-renders edit form on validation failure with error messages
  # @note Prevents self-demotion to avoid admin lockout
  put "/admin/users/:id" do
    require_admin
    @user = User.find_by(id: params[:id])

    # Handle non-existent user
    unless @user
      redirect_with_flash("/admin/users", :error, "User not found")
    end

    # Build update attributes hash
    update_attrs = {
      username: params[:username],
      email: params[:email]
    }

    # Only update password if a new one is provided
    update_attrs[:password] = params[:password] if params[:password] && !params[:password].empty?

    # Handle admin status change with self-demotion protection
    new_admin_status = params[:admin] == "true"
    if @user.id == current_user.id && @user.admin? && !new_admin_status
      redirect_with_flash("/admin/users", :error, "You cannot remove your own admin privileges")
      flash[:error] = "You cannot remove your own admin privileges"
    else
      update_attrs[:admin] = new_admin_status

      # Attempt to update and handle success/failure
      if @user.update(update_attrs)
        redirect_with_flash("/admin/users/#{@user.id}", :success, "User updated successfully!")
      else
        flash[:error] = "Failed to update user: #{@user.errors.full_messages.join(", ")}"
        erb :"admin/users/edit"
      end
    end
  end

  # POST /admin/users/:id/promote - Promote User to Admin
  #
  # Grants admin privileges to an existing user.
  # Requires admin privileges.
  #
  # @param id [Integer] The ID of the user to promote (URL parameter)
  #
  # @require_admin Ensures only administrators can access this route
  # @return [Redirect] Redirects to /admin/users with appropriate flash message
  post "/admin/users/:id/promote" do
    require_admin
    user = User.find_by(id: params[:id])

    # Use safe navigation operator (&.) to handle nil user gracefully
    if user&.update(admin: true)
      flash[:success] = "User promoted to admin"
    else
      flash[:error] = "Failed to promote user"
    end

    redirect "/admin/users"
  end

  # POST /admin/users/:id/demote - Demote User from Admin
  #
  # Removes admin privileges from an existing user.
  # Requires admin privileges. Prevents self-demotion to avoid
  # locking the current admin out of the system.
  #
  # @param id [Integer] The ID of the user to demote (URL parameter)
  #
  # @require_admin Ensures only administrators can access this route
  # @return [Redirect] Redirects to /admin/users with appropriate flash message
  # @note Users cannot demote themselves to prevent accidental lockout
  post "/admin/users/:id/demote" do
    require_admin
    user = User.find_by(id: params[:id])

    # Validate: user exists, is not the current user, and update succeeds
    # The self-demotion check (user.id != current_user.id) prevents admins
    # from accidentally removing their own admin access
    if user && user.id != current_user.id && user.update(admin: false)
      flash[:success] = "User demoted from admin"
    else
      flash[:error] = "Failed to demote user"
    end

    redirect "/admin/users"
  end
end
