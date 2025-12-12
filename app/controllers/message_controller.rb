class MessageController < ApplicationController
  before do
    require_login
  end

  helpers do
    def project_admin?(project)
      current_user&.admin? || current_user&.id == project.user_id
    end

    def can_edit_message?(message, project)
      project_admin?(project) || current_user&.id == message.user_id
    end
  end

  # POST /projects/:project_id/threads/:thread_id/messages
  # Any users associated to the project can create a message
  post "/projects/:project_id/threads/:thread_id/messages" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:thread_id])
    halt 404 unless @thread

    unless current_user.can_manage?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "You are not allowed to post messages in this project")
    end

    if @thread.locked
      return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :error, "This thread is locked")
    end

    @message = @thread.messages.build(
      content: params.dig("message", "content") || params[:content],
      parent_message_id: params.dig("message", "parent_message_id") || params[:parent_message_id],
      user: current_user
    )

    if @message.save
      redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}#message-#{@message.id}", :success, "Message posted successfully")
    else
      flash[:error] = @message.errors.full_messages.join(", ")
      @messages = @thread.messages.includes(:user).order(created_at: :asc)
      erb :"threads/show"
    end
  end

  # GET /projects/:project_id/threads/:thread_id/messages/:id/edit
  get "/projects/:project_id/threads/:thread_id/messages/:id/edit" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:thread_id])
    halt 404 unless @thread

    @message = @thread.messages.find_by(id: params[:id])
    halt 404 unless @message

    unless can_edit_message?(@message, @project)
      return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}#message-#{@message.id}", :error, "You are not allowed to edit this message")
    end

    erb :"messages/edit"
  end

  # PATCH /projects/:project_id/threads/:thread_id/messages/:id
  patch "/projects/:project_id/threads/:thread_id/messages/:id" do
    update_message
  end

  # PUT /projects/:project_id/threads/:thread_id/messages/:id
  put "/projects/:project_id/threads/:thread_id/messages/:id" do
    update_message
  end

  # DELETE /projects/:project_id/threads/:thread_id/messages/:id
  delete "/projects/:project_id/threads/:thread_id/messages/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:thread_id])
    halt 404 unless @thread

    @message = @thread.messages.find_by(id: params[:id])
    halt 404 unless @message

    unless can_edit_message?(@message, @project)
      return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :error, "You are not allowed to delete this message")
    end

    @message.destroy
    redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :success, "Message deleted successfully")
  end

  private

  def update_message
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @thread = @project.threads.find_by(id: params[:thread_id])
    halt 404 unless @thread

    @message = @thread.messages.find_by(id: params[:id])
    halt 404 unless @message

    unless can_edit_message?(@message, @project)
      return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}#message-#{@message.id}", :error, "You are not allowed to edit this message")
    end

    @message.content = params.dig("message", "content") || params[:content]
    @message.edited_at = Time.now

    if @message.save
      redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}#message-#{@message.id}", :success, "Message updated successfully")
    else
      flash[:error] = @message.errors.full_messages.join(", ")
      erb :"messages/edit"
    end
  end
end
