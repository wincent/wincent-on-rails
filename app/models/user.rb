class User < ActiveRecord::Base
  MINIMUM_DISPLAY_NAME_LENGTH = 3
  MINIMUM_PASSPHRASE_LENGTH   = 8

  has_many                  :comments
  has_many                  :emails, dependent: :destroy
  has_many                  :issues
  has_many                  :monitorships, dependent: :destroy
  has_many                  :topics

  attr_reader               :passphrase
  attr_accessor             :passphrase_confirmation, :old_passphrase, :email, :resetting_passphrase
  attr_accessible           :display_name, :passphrase, :passphrase_confirmation, :old_passphrase, :email

  # NOTE: validates_uniqueness_of causes an extra SELECT every time you save, one for each attribute whose uniqueness you validate

  validates_presence_of     :display_name
  validates_uniqueness_of   :display_name,  case_sensitive: false
  validates_length_of       :display_name,  minimum: MINIMUM_DISPLAY_NAME_LENGTH
  validates_format_of       :display_name,
    with: /\A[a-z]{2}( ?[a-z0-9]+)+\z/i,
    allow_nil: true,
    message: 'may only contain letters, numbers and non-consecutive, non-trailing spaces; must start with at least two letters'
  # TODO: rather than reject leading and trailing spaces, should just trim them

  validates_presence_of     :passphrase, if: -> (u) { u.new_record? || u.resetting_passphrase }
  validates_length_of       :passphrase,
    minimum: MINIMUM_PASSPHRASE_LENGTH,
    if: -> (u) { u.passphrase.present? }
  validates_confirmation_of :passphrase, if: -> (u) { u.passphrase.present? }

  validates_each :old_passphrase,
    on: :update,
    if: -> (u) { u.passphrase.present? && !u.resetting_passphrase } do |model, att, value|
    # Guard against cookie-capture attacks for passphrase changes.
    # TODO: same for email updates
    record_in_database = User.find(model.id)
    if value.blank? # mimic validates_presence_of
      model.errors.add att, I18n.translate('activerecord.errors.messages')[:empty]
    elsif User.digest(value, record_in_database.passphrase_salt) != record_in_database.passphrase_hash
      model.errors.add att, 'must match existing passphrase on record'
    end
  end

  set_callback  :save,      :after, :clear_passphrase
  set_callback  :validate,  :after, :check_association_errors

  # pull in User.digest and User.random_salt from Authentication module
  include ActiveRecord::Authentication

  def self.find_by_email(email)
    return nil if email.blank?
    Email.where(address: email).includes(:user).references(:user).first.try(:user)
  end

  # User accounts may have multiple email addresses associated with them,
  # but any of them can be used in combination with the passphrase to authenticate.
  # Returns the user instance on success.
  def self.authenticate email, passphrase
    # TODO: prevent banned users from logging in
    if (user = find_by_email email) and user.passphrase_hash == User.digest(passphrase, user.passphrase_salt)
      user # TODO: could later add last_login update here
    else
      nil
    end
  end

  # Stores a new passphrase_salt and combines it with passphrase to generate and store a new passphrase_hash.
  # Does nothing if passphrase is blank.
  def passphrase= passphrase
    return if passphrase.blank?
    @passphrase = passphrase
    salt = User.random_salt
    self.passphrase_salt, self.passphrase_hash = salt, User.digest(passphrase, salt)
  end

  def utterances_count
    # later on this will also include self.issues_count
    self.comments_count + self.topics_count
  end

  def self.find_with_param! param
    find_by_display_name!(deparametrize(param))
  end

  def self.deparametrize string
    string.gsub '-', ' '
  end

  def self.parametrize string
    string and string.downcase.gsub(' ', '-')
  end

  def to_param
    param = (changes['display_name'] && changes['display_name'].first)
    User.parametrize(param || display_name)
  end

  # make `link_to(user, user)` do something reasonable
  def to_s
    display_name
  end

private

  def clear_passphrase
    # What happens on User.create, or User.save on a new record?
    #   - Rails runs the "save" validations
    #     - validates_length_of :passphrase runs (if passphrase is non-blank)
    #     - validates_confirmation_of :passphrase runs (again, when passphrase
    #       is non-blank)
    #   - Rails runs the "create" validations because this is a new record
    #     - validates_presence_of :passphrase runs
    #   - the after_save callback is fired and the @passphrase instance
    #     variable is cleared; this prevents the old_passphrase validations
    #     from running when not applicable
    #
    # What happens if the user sets a new passphrase on an existing, saved
    # record and then calls user.save?
    #   - Rails runs the :save validations
    #     - validates_length_of :passphrase runs (because passphrase is
    #       non-blank)
    #     - validates_confirmation_of :passphrase runs (for the same reason)
    #   - Rails runs the :update validations because this is not a new record
    #     - validates_presence_of :old_passphrase runs (because passphrase is
    #       non-blank)
    #     - validates_each :old_passphrase runs (because the passphrase is
    #       non-blank); checks with the database that the old passphrase is
    #       correct
    #   - the after_save callback is fired and the @passphrase instance
    #     variable is cleared; this prevents the old_passphrase validations
    #     from running when not applicable
    #
    # What happens if we call user.valid? or user.save on a non-new record?
    #   - Rails runs the :save validations
    #     - validates_length_of :passphrase does not run (because the
    #       passphrase is now blank)
    #     - validates_confirmation_of :passphrase does not run (because the
    #       passphrase is blank)
    #   - Rails runs the :update validations
    #     - validates_presence_of :old_passphrase is skipped (because the
    #       passphrase is blank)
    #     - validates_each :old_passphrase is skipped (because the passphrase
    #       is blank)
    @passphrase = nil
  end

  def check_association_errors
    unless errors[:emails].blank?
      # want error to read "Email is invalid", not "Emails is invalid"
      errors[:emails].each { |e| errors.add :email, e }
      errors.messages.delete :emails # seems hacky, would like to avoid
    end
  end
end
