# Example ufo/variables/prod.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@cpu = 192
@environment = helper.env_vars(%Q{
  RAILS_ENV=staging
  SECRET_KEY_BASE=secret
})
