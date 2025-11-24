class AdminController < ApplicationController
  before do
    require_admin
  end

  get "/admin/users" do
    @users = User.all.order(created_at: :desc)
    erb :"admin/users"
  end

  post "/admin/users/:id/promote" do
    user = User.find_by(id: params[:id])

    if user&.update(admin: true)
      flash[:success] = "User promoted to admin"
    else
      flash[:error] = "Failed to promote user"
    end

    redirect "/admin/users"
  end

  post "/admin/users/:id/demote" do
    user = User.find_by(id: params[:id])

    if user && user.id != current_user.id && user.update(admin: false)
      flash[:success] = "User demoted from admin"
    else
      flash[:error] = "Failed to demote user"
    end

    redirect "/admin/users"
  end
end
