class User < ActiveRecord::Base
  has_secure_password

  has_one :profile, dependent: :destroy
  has_many :projects, foreign_key: "user_id", dependent: :destroy
  has_many :project_assignments, dependent: :destroy
  has_many :assigned_projects, through: :project_assignments, source: :project, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :threads, class_name: "ProjectThread", dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: {minimum: 6}, on: :create

  # Automatically create profile when user is created
  after_create :create_profile!

  # Delegation to profile for profile-related attributes
  delegate :bio, :email_notifications, :weekly_digest, :public_profile, :timezone, :language, :preferences, to: :profile, allow_nil: true

  def all_projects
    Project.where(id: (projects.pluck(:id) + assigned_projects.pluck(:id)).uniq)
  end

  def can_manage?(project)
    admin? || project.user_id == id || project.assigned_users.exists?(id)
  end

  def can_manage_profile?(profile)
    admin? || profile.user_id == id
  end

  def owns?(project)
    project.user_id == id
  end

  # Callbacks
  before_save :downcase_email

  # Methods
  def admin?
    admin
  end

  def contributing_projects
    assigned_projects
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
