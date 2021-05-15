class Budget
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime

  def transactions
    Transaction.where(created_at: {"$gte": start_date, "$lte": end_date})
  end
end
