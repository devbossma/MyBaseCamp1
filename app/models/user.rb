class User < ActiveRecord::Base
  has_secure_password

  has_many :projects, foreign_key: "user_id", dependent: :destroy
  has_many :project_assignments, dependent: :destroy
  has_many :assigned_projects, through: :project_assignments, source: :project
  has_many :comments

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: {minimum: 6}, on: :create

  def all_projects
    Project.where(id: (projects.pluck(:id) + assigned_projects.pluck(:id)).uniq)
  end

  def can_manage?(project)
    admin? || project.user_id == id || project.assigned_users.exists?(id)
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

  private

  def downcase_email
    self.email = email.downcase
  end
end
