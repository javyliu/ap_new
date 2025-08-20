require 'rails/generators'
require 'rails/generators/rails/model/model_generator'

module Rails
  module Generators
    class ModelGenerator
      hook_for :jav_resource, type: :boolean, default: true unless ARGV.include?("--skip-jav-resource")
    end
  end
end
