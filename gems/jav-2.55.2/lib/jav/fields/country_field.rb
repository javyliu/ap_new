module Jav
  module Fields
    class CountryField < BaseField
      include Jav::Fields::FieldExtensions::HasIncludeBlank

      attr_reader :countries, :display_code

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("jav.choose_a_country")

        super

        @countries = begin
          ISO3166::Country.translations.sort_by { |_, name| name }.to_h
        rescue StandardError
          { none: "You need to install the countries gem for this field to work properly" }
        end
        @display_code = args[:display_code].presence || false
      end

      def select_options
        if @display_code
          countries.map do |code, _|
            [code, code]
          end
        else
          countries.map do |code, name|
            [name, code]
          end
        end
      end
    end
  end
end
