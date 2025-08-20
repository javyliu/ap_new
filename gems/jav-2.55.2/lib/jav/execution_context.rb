module Jav
  class ExecutionContext
    attr_accessor :target, :context, :params, :view_context, :current_user, :request, :include, :main_app, :jav

    def initialize(**args)
      # Extend the class with custom modules if required.
      if args[:include].present?
        args[:include].each do |mod|
          self.class.send(:include, mod)
        end
      end

      # If you want this block to behave like a view you can delegate the missing methods to the view_context
      #
      # Ex: Jav::ExecutionContext.new(target: ..., delegate_missing_to: :view_context).handle
      self.class.send(:delegate_missing_to, args[:delegate_missing_to]) if args[:delegate_missing_to].present?

      # If target doesn't respond to call, we don't need to initialize the others attr_accessors.
      return unless (@target = args[:target]).respond_to? :call

      args.except(:target).each do |key, value|
        singleton_class.class_eval { attr_accessor key }
        instance_variable_set(:"@#{key}", value)
      end

      # Set defaults on not initialized accessors
      @context ||= Jav::App.context
      @params ||= Jav::App.params
      @view_context ||= Jav::App.view_context
      @current_user ||= Jav::App.current_user
      @request ||= view_context&.request
      @main_app ||= view_context&.main_app
      @jav ||= view_context&.jav
    end

    # Return target if target is not callable, otherwise, execute target on this instance context
    def handle
      target.respond_to?(:call) ? instance_exec(&target) : target
    end
  end
end
