# Example ufo/variables/development.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 192
@environment = helper.env_vars(%Q[
  RAILS_ENV=development
  SECRET_KEY_BASE=secret
])
