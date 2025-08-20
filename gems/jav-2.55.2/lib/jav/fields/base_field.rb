module Jav
  module Fields
    class BaseField
      extend ActiveSupport::DescendantsTracker
      extend Jav::Fields::FieldExtensions::HasFieldName

      include Jav::Concerns::IsResourceItem
      include Jav::Concerns::HandlesFieldArgs

      include ActionView::Helpers::UrlHelper
      include Jav::Fields::FieldExtensions::VisibleInDifferentViews

      include Jav::Concerns::HasHTMLAttributes
      include Jav::Fields::Concerns::IsRequired
      include Jav::Fields::Concerns::IsReadonly
      include Jav::Fields::Concerns::IsDisabled
      include Jav::Fields::Concerns::HasDefault

      delegate :view_context, to: ::Jav::App
      delegate :simple_format, :content_tag, to: :view_context
      delegate :main_app, to: :view_context
      delegate :jav, to: :view_context
      delegate :t, to: ::I18n

      attr_reader :id, :block, :required, :readonly, :sortable, :nullable, :null_values, :format_using, :autocomplete, :help, :default, :visible, :as_label, :as_avatar, :as_description, :index_text_align, :stacked, :in_sidebar, :computed, :computed_value, :view, :resource, :action, :user, :panel_name

      # Private options
      attr_reader :computable # if allowed to be computable # if block is present # the value after computation

      # Hydrated payload
      attr_reader :model

      class_attribute :field_name_attribute
      class_attribute :item_type, default: :field

      def initialize(id, **args, &block)
        super
        @id = id
        @name = args[:name]
        @translation_key = args[:translation_key]
        @block = block
        @required = args[:required] # Value if :required present on args, nil otherwise
        @readonly = args[:readonly] || false
        @disabled = args[:disabled] || false
        @sortable = args[:sortable] || false
        @nullable = args[:nullable] || false
        @null_values = args[:null_values] || [nil, ""]
        @format_using = args[:format_using] || nil
        @update_using = args[:update_using] || nil
        @placeholder = args[:placeholder]
        @autocomplete = args[:autocomplete] || nil
        @help = args[:help] || nil
        @default = args[:default] || nil
        @visible = args[:visible]
        @as_label = args[:as_label] || false
        @as_avatar = args[:as_avatar] || false
        @as_description = args[:as_description] || false
        @index_text_align = args[:index_text_align] || :left
        @html = args[:html] || nil
        @view = args[:view] || nil
        @value = args[:value] || nil
        @stacked = args[:stacked] || nil
        @resource = args[:resource]
        @action = args[:action]
        @in_sidebar = args[:in_sidebar]

        @args = args

        @computable = true
        @computed = block.present?
        @computed_value = nil

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?
      end

      def hydrate(**kwargs)
        # List of permitted keyword argument keys as symbols
        permited_kwargs_keys = %i[model resource action view panel_name user]

        # Check for unrecognized keys
        unrecognized_keys = kwargs.keys - permited_kwargs_keys
        raise ArgumentError, "Unrecognized argument(s): #{unrecognized_keys.join(', ')}" if unrecognized_keys.any?

        # Set instance variables with provided values
        kwargs.each do |key, value|
          instance_variable_set(:"@#{key}", value)
        end

        # Return self for method chaining, if desired
        self
      end

      def translation_key
        return @translation_key if @translation_key.present?

        "jav.field_translations#{@args[:translation_scope]}.#{@id}"
      end

      # Getting the name of the resource (user/users, post/posts)
      # We'll first check to see if the user passed a name
      # Secondly we'll try to find a translation key
      # We'll fallback to humanizing the id
      def name
        return @name if custom_name?

        if translation_key && ::Jav::App.translation_enabled
          t(translation_key, count: 1, default: default_name).humanize
        else
          default_name
        end
      end

      def plural_name
        default = name.pluralize

        if translation_key && ::Jav::App.translation_enabled
          t(translation_key, count: 2, default: default).humanize
        else
          default
        end
      end

      def custom_name?
        @name.present?
      end

      def default_name
        @id.to_s.humanize(keep_id_suffix: true)
      end

      def placeholder
        return Jav::Hosts::ResourceViewRecordHost.new(block: @placeholder, record: @model, resource: @resource, view: @view).handle if @placeholder.respond_to?(:call)

        @placeholder || name
      end

      def visible?
        return true if visible.nil?

        if visible.respond_to?(:call)
          visible.call resource: @resource
        else
          visible
        end
      end

      def value(property = nil)
        return @value if @value.present?

        property ||= id

        # Get model value
        final_value = @model.send(property) if is_model?(@model) && @model.respond_to?(property)

        # On new views and actions modals we need to prefill the fields with the default value
        final_value = computed_default_value if should_fill_with_default_value? && default.present?

        # Run computable callback block if present
        final_value = instance_exec(@model, @resource, @view, self, &block) if computable && block.present?

        if @format_using.present?
          # Apply the changes in the
          Jav::ExecutionContext.new(
            target: @format_using,
            model: model,
            key: property,
            value: final_value,
            resource: resource,
            view: view,
            field: self,
            delegate_missing_to: :view_context,
            include: self.class.included_modules
          ).handle
        else
          final_value
        end
      end

      # Fills the model with the received value on create and update actions.
      def fill_field(model, key, value, params)
        return model unless model.methods.include? key.to_sym

        value = update_using(model, key, value, params) if @update_using.present?

        model.public_send(:"#{key}=", value)

        model
      end

      def update_using(model, key, value, params)
        Jav::ExecutionContext.new(
          target: @update_using,
          model: model,
          key: key,
          value: value,
          resource: resource,
          field: self,
          include: self.class.included_modules
        ).handle
      end

      # Try to see if the field has a different database ID than it's name
      def database_id
        foreign_key
      rescue StandardError
        id
      end

      def has_own_panel?
        false
      end

      def resolve_attribute(value)
        value
      end

      def to_permitted_param
        id.to_sym
      end

      def view_component_name
        "#{type.camelize}Field"
      end

      # Try and build the component class or fallback to a blank one
      def component_for_view(view = :index)
        # Use the edit variant for all "update" views
        view = :edit if view.in? %i[new create update]

        component_class = "::Jav::Fields::#{view_component_name}::#{view.to_s.camelize}Component"
        component_class.constantize
      rescue StandardError
        # When returning nil, a race condition happens and throws an error in some environments.
        # See https://github.com/jav-hq/jav/pull/365
        ::Jav::BlankFieldComponent
      end

      def model_errors
        model.nil? ? {} : model.errors
      end

      def type
        self.class.name.demodulize.to_s.underscore.gsub("_field", "")
      end

      def custom?
        method(:initialize).source_location.first.exclude?("lib/jav/field")
      rescue StandardError
        true
      end

      def visible_in_reflection?
        true
      end

      def hidden_in_reflection?
        !visible_in_reflection?
      end

      def updatable
        !is_readonly? && visible?
      end

      # Used by Jav to fill the record with the default value on :new and :edit views
      def assign_value(record:, value:)
        id = type == "belongs_to" ? foreign_key : database_id

        return unless record.send(id).nil?

        record.send(:"#{id}=", value)
      end

      private

      def model_or_class(model)
        model.instance_of?(String) ? "class" : "model"
      end

      def is_model?(model)
        model_or_class(model) == "model"
      end

      def should_fill_with_default_value?
        on_create? || in_action?
      end

      def on_create?
        @view.in?(%i[new create])
      end

      def in_action?
        @action.present?
      end
    end
  end
end
