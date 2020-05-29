module Ufo::Stack::Builder::Resources::Roles
  class Base < Ufo::Stack::Builder::Base
    def build
      return unless self.class.build? # important because it runs DSL#evaluate
      Ufo::Role::Builder.new(self.class.role_type).build
    end


    class << self
      def role_type
        self.name.to_s.split("::").last.underscore
      end

      def build?
        path = "#{Ufo.root}/.ufo/iam_roles/#{role_type}.rb"
        return unless File.exist?(path)
        Ufo::Role::DSL.new(path).evaluate # runs the role.rb and registers items
        Ufo::Role::Builder.new(role_type).build?
      end
    end
  end
end
