
module FixtureReplacement
  def comment_attributes
    {
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

  def locale_attributes
    {
      :code                   => String.random,
      :description            => String.random
    }
  end

  def tagging_attributes
    {
    }
  end

  def tag_attributes
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

end