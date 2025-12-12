class Message < ActiveRecord::Base
  belongs_to :thread, class_name: "ProjectThread", foreign_key: :thread_id
  belongs_to :user
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy

  validates :content, presence: true
end
