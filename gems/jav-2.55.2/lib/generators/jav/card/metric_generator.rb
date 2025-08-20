require_relative "../named_base_generator"

module Generators
  module Jav
    module Card
      class MetricGenerator < Generators::Jav::NamedBaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "jav:card:metric"
        desc "Add a metric card for your Jav dashboard."

        def handle
          template "cards/metric_card_sample.tt", "app/jav/cards/#{name.underscore}.rb"
        end
      end
    end
  end
end
