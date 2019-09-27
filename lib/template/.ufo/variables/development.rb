# Example ufo/variables/development.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 256
# Refer to https://github.com/tongueroo/ufo/issues/87 as to why the += is used
@environment += helper.env_vars(%Q[
  RAILS_ENV=development
  SECRET_KEY_BASE=secret
])
