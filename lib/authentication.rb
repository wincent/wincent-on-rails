require 'digest/sha2'

module AuthenticationUtilities
  # Returns a psuedo-random base64-encoded string of length, suitable for storage in a database.
  def self.random_base64_string(length)
    blocks              = length / 4          # base64 outputs in blocks of 4 bytes
    source_chars_needed = blocks * 3          # 3 source bytes needed for each output block
    overflow            = length % 4          # extra bytes needed after last full block
    source_chars_needed += 1 if overflow > 0  # create extra block if needed to handle overflow
    [Array.new(source_chars_needed) { rand(256).chr }.join].pack('m').slice(0, length)
  end
end # module AuthenticationUtilities

module ActionController
  module Authentication
    def self.included base
      base.class_eval do
        helper_method :logged_in?
        helper_method :logged_in_and_verified?
        helper_method :admin?
        helper_method :current_user
      end
      base.extend(ClassMethods)
    end

    module ClassMethods
      SESSION_KEY_LENGTH = 32

      # Generate a random string for use as a session key.
      def random_session_key
        AuthenticationUtilities::random_base64_string(SESSION_KEY_LENGTH)
      end
    end # module ClassMethods

  protected

    # Intended for use as a before_filter in the ApplicationController for all actions.
    def login_before
      self.current_user = self.login_with_cookie or self.login_with_http_basic
    end

    # Intended for use as a before_filter to protect adminstrator-only actions.
    def require_admin
      unless self.admin?
        flash[:notice]          = 'The requested resource requires administrator privileges'
        session[:original_uri]  = request.request_uri
        redirect_to login_url
      end
    end

    # Intended for use as a before_filter to protect actions that are only for logged-in, verified users.
    def require_verified
      if !self.logged_in?
        redirect_to_login
      elsif !self.logged_in_and_verified?
        flash[:notice]          = 'You must verify your account before accessing the requested resource'
        redirect_to new_confirmation_url
      end
    end

    # before_filter: requires a logged-in user, but doesn't need the user to be verified yet.
    def require_user
      redirect_to_login unless self.logged_in?
    end

    def redirect_to_login
      flash[:notice]          = 'You must be logged in to access the requested resource'
      session[:original_uri]  = request.request_uri
      redirect_to login_url
    end

    # only secure over SSL (due to cookie capture attacks)
    def login_with_cookie
      if cookies[:user_id] and cookies[:session_key]
        # we're not vulnerable to session fixation attacks because
        # 1. we use a server-generated session key
        # 2. it only works if paired with the correct user_id
        # 3. upon successful login the session key is immediately updated anyway (in self.set_current_user)
        # 4. we destroy old sessions on logout (including invalidating the old session key in the database)
        # 5. we expire old sessions
        # Additional measures would be possible (see below), but what's implemented here is probably more than
        # enough for a "defense in depth" strategy.
        # - store user agent in new sessions and bail if it changes during the session
        # - check referrer and possibly bail if it's external
        # See: http://en.wikipedia.org/wiki/Session_fixation
        user = User.find_by_id_and_session_key(cookies[:user_id], cookies[:session_key])
        if user
          expiry = user.session_expiry
          if expiry and expiry > Time.now
            return user
          end
        end
      end
      nil
    end

    # needed for AJAX
    # only secure over SSL
    def login_with_http_basic
      authenticate_with_http_basic do |email, passphrase|
         return User.authenticate(email, passphrase)
      end
      nil
    end

    # TODO: allow user to adjust this in their preferences
    DEFAULT_SESSION_EXPIRY = 7 # days

    # this does a little bit more than the current_user= method
    # (which just sets the @current_user instance variable)
    # this is intended to be called from the SessionsController,
    # whereras the current_user= method is suitable for being called from a before filter
    def set_current_user=(user)
      self.current_user = user
      if user
        user.session_key      = self.class.random_session_key
        user.session_expiry   = DEFAULT_SESSION_EXPIRY.days.from_now
        user.save
        cookies[:user_id]     = { :value => user.id.to_s, :secure => true }
        cookies[:session_key] = { :value => user.session_key, :secure => true }
      end
    end

    def current_user=(user)
      if user
        # don't trust Rails' session management; manually manage the relevant cookies here
        # (Rails sets a session key but doesn't tie it to the user id, making session fixation attacks a little easier)
        @current_user = user
      else
        if user = self.current_user
          user.update_attribute(:session_key, nil)
        end
        @current_user = nil
        cookies.delete :user_id
        cookies.delete :session_key
      end
    end

    def current_user
      @current_user
    end

    def logged_in_and_verified?
      self.logged_in? && self.current_user.verified?
    end

    def logged_in?
      not self.current_user.nil?
    end

    def admin?
      self.logged_in? && self.current_user.superuser?
    end

  end # module Authentication
end # module ActionController

module ActiveRecord
  module Authentication
    module ClassMethods
      PASSPHRASE_CHARS        = 'abcdefghjkmnpqrstuvwxyz23456789'.split(//)
      PASSPHRASE_CHARS_LENGTH = PASSPHRASE_CHARS.length

      # Returns a psuedo-random string of length letters and digits, excluding potentially ambiguous characters (0, O, 1, l, I).
      def random_string(length)
        Array.new(length) { PASSPHRASE_CHARS[rand(PASSPHRASE_CHARS_LENGTH)] }.join
      end

      GENERATED_PASSPHRASE_LENGTH = 8

      # Generates a psuedo-random passphrase string.
      def passphrase
        random_string(GENERATED_PASSPHRASE_LENGTH)
      end

      SALT_BYTES = 16

      # Returns a psuedo-random salt string.
      def random_salt
        AuthenticationUtilities::random_base64_string(SALT_BYTES)
      end

      # Returns a digest based on passphrase and salt.
      # Note that this method must be called "digest" rather than "hash" to avoid overriding the built-in hash method.
      def digest(passphrase, salt)
        Digest::SHA256.hexdigest(passphrase + salt)
      end
    end # module ClassMethods
  end # module Authentication
end # module ActiveRecord

# controller methods are included automatically because we want them to be available to all controllers
# the model methods must be extended manually in specific models that want them as they are specific to those models only
ActionController::Base.class_eval { include ActionController::Authentication }
