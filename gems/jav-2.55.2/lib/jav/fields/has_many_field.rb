module Jav
  module Fields
    class HasManyField < HasBaseField
      def initialize(id, **args, &block)
        args[:updatable] = false

        hide_on :all
        show_on Jav.configuration.resource_default_view

        super
      end

      def frame_url
        args = {
          via_resource_class: @resource.class.name,
          via_resource_id: @resource.model.to_param
        }
        args[:active_tab_name] = view_context.params[:active_tab_name] if view_context.params[:active_tab_name].present?
        Jav::Services::URIService.parse(@resource.record_path)
                                 .append_paths(id.to_s)
                                 .append_query(turbo_frame: turbo_frame, **args)
                                 .to_s
      end
    end
  end
end
