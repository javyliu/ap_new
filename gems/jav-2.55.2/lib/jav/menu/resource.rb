class Jav::Menu::Resource < Jav::Menu::BaseItem
  extend Dry::Initializer

  option :resource
  option :label, optional: true
  option :params, default: proc { {} }

  def parsed_resource
    @parsed_resource ||= Jav::App.guess_resource resource.to_s
  end

  def entity_label
    parsed_resource.navigation_label
  end

  def fetch_params
    Jav::ExecutionContext.new(
      target: params,
      resource: parsed_resource
    ).handle
  end
end
