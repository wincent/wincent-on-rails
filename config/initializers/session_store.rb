# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_src_session',
  :secret      => '3d8a7fcf2e859a93579e1aee27feeeb51bf3f0d7784345eb716a45bcb085133ee7bb143b591fb209d6ee0ee79f9fa0b3bd96ca6bf612ee40eb9923215cf9cd67'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
