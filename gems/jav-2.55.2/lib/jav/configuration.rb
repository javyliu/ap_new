module Jav
  class Configuration
    include ResourceConfiguration

    attr_writer :app_name, :branding, :root_path, :cache_store
    attr_accessor :timezone, :per_page, :per_page_steps, :via_per_page, :locale, :currency, :default_view_type, :license, :license_key, :authorization_methods, :authenticate, :current_user, :id_links_to_resource, :full_width_container, :full_width_index_view, :cache_resources_on_index_view, :cache_resource_filters, :context, :display_breadcrumbs, :hide_layout_when_printing, :initial_breadcrumbs, :home_path, :search_debounce, :view_component_path, :display_license_request_timeout_error, :current_user_resource_name, :raise_error_on_missing_policy, :disabled_features, :buttons_on_form_footers, :main_menu, :profile_menu, :model_resource_mapping, :tabs_style, :resource_default_view, :authorization_client, :field_wrapper_layout, :sign_out_path_name, :resources, :prefix_path

    def initialize
      @root_path = "/jav"
      @app_name = ::Rails.application.class.to_s.split("::").first.underscore.humanize(keep_id_suffix: true)
      @timezone = "UTC"
      @per_page = 24
      @per_page_steps = [12, 24, 48, 72]
      @via_per_page = 8
      @locale = nil
      @currency = "USD"
      @default_view_type = :table
      @license = "community"
      @license_key = nil
      @current_user = proc {}
      @authenticate = proc {}
      @authorization_methods = {
        index: "index?",
        show: "show?",
        edit: "edit?",
        new: "new?",
        update: "update?",
        create: "create?",
        destroy: "destroy?"
      }
      @id_links_to_resource = false
      @full_width_container = false
      @full_width_index_view = false
      @cache_resources_on_index_view = Jav::PACKED
      @cache_resource_filters = false
      @context = proc {}
      @initial_breadcrumbs = proc {
        add_breadcrumb I18n.t("jav.home").humanize, jav.root_path
      }
      @display_breadcrumbs = true
      @hide_layout_when_printing = false
      @home_path = nil
      @search_debounce = 300
      @view_component_path = "app/components"
      @display_license_request_timeout_error = true
      @current_user_resource_name = "user"
      @raise_error_on_missing_policy = false
      @disabled_features = []
      @buttons_on_form_footers = false
      @main_menu = nil
      @profile_menu = nil
      @model_resource_mapping = {}
      @tabs_style = :tabs
      @resource_default_view = :show
      @authorization_client = :pundit
      @field_wrapper_layout = :inline
      @resources = nil
      @prefix_path = nil
      @cache_store = computed_cache_store
    end

    def current_user_method(&block)
      @current_user = block if block.present?
    end

    def current_user_method=(method)
      @current_user = method if method.present?
    end

    def authenticate_with(&block)
      @authenticate = block if block.present?
    end

    def set_context(&block)
      @context = block if block.present?
    end

    def set_initial_breadcrumbs(&block)
      @initial_breadcrumbs = block if block.present?
    end

    def namespace
      if Jav.configuration.root_path.present?
        Jav.configuration.root_path.delete "/"
      else
        root_path.delete "/"
      end
    end

    def root_path
      return "" if @root_path == "/"

      @root_path
    end

    def feature_enabled?(feature)
      @disabled_features.map(&:to_sym).exclude?(feature.to_sym)
    end

    def branding
      Jav::Configuration::Branding.new(**@branding || {})
    end

    def app_name
      if @app_name.respond_to? :call
        Jav::Hosts::BaseHost.new(block: @app_name).handle
      else
        @app_name
      end
    end

    def cache_store
      Jav::ExecutionContext.new(
        target: @cache_store,
        production_rejected_cache_stores: %w[ActiveSupport::Cache::MemoryStore ActiveSupport::Cache::NullStore]
      ).handle
    end

    # When not in production or test we'll just use the MemoryStore which is good enough.
    # When running in production we'll use Rails.cache if it's not ActiveSupport::Cache::MemoryStore or ActiveSupport::Cache::NullStore.
    # If it's one of rejected cache stores, we'll use the FileStore.
    # We decided against the MemoryStore in production because it will not be shared between multiple processes (when using Puma).
    def computed_cache_store
      lambda {
        if Rails.env.production?
          if Rails.cache.class.to_s.in?(production_rejected_cache_stores)
            ActiveSupport::Cache.lookup_store(:file_store, Rails.root.join("tmp/cache"))
          else
            Rails.cache
          end
        elsif Rails.env.test?
          Rails.cache
        else
          ActiveSupport::Cache.lookup_store(:memory_store)
        end
      }
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
