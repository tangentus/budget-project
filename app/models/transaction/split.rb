class Transaction::Split
  include Mongoid::Document

  field :allowance, type: String
  field :amount, type: Money

  embedded_in :transaction
end