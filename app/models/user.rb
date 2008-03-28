class User < ActiveRecord::Base
  MINIMUM_LOGIN_NAME_LENGTH = 3
  MINIMUM_PASSWORD_LENGTH   = 8

  has_many                  :emails, :dependent => :destroy
  has_many                  :issues
  has_many                  :comments
  has_many                  :topics

  attr_reader               :passphrase
  attr_accessor             :passphrase_confirmation, :old_passphrase, :email

  attr_accessible           :display_name, :passphrase, :passphrase_confirmation, :old_passphrase, :email

  # NOTE: validates_uniqueness_of causes an extra SELECT every time you save, one for each attribute whose uniqueness you validate

  validates_uniqueness_of   :display_name,  :case_sensitive => false
  validates_length_of       :display_name,  :minimum => MINIMUM_LOGIN_NAME_LENGTH
  validates_format_of       :display_name,  :with => /\A[a-z]{2}( ?[a-z0-9]+)+\z/i, :allow_nil => true, :message =>
  'may only contain letters, numbers and non-consecutive, non-trailing spaces; must start with at least two letters'

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
  extend ActiveRecord::Authentication::ClassMethods

  # User accounts may have multiple email addresses associated with them,
  # but any of them can be used in combination with the passphrase to authenticate.
  def self.authenticate(email, passphrase)
    if user = find(:first, :include => :emails, :conditions => ['emails.address = ?', email])
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

  def update_emails options = {}
    remove_emails(options[:delete]) unless options[:delete].blank?
    add_email(options[:add]) unless options[:add].blank?
  end

  def add_email address
    emails.build(:address => address)
  end

  # The emails variable should be form input like {"1"=>"1", "408"=>"1"}, meaning "delete emails with ids 1 and 408"
  def remove_emails emails
    emails = emails.collect { |k, v| v == '1' ? k.to_i : nil }.select {|a| !a.nil? }
    Email.update_all(['deleted_at = ?', Time.now], ['user_id = ? AND id IN (?)', self.id, emails]) if emails.length > 0
  end

  def self.find_with_param! param
    # TODO: submit Rails patch which would allow find_by_display_name! as a shorthand for this
    # would need to patch activerecord/lib/active_record/base.rb method_missing for this
    find_by_display_name(deparametrize(param)) || (raise ActiveRecord::RecordNotFound)
  end

  def self.deparametrize string
    string.gsub '-', ' '
  end

  def self.parametrize string
    string.downcase.gsub ' ', '-'
  end

  def to_param
    User.parametrize display_name
  end
end
