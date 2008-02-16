require 'additions/string'

class Time
  def distance_in_words
    now     = Time.now
    seconds = (now - self).to_i
    if seconds < 0
      'in the future'
    elsif seconds == 0
      'now'
    elsif seconds < 60
      'a few seconds ago'
    elsif seconds < 120
      'a minute ago'
    elsif seconds < 180
      'a couple of minutes ago'
    elsif seconds < 300 # 5 minutes
      'a few minutes ago'
    elsif seconds < 3600 # 60 minutes
      '%d minutes ago' % (seconds / 60)
    elsif seconds < 7200
      'an hour ago'
    elsif seconds < 86400 # 24 hours
      '%d hours ago' % (seconds / 3600)
    else
      days = seconds / 86400
      if days == 1
        'yesterday'
      elsif days <= 7
        '%d days ago' % days
      else
        weeks = days / 7
        if weeks == 1
          'a week ago'
        elsif weeks <= 6
          '%d weeks ago' % weeks
        else
          self.strftime('%d %B %Y')
        end
      end
    end
  end
end
