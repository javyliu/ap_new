# requires all dependencies
Gem.loaded_specs["jav"].dependencies.each do |d|
  case d.name
  when "activerecord"
    require "active_record/railtie"
  when "actionview"
    require "action_view/railtie"
  when "activestorage"
    require "active_storage/engine"
  when "actiontext"
    require "action_text/engine"
  else
    require d.name
  end
end

module Jav
  class Engine < ::Rails::Engine
    isolate_namespace Jav

    config.after_initialize do
      # Boot Jav
      ::Jav::App.boot
    end

    initializer "jav.autoload" do |_|
      Jav::ENTITIES.each_value do |path_params|
        path = Rails.root.join(*path_params)
        File.directory?(path.to_s) && Rails.autoloaders.main.push_dir(path.to_s)
      end
    end

    initializer "jav.init_fields" do |_|
      # Init the fields
      ::Jav::App.init_fields
    end

    initializer "jav.reloader" do |app|
      Jav::Reloader.new.tap do |reloader|
        reloader.execute
        app.reloaders << reloader
        app.reloader.to_run { reloader.execute }
      end
    end

    initializer "debug_exception_response_format" do |app|
      app.config.debug_exception_response_format = :api
      # app.config.logger = ::Logger.new(STDOUT)
    end

    initializer "jav.test_buddy" do |_|
      Rails.autoloaders.main.push_dir Jav::Engine.root.join("spec", "helpers") if Jav::IN_DEVELOPMENT
    end

    config.app_middleware.use(
      Rack::Static,
      urls: ["/jav-assets"],
      root: Jav::Engine.root.join("public")
    )

    config.generators do |g|
      g.test_framework :rspec, view_specs: false
    end

    generators do |app|
      Rails::Generators.configure! app.config.generators
      require_relative "../generators/model_generator"
    end

    initializer "jav.locales" do |_|
      I18n.load_path += Dir[Jav::Engine.root.join("lib", "generators", "jav", "templates", "locales", "*.{rb,yml}")]
    end

    # After deploy we want to make sure the license response is being cleared.
    # We need a fresh license response.
    # This is disabled in development because the initialization process might be triggered more than once.
    config.after_initialize do
      unless Rails.env.development?
        begin
          Licensing::HQ.new.clear_response
        rescue StandardError => exception
          Rails.logger.info { "Failed to clear Jav HQ response: #{exception.message}" }
        end
      end
    end
  end
end
