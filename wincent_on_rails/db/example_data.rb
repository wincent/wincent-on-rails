module FixtureReplacement
  def article_attributes
    {
    }
  end

  def comment_attributes
    {
      :user                 => new_user,
      :body                 => 'hello world',
      :commentable          => new_article
    }
  end

  def email_attributes
    {
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

  def locale_attributes
    {
      :code                   => String.random,
      :description            => String.random
    }
  end

  def needle_attributes
    {
    }
  end

  def revision_attributes
    {
    }
  end

  def tag_attributes
    {
    }
  end

  def tagging_attributes
    {
    }
  end

  def translation_attributes
    {
    }
  end

  def user_attributes
    passphrase = String.random
    {
      :login_name               => String.random,
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
