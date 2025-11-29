# helpers/project_helpers.rb
module ProjectHelpers
  def project_status_badge(project)
    return unless project
    if project.respond_to?(:active)
      status_class = project.active ? "status-active" : "status-inactive"
      status_text = project.active ? "Active" : "Inactive"
    else
      status_class = "status-active"
      status_text = "Active"
    end
    "<span class='status-badge #{status_class}'>#{status_text}</span>"
  end
end
