class AddDefaultAllowance < Mongoid::Migration
  def self.up
    Allowance.create({
                       name: "Uncategorized"
                     })
  end

  def self.down
    Allowance.where(name: "Uncategorized").destroy
  end
end