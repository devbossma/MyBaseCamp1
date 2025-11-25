class UserController < ApplicationController
  get "/profile" do
    @user = current_user
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

  delete "/profile" do
    current_user.destroy
    session.clear
    redirect_with_flash("/", :success, "Your account has been deleted")
  end

  get "/profile/edit" do
    @user = current_user
    erb :"profile/edit"
  end
end
