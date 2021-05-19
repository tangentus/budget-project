module AllowancesHelper
  def budget_options
    Budget.all.map { |budget|  [budget.name.capitalize, budget.id] }
  end
end
