module Currentable
  extend ActiveSupport::Concern

  class_methods do
    def current_budget=(budget)
      Thread.current[:current_budget] = budget
    end

    def current_budget
      Thread.current[:current_budget]
    end
  end
end