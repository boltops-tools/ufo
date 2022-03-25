module Ufo::Cfn::Stack::Builder::Resources::IamRoles
  class Base < Ufo::Cfn::Stack::Builder::Base
    def build
      return unless self.class.build? # important because it runs Dsl#evaluate
      Ufo::IamRole::Builder.new(self.class.role_type).build
    end

    class << self
      def role_type
        self.name.to_s.split("::").last.underscore
      end

      def build?
        path = lookup_path
        return unless path.nil? || File.exist?(path)
        Ufo::IamRole::Dsl.new(path).evaluate # runs the role.rb and registers items
        Ufo::IamRole::Builder.new(role_type).build?
      end

      def lookup_path
        iam_roles = "#{Ufo.root}/.ufo/resources/iam_roles"
        paths = ["#{Ufo.app}/#{role_type}", "#{role_type}"]
        paths.map! do |path|
          "#{iam_roles}/#{path}.rb"
        end
        paths.find do |path|
          File.exist?(path)
        end
      end
    end
  end
end
