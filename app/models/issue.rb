class Issue < ActiveRecord::Base
  module Status
    # see also http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/1e23eb3d380f2c98?hl=en
    # for another idea
    NEW     = 0 # default
    OPEN    = 1 # in progress
    CLOSED  = 2
  end

  module Kind
    BUG             = 0
    FEATURE_REQUEST = 1
    SUPPORT_TICKET  = 2
    FEEDBACK        = 3
  end

  belongs_to  :user
  #belongs_to  :product
  has_many    :comments,  :as => :commentable
  acts_as_taggable

  def kind_string
    case kind
    when Kind::BUG
      'bug'
    when Kind::FEATURE_REQUEST
      'feature request'
    when Kind::SUPPORT_TICKET
      'support ticket'
    when Kind::FEEDBACK
      'feedback'
    else
      # should never get here
      'ticket'
    end
  end
end
