class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :filename, presence: true
  validates :file_path, presence: true

  # Helper to determine a basic icon type based on MIME type
  def icon_type
    return "file" if content_type.nil?

    if content_type.start_with?("image/")
      "image"
    elsif content_type == "application/pdf"
      "pdf"
    else
      "file"
    end
  end
end
