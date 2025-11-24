class ProjectsController < ApplicationController
  get "/projects" do
    @projects = current_user.all_projects.order(created_at: :desc)
    erb :"projects/index"
  end

  get "/projects/new" do
    erb :"projects/new"
  end

  post "/projects" do
    project_params = parse_project_params(params)

    # If caller supplied assigned_user_emails, resolve them to IDs and validate
    desired_ids = nil
    if params.dig("project", "assigned_user_emails")
      emails_raw = params["project"]["assigned_user_emails"]
      resolved_ids, missing = resolve_assigned_emails(emails_raw)
      if missing.any?
        flash[:error] = "User(s) not found: #{missing.join(", ")}. Please register them first or correct the emails."
        @project = current_user.projects.new(
          name: project_params[:name],
          description: project_params[:description],
          cover_url: project_params[:cover_url],
          active: project_params[:active]
        )
        @project.tags = project_params[:tags] if project_params[:tags]
        return erb :"projects/new"
      end
      desired_ids = resolved_ids
    end

    @project = current_user.projects.new(
      name: project_params[:name],
      description: project_params[:description],
      cover_url: project_params[:cover_url],
      active: project_params[:active]
    )

    @project.tags = project_params[:tags] if project_params[:tags]

    if @project.save
      # prefer explicit assigned_user_ids param, otherwise use resolved emails
      desired = if project_params[:assigned_user_ids] && project_params[:assigned_user_ids].any?
        Array(project_params[:assigned_user_ids]).map(&:to_i)
      else
        Array(desired_ids).map(&:to_i)
      end

      if desired && desired.any?
        current = @project.assigned_users.pluck(:id)
        to_add = desired - current
        to_remove = current - desired

        to_add.each do |uid|
          ProjectAssignment.find_or_create_by(project_id: @project.id, user_id: uid)
        end

        if to_remove.any?
          ProjectAssignment.where(project_id: @project.id, user_id: to_remove).delete_all
        end
      end

      puts "[DEBUG] POST created project attrs: #{@project.attributes.slice("id", "name", "cover_url", "active", "tags")}" if defined?(puts)
      puts "[DEBUG] POST assigned_user_ids: #{@project.assigned_user_ids.inspect}" if defined?(puts)

      redirect_with_flash("/projects/#{@project.id}", :success, "Project Created Successfully, #{@project.name}!")
    else
      flash[:error] = @project.errors.full_messages.join(", ")
      erb :"projects/new"
    end
  end

  get "/projects/:id" do
    @project = Project.find_by(id: params[:id])

    if @project && current_user.can_manage?(@project)
      @comments = @project.comments.includes(:user).order(created_at: :desc)
      erb :"projects/show"
    else
      flash[:error] = "Project not found or access denied"
      redirect "/"
    end
  end

  get "/projects/:id/edit" do
    @project = Project.find_by(id: params[:id])

    if @project && current_user.can_manage?(@project)
      erb :"projects/edit"
    else
      flash[:error] = "Project not found or access denied"
      redirect "/"
    end
  end

  put "/projects/:id" do
    @project = Project.find_by(id: params[:id])

    if @project && current_user.can_manage?(@project)
      project_params = parse_project_params(params)

      # If caller supplied assigned_user_emails, resolve them to IDs and validate
      desired_ids = nil
      if params.dig("project", "assigned_user_emails")
        emails_raw = params["project"]["assigned_user_emails"]
        resolved_ids, missing = resolve_assigned_emails(emails_raw)
        if missing.any?
          flash[:error] = "User(s) not found: #{missing.join(", ")}. Please register them first or correct the emails."
          @project.name = project_params[:name]
          @project.description = project_params[:description]
          @project.cover_url = project_params[:cover_url]
          @project.active = project_params[:active]
          @project.tags = project_params[:tags] if project_params[:tags]
          return erb :"projects/edit"
        end
        desired_ids = resolved_ids
      end

      @project.name = project_params[:name]
      @project.description = project_params[:description]
      @project.cover_url = project_params[:cover_url]
      @project.active = project_params[:active]
      @project.tags = project_params[:tags] if project_params[:tags]

      if @project.save
        # prefer explicit assigned_user_ids param, otherwise use resolved emails
        desired = if project_params[:assigned_user_ids]&.any?
          Array(project_params[:assigned_user_ids]).map(&:to_i)
        else
          Array(desired_ids).map(&:to_i)
        end

        if desired && desired.any?
          current = @project.assigned_users.pluck(:id)

          to_add = desired - current
          to_remove = current - desired

          to_add.each do |uid|
            ProjectAssignment.find_or_create_by(project_id: @project.id, user_id: uid)
          end

          if to_remove.any?
            ProjectAssignment.where(project_id: @project.id, user_id: to_remove).delete_all
          end
        end
        redirect_with_flash("/projects/#{@project.id}", :success, "Project Updated Successfully, #{@project.name}!")
      else
        flash[:error] = @project.errors.full_messages.join(", ")
        erb :"projects/edit"
      end
    else
      flash[:error] = "Project not found or access denied"
      redirect "/"
    end
  end

  delete "/projects/:id" do
    project = Project.find_by(id: params[:id])

    if project && (current_user.admin? || project.user_id == current_user.id)
      project.destroy
      flash[:success] = "Project deleted successfully"
    else
      flash[:error] = "Project not found or access denied"
    end

    redirect "/"
  end

  private

  # Resolve comma-separated emails to user IDs. Returns [ids_array, missing_emails_array]
  def resolve_assigned_emails(emails_raw)
    return [[], []] if emails_raw.nil?
    emails = Array(emails_raw.to_s.split(",")).map(&:strip).reject(&:empty?)
    found = []
    missing = []
    emails.each do |em|
      # case-insensitive match on email
      u = User.where("lower(email) = ?", em.downcase).first
      if u
        found << u.id
      else
        missing << em
      end
    end
    [found, missing]
  end

  # Normalize incoming params from either nested `project[...]` or flat params
  def parse_project_params(params)
    p = params["project"] || {}

    fetch = lambda do |key|
      if p.key?(key)
        p[key]
      else
        params[key] || params[key.to_sym]
      end
    end

    tags_raw = fetch.call("tags")
    tags_val = if tags_raw.is_a?(String)
      tags_raw.strip
    elsif tags_raw.is_a?(Array)
      tags_raw.map(&:to_s).join(", ")
    else
      nil
    end

    assigned = fetch.call("assigned_user_ids")
    assigned_ids = if assigned.nil?
      []
    else
      Array(assigned).reject(&:empty?).map(&:to_i)
    end

    cover_url = fetch.call("cover_url")

    active_raw = if p.key?("active")
      p["active"]
    else
      params["active"] || params[:active]
    end

    # Robust boolean casting for checkbox values
    active_val = case active_raw
    when TrueClass, FalseClass
      active_raw
    when String
      v = active_raw.strip.downcase
      %w[1 true t yes on].include?(v)
    when NilClass
      false
    else
      !!active_raw
    end

    {
      name: fetch.call("name"),
      description: fetch.call("description"),
      cover_url: (cover_url && cover_url != "") ? cover_url : nil,
      active: active_val,
      tags: tags_val,
      assigned_user_ids: assigned_ids
    }
  end
end
