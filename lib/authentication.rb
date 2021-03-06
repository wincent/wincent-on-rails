require 'base64'
require 'digest/sha2'
require 'openssl'
require 'securerandom'

module ActionController
  module Authentication
    extend ActiveSupport::Concern

    # TODO: allow user to adjust DEFAULT_SESSION_EXPIRY in their preferences?
    DEFAULT_SESSION_EXPIRY  = 7 # days
    SESSION_KEY_LENGTH      = 128
    LOCALHOST_ADDRESSES     = ['127.0.0.1', '::1'].freeze

    included do
      helper_method :logged_in?
      helper_method :logged_in_and_verified?
      helper_method :admin?
      helper_method :current_user
    end

  protected

    # Intended for use as a before_filter in the ApplicationController for all
    # actions.
    def log_in_before
      self.current_user = log_in_with_cookie || log_in_with_http_basic
    end

    # Intended for use as a before_filter.
    def require_admin
      unless admin?
        redirect_to_login 'The requested resource requires administrator privileges'
      end
    end

    # before_filter: require a logged-in (not necessarily verified) user
    def require_user
      unless logged_in?
        redirect_to_login 'You must be logged in to access the requested resource'
      end
    end

    def local_request?
      ip = request.remote_ip
      LOCALHOST_ADDRESSES.any? { |l| l == ip }
    end

    # Called by controllers to log the user in or out (for example, in response
    # to a form submission).
    # Compare with the #current_user= method, which is used only internally, to
    # set up an already-logged-in user (via a cookie or other automatic mechanism).
    def set_current_user user
      self.current_user = user
      return unless user
      user.session_key      = random_session_key
      user.session_expiry   = DEFAULT_SESSION_EXPIRY.days.from_now
      user.save
      secure_cookies        = !local_request?
      cookies[:user_id]     = { value: user.id.to_s,     secure: secure_cookies }
      cookies[:session_key] = { value: user.session_key, secure: secure_cookies }
    end

    # Internal use only (see notes for #set_current_user method)
    def current_user= user
      if user
        # don't trust Rails' session management; manually manage the relevant
        # cookies here (Rails sets a session key but doesn't tie it to the
        # user id, making session fixation attacks a little easier)
        @current_user = user
      else
        if user = current_user
          user.update_attribute :session_key, nil
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
      logged_in? && current_user.verified?
    end

    def logged_in?
      !current_user.nil?
    end

    def admin?
      logged_in? && current_user.superuser?
    end

  private

    # only secure over SSL (due to cookie capture attacks)
    def log_in_with_cookie
      if cookies[:user_id] && cookies[:session_key]
        user = User.find_by(
          id: cookies[:user_id],
          session_key: cookies[:session_key],
          suspended: false
        )
        if user
          expiry = user.session_expiry
          if expiry && expiry > Time.now
            user
          end
        end
      end
    end

    # needed for AJAX
    # only secure over SSL
    def log_in_with_http_basic
      authenticate_with_http_basic do |email, passphrase|
         return User.authenticate(email, passphrase)
      end
    end

    # Generate a random string for use as a session key.
    def random_session_key
      SecureRandom::base64(SESSION_KEY_LENGTH)
    end

    # Redirect to the login page showing the supplied msg in the flash
    # For non-HTML formats (XML, JavaScript), return a 403 error instead of redirecting
    def redirect_to_login msg
      if request.format && request.format.html?
        flash[:notice] = msg
        session[:original_uri] = request.fullpath
        redirect_to login_path
      else # XML, JavaScript etc
        render text: Rack::Utils::HTTP_STATUS_CODES[403], status: 403 # Forbidden
      end
    end
  end # module Authentication
end # module ActionController

module ActiveRecord
  module Authentication
    extend ActiveSupport::Concern

    module ClassMethods
      PASSPHRASE_CHARS            = 'abcdefghjkmnpqrstuvwxyz23456789'.split(//)
      PASSPHRASE_CHARS_LENGTH     = PASSPHRASE_CHARS.length
      GENERATED_PASSPHRASE_LENGTH = 8
      SALT_BYTES                  = 128

      # Returns a psuedo-random string of length letters and digits, excluding potentially ambiguous characters (0, O, 1, l, I).
      def random_string(length)
        Array.new(length) do
          PASSPHRASE_CHARS[SecureRandom::random_number(PASSPHRASE_CHARS_LENGTH)]
        end.join
      end

      # Generates a psuedo-random passphrase string.
      def passphrase
        random_string(GENERATED_PASSPHRASE_LENGTH)
      end

      # Returns a psuedo-random salt string.
      def random_salt
        SecureRandom::base64(SALT_BYTES)
      end

      # Returns the version number of the current digest scheme.
      #
      # This is a separate method rather than a constant so we can mock it in
      # the test suite.
      def digest_version
        1
      end

      # Returns a digest based on passphrase and salt.
      #
      # Note that this method must be called "digest" rather than "hash" to
      # avoid overriding the built-in hash method.
      def digest(passphrase, salt, version = digest_version)
        raise ArgumentError, 'nil passphrase' if passphrase.nil?
        raise ArgumentError, 'nil salt' if salt.nil?

        case version
        when 0
          Digest::SHA256.hexdigest(passphrase + salt)
        when 1
          Base64::encode64(
            OpenSSL::PKCS5.pbkdf2_hmac_sha1(
              passphrase,
              salt,
              10_000, # iterations
              128     # key_len
            )
          )
        else
          raise ArgumentError, "Unknown digest version #{digest_version.inspect}"
        end
      end
    end # module ClassMethods
  end # module Authentication
end # module ActiveRecord

# controller methods are included automatically because we want them to be
# available to all controllers
# the model methods must be extended manually in specific models that want
# them as they are specific to those models only
ActionController::Base.class_eval { include ActionController::Authentication }
