require_relative "../named_base_generator"

module Generators
  module Jav
    module Card
      class PartialGenerator < Generators::Jav::NamedBaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "jav:card:partial"
        desc "Add a partial card for your Jav dashboard."

        def handle
          template "cards/partial_card_sample.tt", "app/jav/cards/#{name.underscore}.rb"
          template "cards/partial_card_partial.tt", "app/views/jav/cards/_#{name.underscore}.html.erb"
        end
      end
    end
  end
end
