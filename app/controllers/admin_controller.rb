class AdminController < ApplicationController

  get "/admin/users" do
    require_admin
    @users = User.all.order(created_at: :desc)
    erb :"admin/users"
  end

  post "/admin/users/:id/promote" do
    require_admin
    user = User.find_by(id: params[:id])

    if user&.update(admin: true)
      flash[:success] = "User promoted to admin"
    else
      flash[:error] = "Failed to promote user"
    end

    redirect "/admin/users"
  end

  post "/admin/users/:id/demote" do
    require_admin
    user = User.find_by(id: params[:id])

    if user && user.id != current_user.id && user.update(admin: false)
      flash[:success] = "User demoted from admin"
    else
      flash[:error] = "Failed to demote user"
    end

    redirect "/admin/users"
  end
end
