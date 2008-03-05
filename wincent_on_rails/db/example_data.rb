module FixtureReplacement
  def article_attributes
    {
      :title                => String.random,
      :body                 => String.random
    }
  end

  def comment_attributes
    {
      :user                 => new_user,
      :body                 => 'hello world',
      :commentable          => new_article
    }
  end

  def confirmation_attributes
    {
      :email                => new_email
    }
  end

  def email_attributes
    {
      :address              => "#{String.random}@example.com",
      :user                 => new_user
    }
  end

  def issue_attributes
    {
    }
  end

  def link_attributes
    {
      :uri                    => "http://#{String.random}/",
      :permalink              => String.random
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

  def tag_attributes
    {
      :name                     => String.random
    }
  end

  def tagging_attributes
    {
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
