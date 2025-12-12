class Project < ActiveRecord::Base
  belongs_to :user
  has_many :project_assignments, dependent: :destroy
  has_many :assigned_users, through: :project_assignments, source: :user
  has_many :comments, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :threads, class_name: "ProjectThread", dependent: :destroy

  validates :name, presence: true
  # Tags are stored as JSON in a text column. Provide safe accessors
  def tags
    raw = read_attribute(:tags)
    return [] if raw.nil? || raw == ""
    return raw if raw.is_a?(Array)
    begin
      JSON.parse(raw)
    rescue
      []
    end
  end

  def tags=(value)
    case value
    when String
      # allow setting a JSON string or a comma separated list
      begin
        parsed = JSON.parse(value)
        write_attribute(:tags, parsed.to_json)
      rescue JSON::ParserError
        write_attribute(:tags, value.split(",").map(&:strip).to_json)
      end
    when Array
      write_attribute(:tags, value.to_json)
    else
      write_attribute(:tags, [].to_json)
    end
  end

  # Scope helpers
  scope :active, -> { where(active: true) }

  def contributors
    User.where(id: [user_id] + assigned_users.pluck(:id))
  end
end
