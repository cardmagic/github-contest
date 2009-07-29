# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_github-contest_session',
  :secret      => 'f041742e243fd076075a40b38bb81ec9c40c166c4f569662fb766cdd9ab4e0a8ab5fb186e881e420fd72574551d713e836d29ad16249918ebbca39943c5eb883'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
