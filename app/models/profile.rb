# models/profile.rb
class Profile < ActiveRecord::Base
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :bio, length: {maximum: 500}, allow_blank: true
  validates :timezone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name)}, allow_blank: true
  validates :language, inclusion: {in: %w[en fr es de it]}, allow_blank: true

  after_initialize :set_default_preferences

  # Add a method to safely access preferences
  def preferences
    self[:preferences] || set_default_preferences
  end

  # Helper methods for common preference access
  def theme
    preferences["theme"] || "dark"
  end

  def email_notifications_enabled?
    preferences.dig("notifications", "email") != false
  end

  def push_notifications_enabled?
    preferences.dig("notifications", "push") == true
  end

  def desktop_notifications_enabled?
    preferences.dig("notifications", "desktop") != false
  end

  def compact_mode?
    preferences.dig("display", "compact_mode") == true
  end

  def show_avatars?
    preferences.dig("display", "show_avatars") != false
  end

  private

  def set_default_preferences
    self[:preferences] ||= {
      "theme" => "dark",
      "notifications" => {
        "email" => true,
        "push" => false,
        "desktop" => true
      },
      "display" => {
        "compact_mode" => false,
        "show_avatars" => true
      }
    }
    self[:preferences]
  end
end
