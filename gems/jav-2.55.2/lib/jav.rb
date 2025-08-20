require "zeitwerk"
require_relative "jav/version"
require_relative "jav/engine" if defined?(Rails)

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "html" => "HTML",
  "uri_service" => "URIService",
  "has_html_attributes" => "HasHTMLAttributes"
)
loader.ignore("#{__dir__}/generators")
loader.setup
module Jav
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
  IN_DEVELOPMENT = ENV["JAV_IN_DEVELOPMENT"] == "1"
  PACKED = !IN_DEVELOPMENT
  COOKIES_KEY = "jav"
  ENTITIES = {
    cards: %w[app jav cards],
    fields: %w[app jav fields],
    filters: %w[app jav filters],
    actions: %w[app jav actions],
    resources: %w[app jav resources],
    dashboards: %w[app jav dashboards],
    resource_tools: %w[app jav resource_tools]
  }

  class LicenseVerificationTemperedError < StandardError; end

  class LicenseInvalidError < StandardError; end

  class NotAuthorizedError < StandardError; end

  class NoPolicyError < StandardError; end

  class MissingGemError < StandardError; end
end

loader.eager_load
