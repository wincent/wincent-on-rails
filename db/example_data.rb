module FixtureReplacement
  def article_attributes
    {
      :title                    => String.random,
      :body                     => String.random
    }
  end

  def comment_attributes
    {
      :user                     => default_user,
      :body                     => 'hello world',
      :commentable              => default_article,
      :awaiting_moderation      => false
    }
  end

  def confirmation_attributes
    {
      :email                    => default_email
    }
  end

  def email_attributes
    {
      :address                  => "#{String.random}@example.com",
      :user                     => default_user,
      :verified                 => true
    }
  end

  def forum_attributes
    {
      :name                     => String.random
    }
  end

  def issue_attributes
    {
      :summary                  => String.random,
      :description              => String.random,
      :awaiting_moderation      => false
    }
  end

  def link_attributes
    {
      :uri                      => "http://#{String.random}/",
      :permalink                => String.random
    }
  end

  def message_attributes
    {
      # all fields optional or have default values already
    }
  end

  def needle_attributes
    {
      # needles don't use real ActiveRecord associations, so don't even bother
      # creating a real model object for the model fields here
      :model_class              => 'Article',
      :model_id                 => 5000,
      :attribute_name           => 'body',
      :content                  => 'word'
    }
  end

  def page_attributes
    {
      :title      => String.random,
      :permalink  => String.random,
      :body       => "<p>#{String.random}</p>\n"
    }
  end

  def post_attributes
    {
      :title                    => String.random,
      :permalink                => String.random,
      :excerpt                  => String.random,
    }
  end

  def product_attributes
    {
      :name                     => String.random,
      :permalink                => String.random
    }
  end

  def reset_attributes
    {
      :user                     => default_user
    }
  end

  def tag_attributes
    {
      :name                     => String.random
    }
  end

  def tagging_attributes
    {
    }
  end

  def topic_attributes
    {
      :forum                    => default_forum,
      :title                    => String.random,
      :body                     => String.random,
      :awaiting_moderation      => false
    }
  end

  def tweet_attributes
    {
      :body                     => String.random
    }
  end

  PASSPHRASE = 'supersecret'
  def user_attributes
    {
      :display_name             => String.random,
      :passphrase               => PASSPHRASE,
      :passphrase_confirmation  => PASSPHRASE,
      :verified                 => true
    }
  end

  def word_attributes
    {
    }
  end
end
