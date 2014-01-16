class Session
  include ActiveModel::Model

  attr_accessor :email, :passphrase, :original_uri
  validates :email, :passphrase, presence: true

  def user
    User.authenticate(email, passphrase)
  end
end
