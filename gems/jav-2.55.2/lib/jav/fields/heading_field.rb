require 'securerandom'

module Jav
  module Fields
    class HeadingField < BaseField
      attr_reader :as_html, :empty

      def initialize(content, **args, &block)
        # Mark the field as empty if there's no content passed
        @empty = content.blank?
        # Add dummy content
        content ||= SecureRandom.hex

        args[:updatable] = false

        super

        hide_on :index

        @as_html = args[:as_html].presence || false
      end

      def id
        "heading_#{name.to_s.parameterize.underscore}"
      end

      # Override the value method if the field is empty
      def value
        return nil if empty

        super
      end
    end
  end
end
