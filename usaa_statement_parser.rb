require "csv"

def extract_transaction(row)
  date = row[2]
  description = row[4]
  amount = row[6]

  {
    date: date,
    description: description,
    amount: amount
  }
end

transactions = CSV.read("./usaa_exports/usaa_transactions.csv")
transactions.each do |transaction_row|
  transaction = extract_transaction(transaction_row)

  puts "Amount: #{transaction[:amount]} for: #{transaction[:description]}"
end


