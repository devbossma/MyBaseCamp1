# controllers/comments_controller.rb
class CommentController < ApplicationController
  before do
    require_login
  end

  # POST /projects/:project_id/comments
  # Create new comment
  post "/projects/:project_id/comments" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @comment = @project.comments.build(
      user_id: current_user.id,
      content: params[:content],
      attachment: params[:attachment],
      read: false  # New comments start as unread
    )

    if @comment.save
      set_flash(:success, "Comment posted successfully")
    else
      set_flash(:error, @comment.errors.full_messages.join(", "))
    end

    redirect "/projects/#{@project.id}#comment-#{@comment.id}"
  end

  # POST /projects/:project_id/comments/:id/mark_read
  # Mark single comment as read
  post "/projects/:project_id/comments/:id/mark_read" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @comment = @project.comments.find_by(id: params[:id])
    halt 404 unless @comment

    # Only mark as read if it"s not the user"s own comment
    if @comment.user_id != current_user.id
      @comment.update(read: true)
    end

    redirect "/projects/#{@project.id}#comment-#{@comment.id}"
  end

  # POST /projects/:project_id/comments/mark_all_read
  # Mark all comments in project as read
  post "/projects/:project_id/comments/mark_all_read" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    # Mark all comments as read except user"s own comments
    @project.comments
      .where.not(user_id: current_user.id)
      .where(read: false)
      .update_all(read: true, updated_at: Time.current)

    set_flash(:success, "All comments marked as read")
    redirect "/projects/#{@project.id}#comments"
  end

  # GET /projects/:project_id/comments/:id/edit
  # Edit comment form
  get "/projects/:project_id/comments/:id/edit" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @comment = @project.comments.find_by(id: params[:id])
    halt 404 unless @comment

    unless can?(:edit, @comment)
      set_flash(:error, "You don't have permission to edit this comment")
      redirect "/projects/#{@project.id}#comment-#{@comment.id}"
    end

    erb :"comments/edit"
  end

  # PATCH /projects/:project_id/comments/:id
  # Update comment
  patch "/projects/:project_id/comments/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @comment = @project.comments.find_by(id: params[:id])
    halt 404 unless @comment

    unless can?(:edit, @comment)
      set_flash(:error, "You don't have permission to edit this comment")
      redirect "/projects/#{@project.id}#comment-#{@comment.id}"
    end

    if @comment.update(
      content: params[:content],
      attachment: params[:attachment]
    )
      set_flash(:success, "Comment updated successfully")
    else
      set_flash(:error, @comment.errors.full_messages.join(", "))
    end

    redirect "/projects/#{@project.id}#comment-#{@comment.id}"
  end

  # DELETE /projects/:project_id/comments/:id
  # Delete comment
  delete "/projects/:project_id/comments/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @comment = @project.comments.find_by(id: params[:id])
    halt 404 unless @comment

    unless can?(:destroy, @comment)
      set_flash(:error, "You don't have permission to delete this comment")
      redirect "/projects/#{@project.id}#comments"
    end

    @comment.destroy
    set_flash(:success, "Comment deleted successfully")
    redirect "/projects/#{@project.id}#comments"
  end
end
