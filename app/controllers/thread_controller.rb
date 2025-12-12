class ThreadController < ApplicationController
  helpers do
    def project_admin?(project)
      current_user&.admin? || current_user&.id == project.user_id
    end
  end

  # GET /projects/:project_id/threads/new
  # Only project admin can create a thread
  #    /projects/5/threads/new
  get "/projects/:project_id/threads/new" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    unless project_admin?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "Only the project admin can create threads")
    end

    @thread = @project.threads.build(user: current_user)
    erb :"threads/new"
  end

  # GET /projects/:project_id/threads/:id
  get "/projects/:project_id/threads/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:id])
    halt 404 unless @thread

    unless current_user.can_manage?(@project)
      return redirect_with_flash("/projects", :error, "You do not have access to this project")
    end

    @messages = @thread.messages.includes(:user).order(created_at: :asc)
    erb :"threads/show"
  end

  # POST /projects/:project_id/threads
  post "/projects/:project_id/threads" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    unless project_admin?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "Only the project admin can create threads")
    end

    @thread = @project.threads.build(
      title: params.dig("thread", "title") || params[:title],
      description: params.dig("thread", "description") || params[:description],
      pinned: params.dig("thread", "pinned").to_s == "1" || params[:pinned].to_s == "1",
      locked: params.dig("thread", "locked").to_s == "1" || params[:locked].to_s == "1",
      user: current_user
    )

    if @thread.save
      redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :success, "Thread created successfully")
    else
      flash[:error] = @thread.errors.full_messages.join(", ")
      erb :"threads/new"
    end
  end

  # GET /projects/:project_id/threads/:id/edit
  get "/projects/:project_id/threads/:id/edit" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:id])
    halt 404 unless @thread

    unless project_admin?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "Only the project admin can edit threads")
    end

    erb :"threads/edit"
  end

  # PUT/PATCH /projects/:project_id/threads/:id
  put "/projects/:project_id/threads/:id" do
    update_thread
  end

  patch "/projects/:project_id/threads/:id" do
    update_thread
  end

  # DELETE /projects/:project_id/threads/:id
  delete "/projects/:project_id/threads/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:id])
    halt 404 unless @thread

    unless project_admin?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "Only the project admin can delete threads")
    end

    @thread.destroy
    redirect_with_flash("/projects/#{@project.id}", :success, "Thread deleted successfully")
  end

  private

  def update_thread
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:id])
    halt 404 unless @thread

    unless project_admin?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "Only the project admin can edit threads")
    end

    @thread.title = params.dig("thread", "title") || params[:title]
    @thread.description = params.dig("thread", "description") || params[:description]
    @thread.pinned = params.dig("thread", "pinned").to_s == "1" || params[:pinned].to_s == "1"
    @thread.locked = params.dig("thread", "locked").to_s == "1" || params[:locked].to_s == "1"

    if @thread.save
      redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :success, "Thread updated successfully")
    else
      flash[:error] = @thread.errors.full_messages.join(", ")
      erb :"threads/edit"
    end
  end
end
