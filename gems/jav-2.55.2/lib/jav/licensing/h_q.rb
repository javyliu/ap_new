module Jav
  module Licensing
    class HQ
      attr_accessor :current_request, :cache_store

      ENDPOINT = "https://javhq.io/api/v1/licenses/check".freeze unless const_defined?(:ENDPOINT)
      REQUEST_TIMEOUT = 5 unless const_defined?(:REQUEST_TIMEOUT) # seconds
      CACHE_TIME = 3600 * 12 unless const_defined?(:CACHE_TIME) # seconds

      class << self
        def cache_key
          "jav.hq-#{Jav::VERSION.parameterize}.response"
        end
      end

      def initialize(current_request = nil)
        @current_request = current_request
        @cache_store = Jav::App.cache_store
      end

      def response
        { 'id' => 'pro',
          'valid' => true,
          'payload' => {},
          'expiry' => 3600,
          'fetched_at' => Time.zone.now,
          'license' => 'pro',
          'license_key' => nil }
        # expire_cache_if_overdue
        # ::Rails.cache.fetch(self.class.cache_key) do
        #   { 'id' => 'pro',
        #     'valid' => true,
        #     'payload' => {},
        #     'expiry' => 3600,
        #     'fetched_at' => Time.zone.now,
        #     'license' => 'pro',
        #     'license_key' => nil }
        # end
      end

      # Some cache stores don't auto-expire their keys and payloads so we need to do it for them
      def expire_cache_if_overdue
        return unless cached_response.present?
        return unless cached_response["fetched_at"].present?

        allowed_time = 1.hour
        parsed_time = Time.parse(cached_response["fetched_at"].to_s)
        time_has_passed = parsed_time < Time.now - allowed_time

        clear_response if time_has_passed
      end

      def fresh_response
        clear_response

        make_request
      end

      def clear_response
        # cache_store.delete self.class.cache_key
      end

      def payload
        result = {
          license: Jav.configuration.license,
          license_key: Jav.configuration.license_key,
          jav_version: Jav::VERSION,
          rails_version: Rails::VERSION::STRING,
          ruby_version: RUBY_VERSION,
          environment: Rails.env,
          ip: current_request&.ip,
          host: current_request&.host,
          port: current_request&.port,
          app_name: app_name
        }

        metadata = jav_metadata
        result[:jav_metadata] = metadata if metadata[:resources_count] != 0

        result
      end

      def jav_metadata
        resources = App.resources
        dashboards = App.dashboards
        field_definitions = resources.map(&:get_field_definitions)
        fields_count = field_definitions.map(&:count).sum
        fields_per_resource = format("%0.01f", fields_count / (resources.count + 0.0))

        field_types = {}
        custom_fields_count = 0
        field_definitions.each do |fields|
          fields.each do |field|
            field_types[field.type] ||= 0
            field_types[field.type] += 1

            custom_fields_count += 1 if field.custom?
          end
        end

        {
          resources_count: resources.count,
          dashboards_count: dashboards.count,
          fields_count: fields_count,
          fields_per_resource: fields_per_resource,
          custom_fields_count: custom_fields_count,
          field_types: field_types,
          **other_metadata(:actions),
          **other_metadata(:filters),
          main_menu_present: Jav.configuration.main_menu.present?,
          profile_menu_present: Jav.configuration.profile_menu.present?,
          cache_store: Jav::App.cache_store&.class&.to_s,
          **config_metadata
        }
      rescue StandardError => e
        {
          error: e.message
        }
      end

      def cached_response
        response
        # cache_store.read self.class.cache_key
      end

      private

        def make_request
          return cached_response if has_cached_response

          begin
            perform_and_cache_request
          rescue Errno::EHOSTUNREACH => exception
            cache_and_return_error "HTTP host not reachable error.", exception.message
          rescue Errno::ECONNRESET => exception
            cache_and_return_error "HTTP connection reset error.", exception.message
          rescue Errno::ECONNREFUSED => exception
            cache_and_return_error "HTTP connection refused error.", exception.message
          rescue OpenSSL::SSL::SSLError => exception
            cache_and_return_error "OpenSSL error.", exception.message
          rescue HTTParty::Error => exception
            cache_and_return_error "HTTP client error.", exception.message
          rescue Net::OpenTimeout => exception
            cache_and_return_error "Request timeout.", exception.message
          rescue Net::ReadTimeout => exception
            cache_and_return_error "Request timeout.", exception.message
          rescue SocketError => exception
            cache_and_return_error "Connection error.", exception.message
          end
        end

        def perform_and_cache_request
          hq_response = perform_request

          return cache_and_return_error "Jav HQ Internal server error.", hq_response.body if hq_response.code == 500

          return unless hq_response.code == 200

          cache_response response: hq_response.parsed_response
        end

        def cache_response(response: nil, time: CACHE_TIME)
          response = normalize_response response

          response.merge!(
            expiry: time,
            fetched_at: Time.now,
            **payload
          ).stringify_keys!

          # cache_store.write(self.class.cache_key, response, expires_in: time)

          response
        end

        def normalize_response(response)
          if response.is_a? Hash
            response
          else
            {
              normalized_response: JSON.stringify(response)
            }
          end
          response.merge({})
        rescue StandardError
          {
            normalized_response: "rescued"
          }
        end

        def perform_request
          ::Rails.logger.debug "[Jav] Performing request to javhq.io API to check license availability." if Rails.env.development?

          if Rails.env.test?
            OpenStruct.new({ code: 200, parsed_response: { id: "pro", valid: true } })
          else
            HTTParty.post ENDPOINT, body: payload.to_json, headers: { 'Content-type': "application/json" }, timeout: REQUEST_TIMEOUT
          end
        end

        def app_name
          Rails.application.class.to_s.split("::").first
        rescue StandardError
          nil
        end

        def other_metadata(type = :actions)
          resources = App.resources

          types = resources.map(&:"get_#{type}")
          type_count = types.flatten.uniq.count
          type_per_resource = format("%0.01f", types.map(&:count).sum / (resources.count + 0.0))

          {
            "#{type}_count": type_count,
            "#{type}_per_resource": type_per_resource
          }
        end

        def config_metadata
          {
            config: {
              root_path: Jav.configuration.root_path,
              app_name: Jav.configuration.app_name
            }
          }
        end

        def cache_and_return_error(error, exception_message = "")
          cache_response response: {
            id: Jav.configuration.license,
            valid: true,
            error: error,
            exception_message: exception_message
          }.stringify_keys, time: 5.minutes.to_i
        end

        def has_cached_response
          # cache_store.exist? self.class.cache_key
        end
    end
  end
end
