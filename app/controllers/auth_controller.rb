class AuthController < ApplicationController
  get "/login" do
    erb :"auth/login"
  end

  post "/login" do
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_with_flash("/", :success, "Welcome back, #{user.username}!")
    else
      redirect_with_flash("/login", :error, "Invalid email or password")
    end
  end

  # post "/login" do
  #   user = User.find_by(email: params[:email])

  #   if user&.authenticate(params[:password])
  #     session[:user_id] = user.id
  #     redirect session[:return_to] || "/"
  #     session[:return_to] = nil
  #   else
  #     flash[:error] = "Invalid email or password"
  #     erb :"auth/login"
  #   end
  # end

  get "/register" do
    erb :"auth/register"
  end

  post "/register" do
    user = User.new(
      username: params[:username],
      email: params[:email],
      password: params[:password_confirmation]
    )

    if user.save
      session[:user_id] = user.id
      redirect "/"
    else
      flash[:error] = user.errors.full_messages.join(", ")
      erb :"auth/register"
    end
  end

  post "/logout" do
    session.clear
    redirect "/login"
  end
end
