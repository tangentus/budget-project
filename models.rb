# Modeling v2

class Transaction
  attr_accessor :processed_at # the date the transaction appeared in the bank; may be nil if no bank transaction exists yet
  attr_accessor :created_at # the date the transaction was tracked in-app
  attr_accessor :type # can be :deposit or :withdrawal
  attr_accessor :amount
  attr_accessor :description
  attr_accessor :split # [{allowance_id: BSON:ObjectId, allowance_amount: Money}] description of how the transaction is split between allowances; simple case is one element out of one budget
  attr_accessor :balance # result balance of account after this transaction...should I do this?
end

class Allowance # embedded document
  attr_accessor :planned

  def spent; end
  def left_to_spend; end
  def transactions; end
end

# View a Budget
budget_begin = Time.now # is some timestamp indicating the beginning of a budget period
budget_end = Time.now # is some timestamp indicating the end of a budget period
Transaction.where(created_at: {"$gte": budget_begin}, created_at: {"$lt": budget_end})

# View allowances of a Budget
# probably can use an $group stage in an aggregate to get total spent
split_charges = Transaction.where(created_at: {"$gte": budget_begin}, created_at: {"$lt": budget_end})
           .only(:split).pluck(:split)
allowances = Allowance.where(id: {"$in": split_charges.pluck(:id)})
# We could now combine info from split charges and allowances to display a run-down

# Modeling v1
class Transaction
  attr_accessor :processed_at # the date the transaction appeared in the bank; may be nil if no bank transaction exists yet
  attr_accessor :created_at # the date the transaction was tracked in-app
  attr_accessor :type # can be :deposit or :withdrawal
  attr_accessor :amount
  attr_accessor :description
  attr_accessor :split # description of how the transaction is split between allowances; simple case is one element out of one budget
  attr_accessor :balance # result balance of account after this transaction...should I do this?
end

# this will "fall into" a budget by default (using date of transaction). Do you use processed_at or created_at for budget selection?
Transaction.new(
  processed_at: nil,
  type: :withdrawal,
  amount: Money.new(300),
  description: "first transaction",
  split: {
    # keys are allowance names
    food: Money.new(100),
    entertainment: Money.new(200)
  },
  balance: Money.new(9700)
)

# all transactions
Transaction.all

# transactions for a budget
Budget.find("id").transactions # these will be clickable and will navigate to a transaction page with more details

# all allowances for a budget
# order-by start_date descending (most recent budget first), find the one that is _before_ or _at_ the current time
Budget.where(start_date: {"$lte": Time.now}).order_by(start_date: 1).allowances

class Allowance # embedded document
  attr_accessor :planned

  def spent; end
  def left_to_spend; end
  def transactions; end
end

# since these are date based, there will _probably_ only be one active at a time. but it should be implicit
class Budget
  attr_accessor :start_date # the beginning date to filter transactions by
  attr_accessor :end_date # the last date to filter transactions by. when you "close" a budget, it will persist this date
  attr_accessor :beginning_balance # the balance when this budget was started
  attr_accessor :name # most commonly will be Month..maybe something else though?
  attr_accessor :transactions # denormalized transaction documents w/ amount, desc, and split details.
  attr_accessor :allowances # embedded allowance document
end

