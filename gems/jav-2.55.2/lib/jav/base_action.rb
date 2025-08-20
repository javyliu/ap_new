module Jav
  class BaseAction
    include Jav::Concerns::HasFields
    include Jav::Concerns::HasActionStimulusControllers

    class_attribute :name, default: nil
    class_attribute :message
    class_attribute :confirm_button_label
    class_attribute :cancel_button_label
    class_attribute :no_confirmation, default: false
    class_attribute :standalone, default: false
    class_attribute :visible
    class_attribute :may_download_file, default: false
    class_attribute :turbo

    attr_accessor :view, :response, :model, :resource, :user
    attr_reader :arguments

    delegate :context, to: ::Jav::App
    delegate :current_user, to: ::Jav::App
    delegate :params, to: ::Jav::App
    delegate :view_context, to: ::Jav::App
    delegate :jav, to: :view_context
    delegate :main_app, to: :view_context

    class << self
      delegate :context, to: ::Jav::App

      def form_data_attributes
        # We can't respond with a file download from Turbo se we disable it on the form
        if may_download_file
          { turbo: turbo || false, remote: false }
        else
          { turbo: turbo, turbo_frame: :_top }.compact
        end
      end

      # We can't respond with a file download from Turbo se we disable close the modal manually after a while (it's a hack, we know)
      def submit_button_data_attributes
        attributes = { action_target: "submit" }

        attributes[:action] = "click->modal#delayedClose" if may_download_file

        attributes
      end
    end

    def action_name
      return name if name.present?

      self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    end

    def initialize(model: nil, resource: nil, user: nil, view: nil, arguments: {})
      @model = model
      @resource = resource
      @user = user
      @view = view
      @arguments = arguments

      self.class.message ||= I18n.t("jav.are_you_sure_you_want_to_run_this_option")
      self.class.confirm_button_label ||= I18n.t("jav.run")
      self.class.cancel_button_label ||= I18n.t("jav.cancel")

      @response ||= {}
      @response[:messages] = []
    end

    def get_message
      if self.class.message.respond_to? :call
        Jav::Hosts::ResourceRecordHost.new(block: self.class.message, record: @model, resource: @resource).handle
      else
        self.class.message
      end
    end

    def handle_action(**args)
      models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)
      # Fetching the field definitions and not the actual fields (get_fields) because they will break if the user uses a `visible` block and adds a condition using the `params` variable. The params are different in the show method and the handle method.
      action_fields = get_field_definitions.index_by(&:id)

      # For some fields, like belongs_to, the id and database_id differ (user vs user_id).
      # That's why we need to fetch the database_id for when we process the action.
      action_fields_by_database_id = action_fields.to_h do |_, value|
        [value.database_id.to_sym, value]
      end

      if fields.present?
        processed_fields = fields.to_unsafe_h.map do |name, value|
          field = action_fields_by_database_id[name.to_sym]

          next if field.blank?

          [name, field.resolve_attribute(value)]
        end

        processed_fields = processed_fields.compact_blank.to_h
      else
        processed_fields = {}
      end

      args = {
        fields: processed_fields.with_indifferent_access,
        current_user: current_user,
        resource: resource
      }

      args[:models] = models unless standalone

      handle(**args)

      self
    end

    def visible_in_view(parent_resource: nil)
      if visible.blank?
        # Hide on the :new view by default
        return false if view == :new

        # Show on all other views
        return true
      end

      # Run the visible block if available
      Jav::Hosts::VisibilityHost.new(
        block: visible,
        params: params,
        parent_resource: parent_resource,
        resource: @resource,
        view: @view,
        arguments: arguments
      ).handle
    end

    def param_id
      self.class.to_s
    end

    def succeed(text)
      add_message text, :success

      self
    end

    def fail(text)
      Rails.logger.warn "DEPRECATION WARNING: Action fail method is deprecated in favor of error method and will be removed from Jav version 3.0.0"

      error text
    end

    def error(text)
      add_message text, :error

      self
    end

    def inform(text)
      add_message text, :info

      self
    end

    def warn(text)
      add_message text, :warning

      self
    end

    def keep_modal_open
      response[:keep_modal_open] = true

      self
    end

    # Add a placeholder silent message from when a user wants to do a redirect action or something similar
    def silent
      add_message nil, :silent

      self
    end

    def redirect_to(path = nil, **args, &block)
      response[:type] = :redirect
      response[:redirect_args] = args
      response[:path] = (block.presence || path)

      self
    end

    def reload
      response[:type] = :reload

      self
    end

    def download(path, filename)
      response[:type] = :download
      response[:path] = path
      response[:filename] = filename

      self
    end

    # We're overriding this method to hydrate with the proper resource attribute.
    def hydrate_fields(model: nil, view: nil)
      fields.map do |field|
        field.hydrate(model: @model, view: @view, resource: resource)
      end

      self
    end

    private

    def add_message(body, type = :info)
      response[:messages] << {
        type: type,
        body: body
      }
    end
  end
end
