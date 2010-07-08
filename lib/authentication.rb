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
      true
    end

    # Intended for use as a before_filter to protect adminstrator-only
    # actions. Optionally takes a block, making it convenient for
    # explicit use within controller actions (the block is only
    # executed if the user is admin).
    def require_admin &block
      if self.admin?
        yield if block_given?
      else
        redirect_to_login 'The requested resource requires administrator privileges'
      end
    end

    # before_filter: requires a logged-in user, but doesn't need the user to be verified yet.
    def require_user
      unless self.logged_in?
        redirect_to_login 'You must be logged in to access the requested resource'
      end
      true
    end

    # Redirect to the login page showing the supplied msg in the flash
    # For non-HTML formats (XML, Atom, JavaScript), return a 403 error instead of redirecting
    def redirect_to_login msg
      # in practice for HTML requests, format is always blank, but program defensively
      if params[:format].blank? or params[:format] =~ /html/i
        flash[:notice] = msg
        session[:original_uri] = request.fullpath
        redirect_to login_path
      else # XML, Atom, JavaScript etc
        render :text => Rack::Utils::HTTP_STATUS_CODES[403], :status => 403 # Forbidden
      end
    end

    # only secure over SSL (due to cookie capture attacks)
    def login_with_cookie
      if cookies[:user_id] and cookies[:session_key]
        user = User.find_by_id_and_session_key(cookies[:user_id], cookies[:session_key])
        if user
          expiry = user.session_expiry
          if expiry and expiry > Time.now
            return user
          end
        end
      end
    end

    # needed for AJAX
    # only secure over SSL
    def login_with_http_basic
      authenticate_with_http_basic do |email, passphrase|
         return User.authenticate(email, passphrase)
      end
    end

    # TODO: allow user to adjust this in their preferences
    DEFAULT_SESSION_EXPIRY = 7 # days

    LOCALHOST_ADDRESSES = ['127.0.0.1', '::1'].freeze

    def local_request?
      ip = request.remote_ip
      LOCALHOST_ADDRESSES.any? { |l| l == ip }
    end

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
        secure_cookies        = !local_request?
        cookies[:user_id]     = { :value => user.id.to_s, :secure =>
          secure_cookies }
        cookies[:session_key] = { :value => user.session_key, :secure =>
          secure_cookies }
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
