module Jav
  module Fields
    class HasOneField < HasBaseField
      attr_accessor :relation_method

      def initialize(id, **args, &block)
        hide_on :new, :edit

        super

        @placeholder ||= I18n.t "jav.choose_an_option"

        @relation_method = name.to_s.parameterize.underscore
      end

      def label
        value.send(target_resource.title)
      end

      def resource
        Jav::App.get_resource_by_model_name @model.class
      end

      def frame_url
        args = {
          via_resource_class: @resource.class.name,
          via_resource_id: @resource.model.to_param
        }
        Jav::Services::URIService.parse(@resource.record_path)
                                 .append_paths(id, value.id)
                                 .append_query(turbo_frame: turbo_frame, **args)
                                 .to_s
      end

      def fill_field(model, key, value, params)
        if value.blank?
          related_model = nil
        else
          related_class = model.class.reflections[name.to_s.downcase].class_name
          related_resource = ::Jav::App.get_resource_by_model_name(related_class)
          related_model = related_resource.find_record value
        end

        model.public_send(:"#{key}=", related_model)

        model
      end
    end
  end
end
