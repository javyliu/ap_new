module Jav
  module ApplicationHelper
    include ::Pagy::Frontend

    def render_license_warnings
      render partial: 'jav/sidebar/license_warnings', locals: {
        license: Jav::App.license.properties
      }
    end

    def render_license_warning(title: '', message: '', icon: 'exclamation')
      render partial: 'jav/sidebar/license_warning', locals: {
        title: title,
        message: message,
        icon: icon
      }
    end

    def empty_state(**args)
      render Jav::EmptyStateComponent.new(**args)
    end

    def a_button(**args, &block)
      render Jav::ButtonComponent.new(is_link: false, **args) do
        capture(&block) if block.present?
      end
    end

    def a_link(path = nil, **args, &block)
      render Jav::ButtonComponent.new(path, is_link: true, **args) do
        capture(&block) if block.present?
      end
    end

    def button_classes(extra_classes = nil, color: nil, variant: nil, size: :md, active: false)
      classes = "inline-flex flex-grow-0 items-center text-sm font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 rounded-sm transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer disabled:cursor-not-allowed #{extra_classes}"

      if color.present?
        if variant.present? && (variant.to_sym == :outlined)
          classes += ' bg-white border'

          classes += " hover:border-#{color}-700 border-#{color}-500 text-#{color}-600 hover:text-#{color}-700 disabled:border-gray-300 disabled:text-gray-600"
        else
          classes += " text-white bg-#{color}-500 hover:bg-#{color}-600 disabled:bg-#{color}-300"
        end
      else
        classes += ' text-gray-700 bg-white hover:bg-gray-100 disabled:bg-gray-300'
      end

      size = size.present? ? size.to_sym : :md
      classes += case size
                 when :xs
                   ' p-2 py-1'
                 when :sm
                   ' py-1 px-4'
                 when :md
                   ' py-2 px-4'
                 when :xl
                   ' py-3 px-4'
                 else
                   ' p-4'
                 end

      classes
    end

    # Use inline_svg gem but with our own finder implementation.
    def svg(file_name, **args)
      return if file_name.blank?

      file_name = "#{file_name}.svg" unless file_name.end_with? '.svg'

      with_asset_finder(::Jav::SvgFinder) do
        inline_svg file_name, **args
      end
    end

    def input_classes(extra_classes = '', has_error: false)
      classes = 'appearance-none inline-flex bg-gray-25 disabled:cursor-not-allowed text-gray-600 disabled:opacity-50 rounded-sm py-2 px-3 leading-tight border focus:border-gray-600 focus-visible:ring-0 focus:text-gray-700 placeholder:text-gray-300'

      classes += if has_error
                   ' border-red-600'
                 else
                   ' border-gray-200'
                 end

      classes += " #{extra_classes}"

      classes
    end

    def white_panel_classes
      'bg-white rounded-sm shadow-sm overflow-hidden'
    end

    def get_model_class(model)
      if model.instance_of?(Class)
        model
      else
        model.class
      end
    end

    def root_path_without_url
      "#{Jav.configuration.prefix_path}#{mount_path}"
    rescue StandardError
      Jav.configuration.root_path
    end

    def mount_path
      Jav::Engine.routes.find_script_name(params.permit!.to_h.symbolize_keys)
    end

    def decode_filter_params(encoded_params)
      Jav::Filters::BaseFilter.decode_filters(encoded_params)
    end

    def encode_filter_params(filter_params)
      Jav::Filters::BaseFilter.encode_filters(filter_params)
    end

    def frame_id(resource)
      ['frame', resource.model_name.singular, resource.model.id].compact.join('-')
    end

    private

    # Taken from the original library
    # https://github.com/jamesmartin/inline_svg/blob/main/lib/inline_svg/action_view/helpers.rb#L76
    def with_asset_finder(asset_finder)
      Thread.current[:inline_svg_asset_finder] = asset_finder
      output = yield
      Thread.current[:inline_svg_asset_finder] = nil

      output
    end

    def jav_field(type = nil, id = nil, as: nil, view: :show, form: nil, component_options: {}, **args, &block)
      if as.present?
        id = type
        type = as
      end
      field_klass = "Jav::Fields::#{type.to_s.camelize}Field".safe_constantize
      field = field_klass.new id, form: form, view: view, **args, &block

      # Add the form record to the field so all fields have access to it.
      field.hydrate(model: form.object) if form.present?

      render field.component_for_view(view).new field: field, form: form, **component_options
    end

    def jav_show_field(id, type = nil, view: :show, **args, &block)
      jav_field(id, type, **args, view: view, &block)
    end

    def jav_edit_field(id, type = nil, view: :edit, **args, &block)
      jav_field(id, type, **args, view: view, &block)
    end

    def field_container(**args, &block)
      classes = args[:class] || ''
      classes << 'flex flex-col divide-y'
      content_tag :div, **args, class: classes, &block
    end
  end
end
