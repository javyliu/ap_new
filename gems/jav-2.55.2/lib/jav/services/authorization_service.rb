module Jav
  module Services
    class AuthorizationService
      attr_accessor :user, :record, :policy_class

      class << self
        def client
          client = Jav.configuration.authorization_client

          klass = case client
                  when nil
                    nil_client
                  when :pundit
                    pundit_client
                  else
                    if client.is_a?(String)
                      client.safe_constantize
                    else
                      client
                    end
                  end

          klass.new
        end

        def authorize(user, record, action, policy_class: nil, **args)
          client.authorize user, record, action, policy_class: policy_class

          true
        rescue NoPolicyError => error
          # By default, Jav allows anything if you don't have a policy present.
          return true unless Jav.configuration.raise_error_on_missing_policy

          raise error
        rescue StandardError => error
          raise error unless args[:raise_exception] == false

          false
        end

        def authorize_action(user, record, action, policy_class: nil, **args)
          action = Jav.configuration.authorization_methods.stringify_keys[action.to_s] || action

          # If no action passed we should raise error if the user wants that.
          # If not, just allow it.
          if action.nil?
            raise NoPolicyError, "Policy method is missing" if Jav.configuration.raise_error_on_missing_policy

            return true
          end

          # Add the question mark if it's missing
          action = "#{action}?" unless action.end_with? "?"
          authorize(user, record, action, policy_class: policy_class, **args)
        end

        def apply_policy(user, model, policy_class: nil)
          client.apply_policy(user, model, policy_class: policy_class)
        rescue NoPolicyError => error
          return model unless Jav.configuration.raise_error_on_missing_policy

          raise error
        end

        def skip_authorization
          Jav::App.license.lacks_with_trial :authorization
        end

        def defined_methods(user, record, policy_class: nil, **args)
          return client.policy!(user, record).methods if policy_class.nil?

          # I'm aware this will not raise a Pundit error.
          # Should the policy not exist, it will however raise an uninitialized constant error, which is probably what we want when specifying a custom policy
          policy_class.new(user, record).methods
        rescue NoPolicyError => error
          return [] unless Jav.configuration.raise_error_on_missing_policy

          raise error
        rescue StandardError => error
          raise error unless args[:raise_exception] == false

          []
        end

        def pundit_client
          raise Jav::MissingGemError, "Please add `gem 'pundit'` to your Gemfile." unless defined?(Pundit)

          Jav::Services::AuthorizationClients::PunditClient
        end

        def nil_client
          Jav::Services::AuthorizationClients::NilClient
        end
      end

      def initialize(user = nil, record = nil, policy_class: nil)
        @user = user
        @record = record
        @policy_class = policy_class || self.class.client.policy(user, record)&.class
      end

      def set_record(record)
        @record = record

        self
      end

      def authorize_action(action, **args)
        self.class.authorize_action(user, args[:record] || record, action, policy_class: policy_class, **args)
      end

      def apply_policy(model)
        self.class.apply_policy(user, model, policy_class: policy_class)
      end

      def defined_methods(model, **args)
        self.class.defined_methods(user, model, policy_class: policy_class, **args)
      end

      def has_method?(method, **args)
        method = "#{method}?" unless method.to_s.end_with? "?"
        defined_methods(args[:record] || record, **args).include? method.to_sym
      end

      # Check the received method to see if the user overrode it in their config and then checks if it's present on the policy.
      def has_action_method?(method, **args)
        method = Jav.configuration.authorization_methods.stringify_keys[method.to_s] || method

        has_method? method, **args
      end
    end
  end
end
