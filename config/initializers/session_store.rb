# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_seentags_session',
  :secret      => '40b581f24c1b7501a0047a2c64a6853bb5410124ff7ca7deab818019dbbcfcbffdbfed7b2e488a7b13c56a91ef1385ae76f13476571cf7f3b245daff4e0ea5d0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
