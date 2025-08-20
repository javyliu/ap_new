# frozen_string_literal: true

class Jav::Index::Ordering::BaseComponent < Jav::BaseComponent
  private

  def order_actions
    @resource.class.order_actions
  end
end
