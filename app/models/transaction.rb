class Transaction
  TYPES = {
    deposit: :deposit,
    withdrawal: :withdrawal
  }

  include Mongoid::Document
  include Mongoid::Timestamps

  field :processed_at, type: DateTime
  field :transaction_date, type: DateTime, default: DateTime.now
  field :type, type: String
  field :amount, type: Money
  field :description, type: String
  field :balance, type: Money

  after_save :update_allowances
  after_destroy :update_allowances

  # @todo add validation to ensure that when these exists, that there are _at least_ two of them
  embeds_many :splits

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
    # Mongoid::QueryCache.enabled = true

    impacted_allowances = splits.pluck(:allowance)
    result = collection.aggregate([
                                    {
                                      "$match": {
                                        "splits.allowance": { "$in": impacted_allowances },
                                        "$and": [
                                          # {transaction_date: {"$gte": Budget.current_budget.start_date}},
                                          # {transaction_date: {"$lte": Budget.current_budget.end_date}}
                                          # overridden to explicit times until the budget selection can be modified
                                          {transaction_date: {"$gte": DateTime.parse("Tue, 11 May 2021 00:34:00 +0000")}},
                                          {transaction_date: {"$lte": DateTime.parse("Wed, 30 Jun 2021 00:34:00 +0000")}}
                                        ],
                                        type: TYPES[:withdrawal]
                                      }
                                    },
                                    {
                                      "$unwind": "$splits"
                                    },
                                    {
                                      "$group": {
                                        _id: "$splits.allowance",
                                        spent: {
                                          "$sum": "$splits.amount.cents"
                                        }
                                      }
                                    }
                                  ])
    aggregates = []

    result.each do |doc|
      Allowance.find(doc[:_id]).update(spent: Monetize.from_float(doc[:spent]))
      # aggregates << {
      #   update_one: {
      #     filter: {
      #       id: doc[:_id]
      #     },
      #     update: {
      #       "$set": {
      #         spent: {
      #           cents: doc[:spent].to_i.to_s,
      #           currency_iso: "USD"
      #         }
      #       }
      #     }
      #   }
      # }
    end

    # Allowance.collection.bulk_write(aggregates)

    # Mongoid::QueryCache.enabled = false

    true
  end
end
