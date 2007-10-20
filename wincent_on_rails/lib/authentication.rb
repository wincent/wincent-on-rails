require 'digest/sha2'

module Authentication
  module Model
    module ClassMethods
      PASSWORD_CHARS            = 'abcdefghjkmnpqrstuvwxyz23456789'.split(//)
      PASSWORD_CHARS_LENGTH     = PASSWORD_CHARS.length

      # Returns a psuedo-random string of length letters and digits, excluding potentially ambiguous characters (0, O, 1, l, I).
      def random_string(length)
        Array.new(length) { PASSWORD_CHARS[rand(PASSWORD_CHARS_LENGTH)] }.join
      end

      GENERATED_PASSWORD_LENGTH = 8

      # Generates a psuedo-random passphrase string.
      def passphrase
        random_string(GENERATED_PASSWORD_LENGTH)
      end

      SALT_BYTES = 16

      # Returns a psuedo-random salt string.
      def random_salt
        Authentication::random_base64_string(SALT_BYTES)
      end

      # Returns a digest based on passphrase and salt.
      # Note that this method must be called "digest" rather than "hash" to avoid overriding the built-in hash method.
      def digest(passphrase, salt)
        Digest::SHA256.hexdigest(passphrase + salt)
      end
    end # module ClassMethods
  end # module Model

  module Controller
    module ClassMethods
      SESSION_KEY_LENGTH        = 32

      # Generate a random string for use as a session key.
      def random_session_key
        random_base64_string(SESSION_KEY_LENGTH)
      end
    end # module ClassMethods

    module InstanceMethods
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
          user.session_key      = cookies[:session_key] = User.random_session_key
          user.session_expiry   = DEFAULT_SESSION_EXPIRY.days.from_now
          # BUG: session_key and session_expiry don't seem to be getting set in the database
          # doing a user.save here has no apparent effect
        else
          @current_user = session[:user_id] = cookies[:user_id] = nil
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
    end # module InstanceMethods
  end # module Controller

  # Returns a psuedo-random base64-encoded string of length, suitable for storage in a database.
  def self.random_base64_string(length)
    blocks              = length / 4          # base64 outputs in blocks of 4 bytes
    source_chars_needed = blocks * 3          # 3 source bytes needed for each output block
    overflow            = length % 4          # extra bytes needed after last full block
    source_chars_needed += 1 if overflow > 0  # create extra block if needed to handle overflow
    [Array.new(source_chars_needed) { rand(256).chr }.join].pack('m').slice(0, length)
  end

end # module Authentication
