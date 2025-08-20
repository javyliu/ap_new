require "rails/generators"

module Generators
  module Jav
    class NamedBaseGenerator < ::Rails::Generators::NamedBase
      hide!

      def initialize(name, *options)
        super(name, *options)
        invoke "jav:version", name, *options
      end
    end
  end
end
