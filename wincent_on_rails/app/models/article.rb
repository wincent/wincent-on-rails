# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many    :revisions
  has_many    :comments,  :as => :commentable
  acts_as_taggable
end
