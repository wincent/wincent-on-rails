require 'string_additions'

class Time

  def distance_in_words
    now     = Time.now
    seconds = (now - self).to_i
    if seconds < 0
      'in the future'.localized
    elsif seconds == 0
      'now'.localized
    elsif seconds < 60
      'a few seconds ago'.localized
    elsif seconds < 120
      'a minute ago'.localized
    elsif seconds < 180
      'a couple of minutes ago'.localized
    elsif seconds < 300 # 5 minutes
      'a few minutes ago'.localized
    elsif seconds < 3600 # 60 minutes
      '%d minutes ago'.localized % (seconds / 60)
    elsif seconds < 7200
      'an hour ago'.localized
    elsif seconds < 86400 # 24 hours
      '%d hours ago'.localized % (seconds / 3600)
    else
      days = seconds / 86400
      if days == 1
        'yesterday'.localized
      elsif days <= 7
        '%d days ago'.localized % days
      else
        weeks = days / 7
        if weeks == 1
          'a week ago'.localized
        elsif weeks <= 6
          '%d weeks ago'.localized % weeks
        else
          # TODO: localize time/date formats as well
          self.strftime('%d %B %Y')
        end
      end
    end
  end

end
