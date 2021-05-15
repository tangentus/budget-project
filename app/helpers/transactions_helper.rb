module TransactionsHelper
  def allowance_types
    # Allowance.for_current_budget.map { |allowance| [allowance.name, allowance.id] }
    Allowance.all.map { |allowance| [allowance.name, allowance.id] }
  end

  def allowance_name(id)
    Allowance.find(id).name
  end

  def allowance_names(ids)
    ids = [ids] unless ids.is_a?(Array)

    ids.map {|id| allowance_name(id) }
  end
end
