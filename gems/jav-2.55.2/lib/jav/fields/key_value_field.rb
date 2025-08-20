require "json"

module Jav
  module Fields
    class KeyValueField < BaseField
      attr_reader :disable_editing_keys, :disable_adding_rows

      def initialize(id, **args, &block)
        super

        hide_on :index

        @key_label = args[:key_label]
        @value_label = args[:value_label]
        @action_text = args[:action_text]
        @delete_text = args[:delete_text]

        @disable_editing_keys = args[:disable_editing_keys].presence || false
        # disabling editing keys also disables adding rows (doesn't take into account the value of disable_adding_rows)
        @disable_adding_rows = args[:disable_adding_rows].presence || false
        @disable_deleting_rows = args[:disable_deleting_rows].presence || false
      end

      def key_label
        return @key_label if @key_label.present?

        I18n.t("jav.key_value_field.key")
      end

      def value_label
        return @value_label if @value_label.present?

        I18n.t("jav.key_value_field.value")
      end

      def action_text
        return @action_text if @action_text.present?

        I18n.t("jav.key_value_field.add_row")
      end

      def delete_text
        return @delete_text if @delete_text.present?

        I18n.t("jav.key_value_field.delete_row")
      end

      def to_permitted_param
        [:"#{id}", { "#{id}": {} }]
      end

      def parsed_value
        value.to_json
      rescue StandardError
        {}
      end

      def disable_editing_keys
        if @disable_editing_keys.respond_to?(:call)
          instance_exec(@view, &@disable_editing_keys)
        else
          @disable_editing_keys
        end
      end

      def disable_adding_rows
        disable_editing_keys || @disable_adding_rows
      end

      def options
        {
          key_label: key_label,
          value_label: value_label,
          action_text: action_text,
          delete_text: delete_text,
          disable_editing_keys: disable_editing_keys,
          disable_adding_rows: disable_adding_rows,
          disable_deleting_rows: disable_editing_keys || @disable_deleting_rows
        }
      end

      def fill_field(model, key, value, params)
        begin
          new_value = JSON.parse(value)
        rescue StandardError
          new_value = {}
        end

        model.send(:"#{key}=", new_value)

        model
      end
    end
  end
end
