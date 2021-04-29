class Transaction::Split
  include Mongoid::Document

  field :allowance, type: BSON::ObjectId
  field :amount, type: Money

  embedded_in :transaction
end