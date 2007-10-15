require 'digest/sha2'

module Authentication

  # Returns a psuedo-random base64-encoded string of length, suitable for storage in a database.
  def self.random_base64_string(length)
    blocks              = length / 4          # base64 outputs in blocks of 4 bytes
    source_chars_needed = blocks * 3          # 3 source bytes needed for each output block
    overflow            = length % 4          # extra bytes needed after last full block
    source_chars_needed += 1 if overflow > 0  # create extra block if needed to handle overflow
    [Array.new(source_chars_needed) { rand(256).chr }.join].pack('m').slice(0, length)
  end

  SESSION_KEY_LENGTH        = 32

  # Generate a random string for use as a session key.
  def self.random_session_key
    random_base64_string(SESSION_KEY_LENGTH)
  end

  # Returns a digest based on passphrase and salt.
  # Note that this method must be called "digest" rather than "hash" to avoid overriding the built-in hash method.
  def self.digest(passphrase, salt)
    Digest::SHA256.hexdigest(passphrase + salt)
  end

protected

  # Intended for use as a before_filter in the ApplicationController.
  def login_with_session_key
    unless logged_in?
      if cookies[:user_id] and cookies[:session_key]
        user = User.find_by_id_and_session_key(cookies[:user_id], cookies[:session_key])
        self.current_user = user if user.session_expiry > Time.now
      end
    end
    true
  end

  # Intended for use as a before_filter to protect adminstrator-only actions.
  def require_admin
    admin?
  end

  # Intended for use as a before_fitler to protect actions that are only for logged-in users.
  def require_user
    logged_in?
  end

  # TODO: allow user to adjust this in their preferences
  DEFAULT_SESSION_EXPIRY = 7 # days

  def current_user=(user)
    if user
      session[:user_id]     = cookies[:user_id]     = user.id.to_s
      user.session_key      = cookies[:session_key] = Authentication.random_session_key
      user.session_expiry   = DEFAULT_SESSION_EXPIRY.days.from_now
      # BUG: session_key and session_expiry don't seem to be getting set in the database
      # doing a user.save here has no apparent effect
    else
      session[:user_id]     = cookies[:user_id]     = nil
    end
  end

  def current_user
    @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end

  def logged_in?
    not current_user.nil?
  end

  def admin?
    logged_in? && current_user.superuser?
  end

end
