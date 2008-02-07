require 'additions/time'

module ApplicationHelper
  # Pretty formatting for model creation/update information.
  #
  # Examples:
  #   - Created yesterday
  #   - Created 4 hours ago, updated a few seconds ago
  #
  def timeinfo(model, precise = false)
    # BUG: in Spanish localization will be translated as "creado" (masculine) etc for both masculine and feminine models
    created = model.created_at
    updated = model.updated_at
    if precise  # always show exact date and time
      if created == updated
        'Created %s'.localized % created.to_s(:long)
      else
        'Created %s, updated %s' % [created.to_s(:long), updated.to_s(:long)]
      end
    else        # show human-friendly dates ("yesterday", "2 hours ago" etc)
      created = created.distance_in_words
      updated = updated.distance_in_words
      if created == updated
        'Created %s'.localized % created
      else
        'Created %s, updated %s'.localized % [created, updated]
      end
    end
  end

  # TODO: localize
  def item_count number
    if number == 1
      '1 item'
    else
      "#{number} items"
    end
  end

  # TODO: potentially move these methods into authentication.rb as well
  def logged_in_only &block
    if logged_in?
      yield
    end
  end

  def admin_only &block
    if admin?
      open :div, { :class => 'admin' } do
        yield
      end
    end
  end
end
