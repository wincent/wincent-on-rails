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
      :user                     => default_user
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

  def needle_attributes
    {
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

  def user_attributes
    passphrase = String.random
    {
      :display_name             => String.random,
      :passphrase               => passphrase,
      :passphrase_confirmation  => passphrase
    }
  end

  def word_attributes
    {
    }
  end
end
