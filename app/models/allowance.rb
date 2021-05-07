class Allowance
  UNCATEGORIZED = "Uncategorized".freeze

  include Mongoid::Document

  field :name, type: String
  field :starting_amount, type: Money, default: Money.new(0)
  field :planned, type: Money, default: Money.new(0)
  field :spent, type: Money, default: Money.new(0)
  field :category, type: String, default: UNCATEGORIZED
  field :start_date, type: DateTime, default: DateTime.now
  field :end_date, type: DateTime

  validates :name, uniqueness: { case_sensitive: false }

  # scope :for_current_budget, -> { where(start_date: {"$gte": current_budget.begin}, end_date: {"$lt": current_budget.end}) }

  def left_to_spend
    planned - spent
  end

  # @todo store value for `current_budget` that is a dropdown at the top of screen that always has a value and defaults
  # to beginning of month to end of month.
  def transactions
    # @todo a scope that eases querying for transactions in a particular budget
    Transaction.current_budget.where("split.allowance_id": id)
  end
end