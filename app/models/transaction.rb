class Transaction
  TYPES = {
    deposit: :deposit,
    withdrawal: :withdrawal
  }

  include Mongoid::Document
  include Mongoid::Timestamps

  field :processed_at, type: DateTime
  field :type, type: String
  field :amount, type: Money
  field :description, type: String
  field :balance, type: Money

  # after_save :update_allowances
  # after_destroy :update_allowances

  # @todo add validation to ensure that when these exists, that there are _at least_ two of them
  embeds_many :splits, store_as: :split_charges

  validates_inclusion_of :type, in: TYPES.values.concat(TYPES.values.map(&:to_s))

  def income
    Transaction.current_budget.where(type: TYPES[:deposit]).only(:amount).pluck(:amount).sum
  end

  def left_to_spend
    # @todo query of Allowances that sums the amount left to spend (planned - spent). this can be done in an aggregate
    aggregate_query = nil

    income - aggregate_query
  end

  def left_to_assign
    # @todo query of allowances that sums the amount planned for each allowance
    aggregate_query = nil
      
    income - aggregate_query
  end

  private

  def update_allowances
    Mongoid::QueryCache.enabled = true
    Allowance.current_budget.each do |allowance|
      result = collection.aggregate([
                                      {
                                        "$match": {
                                          "split.allowance_id": id,
                                          created_at: {"$gte": current_budget.begin, "lt": current_budget.end}
                                        }
                                      },
                                      {
                                        "$group": {
                                          _id: "split.allowance_id",
                                          spent: {
                                            "$sum": "split.allowance_amount"
                                          }
                                        }
                                      }
                                    ])

      allowance.update(spent: result[:spent])
    end

    Mongoid::QueryCache.enabled = false

    true
  end
end
