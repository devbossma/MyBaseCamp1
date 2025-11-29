# helpers/comment_helpers.rb
module CommentHelpers
  # Get unread comments count for a project (for current user)
  def unread_comments_count(project)
    return 0 unless logged_in?

    project.comments
      .where.not(user_id: current_user.id)
      .where(read: false)
      .count
  end

  # Get total comments count
  def total_comments_count(project)
    project.comments.count
  end

  # Get first unread comment ID (for direct linking)
  def first_unread_comment_id(project)
    return nil unless logged_in?

    project.comments
      .where.not(user_id: current_user.id)
      .where(read: false)
      .order(created_at: :asc)
      .first
      &.id
  end

  # Mark all comments in a project as read for current user
  def mark_project_comments_as_read(project)
    return unless logged_in?

    project.comments
      .where.not(user_id: current_user.id)
      .where(read: false)
      .update_all(read: true, updated_at: Time.current)
  end

  # Check if comment is unread for current user
  def comment_unread?(comment)
    return false unless logged_in?
    return false if comment.user_id == current_user.id

    !comment.read
  end

  # Simple format helper (like Rails simple_format)
  # Converts line breaks to <br> tags and wraps paragraphs in <p> tags
  def simple_format(text)
    return "" if text.nil? || text.empty?

    # Escape HTML to prevent XSS
    text = h(text)

    # Split into paragraphs (double line breaks)
    paragraphs = text.split(/\n\n+/)

    # Wrap each paragraph in <p> tags and convert single line breaks to <br>
    paragraphs.map { |p|
      "<p>#{p.gsub("\n", "<br>")}</p>"
    }.join("\n")
  end

  # HTML escape helper (if not already available)
  def h(text)
    Rack::Utils.escape_html(text.to_s)
  end
end
