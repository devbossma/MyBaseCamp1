# Thread model for project discussions.
# Uses table name `threads` but avoids clashing with Ruby's core Thread
# class by naming this model `ProjectThread`.
class ProjectThread < ActiveRecord::Base
  self.table_name = "threads"

  belongs_to :project
  belongs_to :user
  has_many :messages, foreign_key: :thread_id, dependent: :destroy

  validates :title, presence: true

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }
end
