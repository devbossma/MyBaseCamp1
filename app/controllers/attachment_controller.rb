class AttachmentController < ApplicationController
  require "fileutils"

  # POST /projects/:project_id/attachments
  # Any user associated to the project can create an attachment
  post "/projects/:project_id/attachments" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    unless current_user.can_manage?(@project)
      return redirect_with_flash("/projects/#{@project.id}", :error, "You are not allowed to add attachments to this project")
    end

    file = params["file"]

    if file.nil? || file[:tempfile].nil? || file[:filename].to_s.strip.empty?
      return redirect_with_flash("/projects/#{@project.id}", :error, "No file selected")
    end

    tempfile = file[:tempfile]
    original_filename = file[:filename].to_s
    content_type = file[:type].to_s
    file_size = File.size(tempfile.path)

    # Simple file size limit (e.g., 10 MB)
    max_size = 10 * 1024 * 1024
    if file_size > max_size
      return redirect_with_flash("/projects/#{@project.id}", :error, "File is too large (max 10MB)")
    end

    # Store under public/uploads/projects/<project_id>/
    uploads_root = File.expand_path("../../public/uploads/projects/#{@project.id}", __dir__)
    FileUtils.mkdir_p(uploads_root)

    sanitized_name = original_filename.gsub(/[^0-9A-Za-z.-]/, "_")
    stored_name = "#{Time.now.to_i}_#{sanitized_name}"
    stored_path = File.join(uploads_root, stored_name)

    File.binwrite(stored_path, tempfile.read)

    # Path used for public download (relative to /public)
    public_path = "/uploads/projects/#{@project.id}/#{stored_name}"

    attachment = @project.attachments.build(
      filename: original_filename,
      file_path: public_path,
      content_type: content_type,
      file_size: file_size,
      user_id: current_user.id
    )

    if attachment.save
      redirect_with_flash("/projects/#{@project.id}", :success, "Attachment uploaded successfully")
    else
      # Clean up file if DB save fails
      File.delete(stored_path) if File.exist?(stored_path)
      redirect_with_flash("/projects/#{@project.id}", :error, attachment.errors.full_messages.join(", "))
    end
  end

  # DELETE /projects/:project_id/attachments/:id
  # File uploader OR project admin (owner/global admin) can delete
  delete "/projects/:project_id/attachments/:id" do
    @project = Project.find_by(id: params[:project_id])
    halt 404 unless @project

    @attachment = @project.attachments.find_by(id: params[:id])
    halt 404 unless @attachment

    is_project_admin = current_user.admin? || current_user.id == @project.user_id
    can_delete = is_project_admin || current_user.id == @attachment.user_id

    unless can_delete
      return redirect_with_flash("/projects/#{@project.id}", :error, "You are not allowed to delete this attachment")
    end

    file_full_path = File.expand_path("../../public#{@attachment.file_path}", __dir__)
    @attachment.destroy
    File.delete(file_full_path) if File.exist?(file_full_path)

    redirect_with_flash("/projects/#{@project.id}", :success, "Attachment deleted successfully")
  end
end
