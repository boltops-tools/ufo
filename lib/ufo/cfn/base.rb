module Ufo::Cfn
  class Base < Ufo::CLI::Base
    extend Memoist
    include Ufo::AwsServices
    include Ufo::Concerns # info
  end
end
