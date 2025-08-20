require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class JavResourceGenerator < ::Rails::Generators::Base
      def invoke_jav_command
        invoke "jav:resource", @args, {from_model_generator: true}
      end
    end
  end
end
