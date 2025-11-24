require "json"
class UsersController < ApplicationController
  # JSON endpoint for user lookup used by assignee typeahead
  get "/users/search" do
    q = params[:q].to_s.strip
    content_type :json

    if q.length < 1
      status 400
      return {error: "query required"}.to_json
    end
    # If not logged in, return 401 JSON rather than redirect
    unless current_user
      status 401
      return {error: "unauthenticated"}.to_json
    end

    # Basic, safe search: match email or username (SQLite uses LIKE)
    pattern = "%#{q}%"
    users = User.where("email LIKE ? OR username LIKE ?", pattern, pattern)
      .limit(10)
      .select(:id, :email, :username)

    users.map { |u| {id: u.id, email: u.email, username: u.username} }.to_json
  end
end
