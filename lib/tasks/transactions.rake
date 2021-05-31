require 'csv'

namespace :transactions do
  def read
    STDIN.gets.chomp
  end

  def retrieve_files
    puts "What is the newest transaction list location?"
    new_transaction_filename = read

    puts "What is the older transaction list location?"
    old_transaction_filename = read

    file = nil
    unless File.exists?(old_transaction_filename)
      file = old_transaction_filename
    end

    unless File.exists?(new_transaction_filename)
      file = new_transaction_filename
    end

    raise StandardError, "This location file does not exist. #{file}" if file

    [old_transaction_filename, new_transaction_filename]
  end

  desc "Does a diff of two different transaction exports from USAA to find differences in transactions."
  task diff: :environment do
    old_filename, new_filename = retrieve_files

    # status,nil,date,nil,desc,category,amount
    # posted,,05/28/2021,,PAYPAL           INST XFER  ***********BILL,Online Services,-2.99
    #
    # @note: Sometimes "amount" is represented like "--2.99", which is equivalent to "2.99"
    old_transactions = CSV.parse(File.read(old_filename))
    new_transactions = CSV.parse(File.read(new_filename))

    old_transaction_map = {}
    old_transactions.each do |transaction_row|
      # 0: status
      # 1: nil
      # 2: date
      # 3: nil
      # 4: desc
      # 5: category
      # 6: amount
      status = transaction_row[0]
      date = transaction_row[2]
      descr = transaction_row[4]
      category = transaction_row[5]
      amount = transaction_row[6]

      record = {
        status: status,
        date: date,
        descr: descr,
        category: category,
        amount: amount
      }

      old_transaction_map["#{status}#{date}#{descr}#{category}#{amount}"] = record
      old_transaction_map["#{date}#{descr}#{category}#{amount}"] = record
      old_transaction_map["#{descr}#{category}#{amount}"] = record
      old_transaction_map["#{category}#{amount}"] = record
      old_transaction_map["#{amount}"] = record
    end

    new_transactions.each do |transaction_row|
      status = transaction_row[0]
      date = transaction_row[2]
      descr = transaction_row[4]
      category = transaction_row[5]
      amount = transaction_row[6]

      # [
      #   {
      #     status: {
      #       old: "",
      #       new: "",
      #     },
      #     date: {
      #       old: "",
      #       new: ""
      #     }
      #     ...etc
      #   }
      # ]
      statuses = []

      # record format in old_transaction_map:
      # {
      #   status: status,
      #   date: date,
      #   descr: descr,
      #   category: category,
      #   amount: amount
      # }
      old_record = old_transaction_map["#{status}#{date}#{descr}#{category}#{amount}"]
      statuses << {
        status: {
          old: old_record[:status],
          new: status
        },
        date: {
          old: old_record[:date],
          new: date
        },
        descr: {
          old: old_record[:descr],
          new: descr
        },
        category: {
          old: old_record[:category],
          new: descr
        },
        amount: {
          old: old_record[:amount],
          new: amount
        }
      }
    end
  end
end
