require "dry-initializer"

# This object holds some data tha is usually needed to compute blocks around the app.
module Jav
  module Resources
    module Controls
      class ExecutionContext
        extend Dry::Initializer

        option :context, default: proc { Jav::App.context }
        option :params, default: proc { Jav::App.params }
        option :view_context, default: proc { Jav::App.view_context }
        option :current_user, default: proc { Jav::App.current_user }
        option :items_holder, default: proc { Jav::Resources::Controls::ItemsHolder.new }
        option :resource, optional: true
        option :record, optional: true
        option :view, optional: true
        option :block, optional: true

        delegate :authorize, to: Jav::Services::AuthorizationService

        def handle
          instance_exec(&block)
        end

        private

        def back_button(**args)
          items_holder.add_item Jav::Resources::Controls::BackButton.new(**args)
        end

        def delete_button(**args)
          items_holder.add_item Jav::Resources::Controls::DeleteButton.new(**args)
        end

        def detach_button(**args)
          items_holder.add_item Jav::Resources::Controls::DetachButton.new(**args)
        end

        def edit_button(**args)
          items_holder.add_item Jav::Resources::Controls::EditButton.new(**args)
        end

        def link_to(label, path, **args)
          items_holder.add_item Jav::Resources::Controls::LinkTo.new(label: label, path: path, **args)
        end

        def actions_list(**args)
          items_holder.add_item Jav::Resources::Controls::ActionsList.new(**args)
        end

        def action(klass, **args)
          items_holder.add_item Jav::Resources::Controls::Action.new(klass, record: record, resource: resource, view: view, **args)
        end
      end
    end
  end
end
