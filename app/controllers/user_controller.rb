class UserController < ApplicationController
  get "/profile" do
    @user = User.find_by(id: session[:user_id])
    if @user
      erb :"profile/index"
    else
      redirect_with_flash("/projects/index", :error, "User not Found")
    end
  end

  get "/profile/edit" do
    @user = current_user
    erb :"profile/edit"
  end

  get "/user/data" do
    content_type :json
    current_user.profile.to_json
    current_user.to_json
  end

  get "/profile/security" do
    erb :"profile/security"
  end

  # Handle password update
  post "/profile/security" do
    @user = current_user

    current_password = params[:current_password]
    new_password = params[:new_password]
    confirm_password = params[:confirm_password]

    # Validation checks
    if current_password.empty? || new_password.empty? || confirm_password.empty?
      redirect_with_flash("/profile/security", :error, "All password fields are required.")
      return
    end

    unless @user.authenticate(current_password)
      redirect_with_flash("/profile/security", :error, "Current password is incorrect.")
      return
    end

    unless new_password == confirm_password
      redirect_with_flash("/profile/security", :error, "New passwords do not match.")
      return
    end

    if new_password.length < 8
      redirect_with_flash("/profile/security", :error, "New password must be at least 8 characters long.")
      return
    end

    # Update password
    if @user.update(password: new_password)
      redirect_with_flash("/profile/security", :success, "Password updated successfully!")
    else
      redirect_with_flash("/profile/security", :error, "Failed to update password: #{@user.errors.full_messages.join(', ')}")
    end
  end

  put "/profile/update" do

    @user = current_user
    @profile = @user.profile
    begin
      ActiveRecord::Base.transaction do
        # Update user
        user_updated = @user.update(
          username: params.dig(:user, :username),
          email: params.dig(:user, :email)
        )

        # Update profile - handle checkboxes properly
        profile_updated = @profile.update(
          bio: params.dig(:profile, :bio),
          # If checkbox is checked, value is "true", otherwise nil
          email_notifications: params.dig(:profile, :email_notifications) == 'true',
          weekly_digest: params.dig(:profile, :weekly_digest) == 'true',
          public_profile: params.dig(:profile, :public_profile) == 'true',
          timezone: params.dig(:profile, :timezone),
          language: params.dig(:profile, :language)
        )

        unless user_updated && profile_updated
          redirect_with_flash("/profile/edit", :error, "Profile update failed: #{errors}")
          return
        end
      end
      redirect_with_flash("/profile", :success, "Profile Updated Successfully")
    rescue => e
      redirect_with_flash("/profile/edit", :error, "Error updating profile: #{e.message}")
    end
  end

  get "/profile/:id" do
    @user = User.find_by(id: params[:id])
    @current_user = current_user

    unless @user
      redirect_with_flash("/errors/404", :error, "User Not found")
    end

    if @user.id == @current_user.id
      redirect "/profile"
    end
    erb :"profile/index"
  end

  post "/profile" do
    @user = current_user

    if @user.update(
      username: params[:username],
      email: params[:email],
      password: params[:password].empty? ? @user.password : params[:password]
    )
      redirect_with_flash("/profile", :success, "Profile updated successfully")
    else
      flash.now[:error] = @user.errors.full_messages.join(", ")
      erb :"profile/index"
    end
  end

  # Deleting Profile is deleting The User that this profile beleongs to
  delete "/profile" do
    current_user.destroy
    session.clear
    redirect_with_flash("/register", :success, "Your account has been deleted")
  end


  private

  def user_params
    params[:user]&.slice(:username, :email) || {}
  end

  def profile_params
    profile_data = params[:profile] || {}
    {
      bio: profile_data[:bio],
      email_notifications: profile_data[:email_notifications] == true,
      weekly_digest: profile_data[:weekly_digest] == true,
      public_profile: profile_data[:public_profile] == true,
      timezone: profile_data[:timezone],
      language: profile_data[:language]
    }
  end
end
