require 'digest'
require 'erb'

module Jav
  module Fields
    class GravatarField < BaseField
      attr_reader :link_to_resource, :rounded, :size, :default

      def initialize(id, **args, &block)
        args[:name] ||= 'Avatar'

        super

        hide_on %i[edit new]

        @link_to_resource = args[:link_to_resource].presence || false
        @rounded = args[:rounded].nil? ? true : args[:rounded]
        @size = args[:size].present? ? args[:size].to_i : 32
        @default = args[:default].present? ? ERB::Util.url_encode(args[:default]).to_s : ''
      end

      def md5
        return if value.blank?

        Digest::MD5.hexdigest(value.strip.downcase)
      end

      def to_image
        options = {
          default: '',
          size: 340
        }

        query = options.map { |key, value| "#{key}=#{value}" }.join('&')

        URI::HTTPS.build(host: 'www.gravatar.com', path: "/avatar/#{md5}", query: query).to_s
      end
    end
  end
end
