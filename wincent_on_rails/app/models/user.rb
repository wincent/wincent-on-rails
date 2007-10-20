class User < ActiveRecord::Base
  MINIMUM_LOGIN_NAME_LENGTH = 3
  MINIMUM_PASSWORD_LENGTH   = 8

  has_many    :emails
  has_many    :issues
  has_many    :comments
  belongs_to  :locale

  attr_reader               :passphrase
  attr_accessor             :passphrase_confirmation, :old_passphrase

  attr_accessible           :login_name, :display_name, :passphrase, :passphrase_confirmation, :old_passphrase, :locale

  validates_presence_of     :login_name
  validates_uniqueness_of   :login_name,    :case_sensitive => false
  validates_length_of       :login_name,    :minimum => MINIMUM_LOGIN_NAME_LENGTH
  validates_format_of       :login_name,    :with => /\A[a-z]{2}( ?\w+)+\z/i, :allow_nil => true, :message =>
  'may only contain letters, numbers, underscores and non-consecutive, non-trailing spaces; must start with at least two letters'

  before_validation         { |u| u.display_name = u.login_name if u.display_name.blank? }
  validates_uniqueness_of   :display_name,  :case_sensitive => false
  validates_length_of       :display_name,  :minimum => MINIMUM_LOGIN_NAME_LENGTH
  validates_format_of       :display_name,  :with => /\A[a-z]{2}( ?\w+)+\z/i, :allow_nil => true, :message =>
  'may only contain letters, numbers, underscores and non-consecutive, non-trailing spaces; must start with at least two letters'

  validates_presence_of     :passphrase,      :on => :create
  validates_length_of       :passphrase,      :minimum => MINIMUM_PASSWORD_LENGTH,  :if => Proc.new { |u| !u.passphrase.blank? }
  validates_confirmation_of :passphrase,      :if => Proc.new { |u| !u.passphrase.blank? }

  validates_each            :old_passphrase,  :on => :update, :if => Proc.new { |u| !u.passphrase.blank? } do |model, att, value|
    # Guard against cookie-capture attacks for passphrase changes.
    # TODO: same for email updates
    record_in_database = User.find(model.id)
    if value.blank? # mimic validates_presence_of
      model.errors.add(att, ActiveRecord::Errors.default_error_messages[:empty])
    elsif User.digest(value, record_in_database.passphrase_salt) != record_in_database.passphrase_hash
      model.errors.add(att, 'must match existing passphrase on record')
      false
    end
    true
  end

  # model the registration event? (email confirmation etc)
  #has_one                   :registration

  #has_many                  :memberships
  #has_many                  :groups,        :through => :memberships

  # the first created user is the superuser
  before_create             { |u| u.superuser = true if User.count == 0 }

  def after_save
    # What happens on User.create, or User.save on a new record?
    #   - Rails runs the :save validations
    #     - validates_length_of :passphrase runs (if passphrase is non-blank)
    #     - validates_confirmation_of :passphrase runs (again, when passphrase is non-blank)
    #   - Rails runs the :create validations because this is a new record
    #     - validates_presence_of :passphrase runs
    #   - the after_save callback is fired and the @passphrase instance variable is cleared;
    #     this prevents the old_passphrase validations from running when not applicable
    #
    # What happens if the user sets a new passphrase on an existing, saved record and then calls user.save?
    #   - Rails runs the :save validations
    #     - validates_length_of :passphrase runs (because passphrase is non-blank)
    #     - validates_confirmation_of :passphrase runs (for the same reason)
    #   - Rails runs the :update validations because this is not a new record
    #     - validates_presence_of :old_passphrase runs (because passphrase is non-blank)
    #     - validates_each :old_passphrase runs (because the passphrase is non-blank);
    #       checks with the database that the old passphrase is correct
    #   - the after_save callback is fired and the @passphrase instance variable is cleared;
    #     this prevents the old_passphrase validations from running when not applicable
    #
    # What happens if we call user.valid? or user.save on a non-new record?
    #   - Rails runs the :save validations
    #     - validates_length_of :passphrase does not run (because the passphrase is now blank)
    #     - validates_confirmation_of :passphrase does not run (because the passphrase is blank)
    #   - Rails runs the :update validations
    #     - validates_presence_of :old_passphrase is skipped (because the passphrase is blank)
    #     - validates_each :old_passphrase is skipped (because the passphrase is blank)
    #
    @passphrase = nil
  end

  # pull in User.digest and User.random_salt from Authentication module
  extend Authentication::Model::ClassMethods

  def self.authenticate(login, passphrase)
    if user = find_by_login_name(login)
      user = nil if user.passphrase_hash != User.digest(passphrase, user.passphrase_salt)
    end
    user
  end

  # Stores a new passphrase_salt and combines it with passphrase to generate and store a new passphrase_hash.
  # Does nothing if passphrase is blank.
  def passphrase=(passphrase)
    return if passphrase.blank?
    @passphrase = passphrase
    salt = User.random_salt
    self.passphrase_salt, self.passphrase_hash = salt, User.digest(passphrase, salt)
  end

end