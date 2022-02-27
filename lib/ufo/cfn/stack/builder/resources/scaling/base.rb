module Ufo::Cfn::Stack::Builder::Resources::Scaling
  class Base < Ufo::Cfn::Stack::Builder::Base
    include Ufo::Concerns::Autoscaling
  end
end
