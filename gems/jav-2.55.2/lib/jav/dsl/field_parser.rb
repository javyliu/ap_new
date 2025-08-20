module Jav
  module Dsl
    class FieldParser
      attr_reader :as, :args, :id, :block, :instance, :order_index

      def initialize(id:, order_index: 0, **args, &block)
        @id = id
        @as = args.fetch(:as, nil)
        @order_index = order_index
        @args = args
        @block = block
        @instance = nil
      end

      def valid?
        instance.present?
      end

      def invalid?
        !valid?
      end

      def parse
        # The field is passed as a symbol eg: :text, :color_picker, :trix
        @instance = if as.is_a? Symbol
                      parse_from_symbol
                    elsif as.is_a? Class
                      parse_from_class
                    end

        self
      end

      private

      def parse_from_symbol
        field_class = field_class_from_symbol(as)

        if field_class.present?
          # The field has been registered before.
          instantiate_field(id, klass: field_class, **args, &block)
        else
          # The symbol can be transformed to a class and found.
          class_name = as.to_s.camelize
          field_class = "#{class_name}Field"

          # Discover & load custom field classes
          instantiate_field(id, klass: field_class.safe_constantize, **args, &block) if Object.const_defined? field_class
        end
      end

      def parse_from_class
        # The field has been passed as a class.
        return unless Object.const_defined? as.to_s

        instantiate_field(id, klass: as, **args, &block)
      end

      def instantiate_field(id, klass:, **args, &block)
        if block
          klass.new(id, **args || {}, &block)
        else
          klass.new(id, **args || {})
        end
      end

      def field_class_from_symbol(symbol)
        matched_field = Jav::App.fields.find do |field|
          field[:name].to_s == symbol.to_s
        end

        matched_field[:class] if matched_field.present? && matched_field[:class].present?
      end
    end
  end
end
