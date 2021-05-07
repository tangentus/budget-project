module TransactionsHelper
  def allowance_types
    # Allowance.for_current_budget.map { |allowance| [allowance.name, allowance.id] }
    Allowance.all.map { |allowance| [allowance.name, allowance.id] }
  end
end
