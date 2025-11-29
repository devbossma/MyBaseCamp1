# helpers/time_helpers.rb
module TimeHelpers
  def time_ago(time)
    return "" unless time

    seconds = Time.now - time
    case seconds
    when 0..59
      "just now"
    when 60..3599
      "#{(seconds / 60).to_i}m ago"
    when 3600..86399
      "#{(seconds / 3600).to_i}h ago"
    when 86400..604799
      "#{(seconds / 86400).to_i}d ago"
    when 604800..2419199
      "#{(seconds / 604800).to_i}w ago"
    else
      time.strftime("%b %d, %Y")
    end
  rescue
    time.strftime("%b %d, %Y")
  end
end
