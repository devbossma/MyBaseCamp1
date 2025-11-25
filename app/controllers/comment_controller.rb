class CommentController < ApplicationController
  post "/projects/:project_id/comments" do
    project = Project.find_by(id: params[:project_id])

    if project && current_user.can_manage?(project)
      comment = project.comments.new(
        content: params[:content],
        user_id: current_user.id
      )

      if comment.save
        flash[:success] = "Comment added successfully"
      else
        flash[:error] = comment.errors.full_messages.join(", ")
      end

      redirect "/projects/#{project.id}"
    else
      flash[:error] = "Project not found or access denied"
      redirect "/"
    end
  end
end
