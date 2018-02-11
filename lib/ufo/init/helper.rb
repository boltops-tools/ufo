module Ufo::Init::Helper
  private # all helpers need to be private or it'll be called by Thor::Group

  def project_class_name
    project_name.underscore.camelize
  end

  # Files should be named with underscores instead of dashes even
  # though project name can contain a dash. This is because autoloading
  # works will underscores in the filenames only.
  def underscored_name
    project_name.underscore
  end

  # project_name is also available from new.rb:
  #   argument :project_name
end
