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

    # UX rule: all replies render at ONE indentation level.
    # - Replying to a parent -> child reply with parent_message_id = parent.id
    # - Replying to a reply  -> sibling reply with parent_message_id = reply.parent_message_id
    #   (but prefix uses the user you clicked “reply” on)

    parent_message_id = (params.dig("message", "parent_message_id") || params[:parent_message_id]).to_s.strip
    reply_to_message_id = (params.dig("message", "reply_to_message_id") || params[:reply_to_message_id]).to_s.strip

    reply_to_message = nil
    if reply_to_message_id != ""
      reply_to_message = @thread.messages.find_by(id: reply_to_message_id)
      unless reply_to_message
        return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :error, "Reply target message not found")
      end
    end

    parent_message = nil
    if parent_message_id != ""
      parent_message = @thread.messages.find_by(id: parent_message_id)
      unless parent_message
        return redirect_with_flash("/projects/#{@project.id}/threads/#{@thread.id}", :error, "Parent message not found")
      end
    end

    # Determine the actual parent to store (always top-level parent for depth=1 UI)
    store_parent = nil
    if parent_message
      store_parent = parent_message.parent_message_id.present? ? @thread.messages.find_by(id: parent_message.parent_message_id) : parent_message
    end

    content = (params.dig("message", "content") || params[:content]).to_s

    # Prefix should target the message you clicked reply on (reply_to_message if present, otherwise store_parent)
    prefix_target = reply_to_message || store_parent
    if prefix_target
      prefix = "@#{prefix_target.user.username} "
      content = prefix + content.sub(/^@\w+\s+/, "") unless content.start_with?(prefix)
    end

    @message = @thread.messages.build(
      content: content,
      parent_message_id: store_parent&.id,
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
