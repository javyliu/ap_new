module Jav
  module Fields
    class DateTimeField < DateField
      attr_reader :format, :picker_format, :time_24hr, :relative

      def initialize(id, **args, &block)
        super

        add_boolean_prop args, :time_24hr
        add_string_prop args, :picker_format, "Y-m-d H:i:S"
        add_string_prop args, :format, "yyyy-LL-dd TT"
        add_string_prop args, :timezone
        add_boolean_prop args, :relative, true
      end

      def formatted_value
        return nil if value.nil?

        value.utc.to_time.iso8601
      end

      def edit_formatted_value
        return nil if value.nil?

        value.utc.iso8601
      end

      def fill_field(model, key, value, params)
        if value.in?(["", nil])
          model[id] = value

          return model
        end

        return model if value.blank?

        model[id] = utc_time(value)

        model
      end

      def utc_time(value)
        time = Time.zone.parse(value)

        if timezone.present? && !time.utc?
          ActiveSupport::TimeZone.new(timezone).local_to_utc(time)
        else
          value
        end
      end

      def timezone
        timezone = if @timezone.respond_to?(:call)
                     return Jav::Hosts::ResourceViewRecordHost.new(block: @timezone, record: resource.model, resource: resource, view: view).handle
                   else
                     @timezone
                   end

        # Fix for https://github.com/moment/luxon/issues/1358#issuecomment-2017477897
        return "Etc/UTC" if timezone&.downcase == "utc" && view.in?(%i[new create edit update])

        timezone
      end
    end
  end
end
