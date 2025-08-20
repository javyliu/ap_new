module Jav
  class ToolsManager
    def self.get_tools
      Jav::Tools.constants.map do |c|
        "Jav::Tools::#{c}".safe_constantize if Jav::Tools.const_get(c).is_a?(Class)
      end
    end
  end
end
