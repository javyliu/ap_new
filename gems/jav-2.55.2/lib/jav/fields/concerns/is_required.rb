module Jav
  module Fields
    module Concerns
      module IsRequired
        extend ActiveSupport::Concern

        def is_required?
          if required.respond_to? :call
            Jav::Hosts::ResourceViewRecordHost.new(block: required, record: model, view: view, resource: resource).handle
          else
            required.nil? ? required_from_validators : required
          end
        end

        private

        def required_from_validators
          return false if model.nil?

          validators.any?(ActiveModel::Validations::PresenceValidator)
        end

        def validators
          model.class.validators_on(id)
        end
      end
    end
  end
end
