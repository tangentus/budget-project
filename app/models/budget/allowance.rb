class Allowance
  include Mongoid::Document

  field :name, type: String
  field :planned, type: Money
  field :spent, type: Money

  def left_to_spend
    planned - spent
  end

  # @todo store value for `current_budget` that is a dropwdown at the top of screen that always has a value and defaults
  # to beginning of month to end of month.
  def transactions
    # @todo a scope that eases querying for transactions in a particular budget
    Transaction.current_budget.where("split.allowance_id": id)
  end
end